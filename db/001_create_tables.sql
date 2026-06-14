-- ============================================
-- RESERVAPRO 
-- ============================================

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 1. AUTENTICACIÓN (simulación local de Supabase)
-- ============================================
CREATE TABLE IF NOT EXISTS auth_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,  -- bcrypt hash
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. NEGOCIOS (PYMEs)
-- ============================================
CREATE TABLE IF NOT EXISTS negocios (
    id_negocio UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_boss UUID NOT NULL REFERENCES auth_users(id) ON DELETE RESTRICT,
    -- RESTRICT: no se puede borrar usuario si tiene negocio
    
    nombre_negocio VARCHAR(150) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    -- slug personalizado: "peluqueria-fulanita"
    -- Seguridad: UNIQUE evita colisiones
    
    descripcion TEXT,
    direccion VARCHAR(255),
    telefono VARCHAR(20),
    
    tipo_plan VARCHAR(20) NOT NULL DEFAULT 'gratis' 
        CHECK (tipo_plan IN ('gratis', 'pro', 'empresa')),
    
    zona_horaria VARCHAR(50) NOT NULL DEFAULT 'America/Santiago',
    creado_en TIMESTAMPTZ DEFAULT NOW(),
    actualizado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 3. PROFESIONALES / EMPLEADOS
-- ============================================
CREATE TABLE IF NOT EXISTS profesionales (
    id_profesional UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_auth UUID NOT NULL REFERENCES auth_users(id) ON DELETE CASCADE,
    id_negocio UUID NOT NULL REFERENCES negocios(id_negocio) ON DELETE CASCADE,
    
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    
    slug_publico VARCHAR(100) UNIQUE,
    -- Para agenda individual: "reservapro.app/p/maria-gomez"
    
    rol VARCHAR(20) NOT NULL DEFAULT 'profesional'
        CHECK (rol IN ('boss', 'profesional')),
    -- 'boss': puede gestionar empleados, ver todo
    -- 'profesional': solo ve su horario
    
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 4. SERVICIOS
-- ============================================
CREATE TABLE IF NOT EXISTS servicios (
    id_servicio UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_negocio UUID NOT NULL REFERENCES negocios(id_negocio) ON DELETE CASCADE,
    id_profesional UUID REFERENCES profesionales(id_profesional) ON DELETE SET NULL,
    -- NULL = servicio genérico del negocio, cualquier profesional lo puede hacer
    -- NOT NULL = servicio específico de ese profesional
    
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_minutos INTEGER NOT NULL CHECK (duracion_minutos > 0),
    precio NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    color VARCHAR(7) DEFAULT '#6366F1',  -- Para calendario visual
    
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 5. REGLAS DE DISPONIBILIDAD
-- ============================================
CREATE TABLE IF NOT EXISTS regla_disponibilidad (
    id_disp UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_profesional UUID NOT NULL REFERENCES profesionales(id_profesional) ON DELETE CASCADE,
    
    dia_semana SMALLINT NOT NULL CHECK (dia_semana >= 0 AND dia_semana <= 6),
    -- 0=domingo, 1=lunes, ..., 6=sábado
    
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    
    CONSTRAINT horas_coherentes CHECK (hora_fin > hora_inicio),
    
    creado_en TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 6. CITAS (Core del negocio)
-- ============================================
CREATE TABLE IF NOT EXISTS citas (
    id_cita UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_negocio UUID NOT NULL REFERENCES negocios(id_negocio) ON DELETE CASCADE,
    id_profesional UUID NOT NULL REFERENCES profesionales(id_profesional) ON DELETE CASCADE,
    id_servicio UUID NOT NULL REFERENCES servicios(id_servicio) ON DELETE RESTRICT,
    
    -- Datos del cliente (denormalizados, no requiere login)
    nombre_cliente VARCHAR(100) NOT NULL,
    email_cliente VARCHAR(255) NOT NULL,
    telefono_cliente VARCHAR(20),
    
    -- Horarios en UTC (persistencia), transformación en borde
    hora_inicio TIMESTAMPTZ NOT NULL,
    hora_fin TIMESTAMPTZ NOT NULL,
    
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente'
        CHECK (estado IN ('pendiente', 'confirmada', 'cancelada', 'completada')),
    
    notas TEXT,
    creado_en TIMESTAMPTZ DEFAULT NOW(),
    
    -- REGLA CRÍTICA: Prevención de Double Booking a nivel de BD
    CONSTRAINT evitar_double_booking UNIQUE (id_profesional, hora_inicio)
);

-- ============================================
-- ÍNDICES DE PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_citas_profesional_fecha 
    ON citas(id_profesional, hora_inicio);
    
CREATE INDEX IF NOT EXISTS idx_citas_negocio_fecha 
    ON citas(id_negocio, hora_inicio);
    
CREATE INDEX IF NOT EXISTS idx_servicios_negocio 
    ON servicios(id_negocio, activo);
    
CREATE INDEX IF NOT EXISTS idx_profesionales_negocio 
    ON profesionales(id_negocio, rol, activo);
    
CREATE INDEX IF NOT EXISTS idx_regla_disp_profesional 
    ON regla_disponibilidad(id_profesional, dia_semana);

-- ============================================
-- VISTA: Agenda pública (solo datos necesarios)
-- ============================================
CREATE OR REPLACE VIEW vista_agenda_publica AS
SELECT 
    p.id_profesional,
    p.nombre as nombre_profesional,
    p.slug_publico,
    n.nombre_negocio,
    n.slug as slug_negocio,
    n.zona_horaria,
    s.id_servicio,
    s.nombre as nombre_servicio,
    s.duracion_minutos,
    s.precio,
    s.color
FROM profesionales p
JOIN negocios n ON p.id_negocio = n.id_negocio
LEFT JOIN servicios s ON (s.id_profesional = p.id_profesional OR s.id_negocio = n.id_negocio)
WHERE p.activo = TRUE AND s.activo = TRUE;