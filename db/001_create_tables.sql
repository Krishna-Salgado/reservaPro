
--NOTA: todo tiene IF NOT EXISTS para evitar errores de idempotencia y que no se muera cuando lo corra denuevo

-- Simulacion local de SUPABASE AUTH (para prueba en Docker)
CREATE TABLE IF NOT EXISTS auth_users(
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAUlT NOW()
);

-- Tabla Profesionales
CREATE TABLE IF NOT EXISTS profesionales(
    id_profesional UUID PRIMARY KEY REFERENCES auth_users(id) ON DELETE CASCADE,
    -- REFERENCES: es la integridad referencial FK, los valores ya existen en la tabla auth.users restringe la creacion de id que no existan en auth
    -- es una copia por decirlo
    --ON DELETE CASCADE : si algo se borra en auth_users tambien se borra aca 'automaticamente'
    slug VARCHAR(100) UNIQUE NOT NULL,
    tipo_plan VARCHAR(20) NOT NULL DEFAULT 'gratis' CHECK (tipo_plan IN ('gratis', 'pro', 'negocio')),
    --CHECK : es una restriccion de comprobacion
    -- IN() : van las opciones posibles que comprueba el CHECK, no se puede agregar nada que no este en el in() o da error
    zona_horaria VARCHAR(50) NOT NULL DEFAULT 'America/Santiago',
    creado_en TIMESTAMPTZ DEFAULT NOW() -- la fecha hora en UTC
);

-- tabla servicios
CREATE TABLE IF NOT EXISTS servicios(
    id_servicio UUID PRIMARY KEY DEFAUlT gen_random_uuid(),
    --FK de id_profesional
    id_profesional UUID NOT NULL REFERENCES profesionales(id_profesional) ON DELETE CASCADE,
    nombre VARCHAR(100) NOT NULL,
    duracion_minutos INTEGER NOT NULL CHECK (duracion_minutos > 0),--se comprueba que los minutos >0
    precio NUMERIC(10,2) --para precios es mas preciso no como float
);


--tabla reglas_disponibilidad
CREATE TABLE IF NOT EXISTS reglas_disponibilidad (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_profesional UUID NOT NULL REFERENCES profesionales(id_profesional) ON DELETE CASCADE,
    dia_semana SMALLINT NOT NULL CHECK (dia_semana >= 0 AND dia_semana <= 6),
    -- 0= domingo, 1=lunes ...
    --SMALLINT: un INT de 2bytes
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CONSTRAINT horas_coherentes CHECK (hora_fin > hora_inicio)
);

-- tabla citas
CREATE TABLE IF NOT EXISTS citas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_profesional UUID NOT NULL REFERENCES profesionales(id_profesional) ON DELETE CASCADE,
    id_servicio UUID NOT NULL REFERENCES servicios(id_servicio) ON DELETE RESTRICT,
    --si se quiere borrar servicios pero hay citas no se borra
    nombre_cliente VARCHAR(100) NOT NULL,
    email_cliente VARCHAR(255) NOT NULL,
    telefono_cliente VARCHAR(20),
    hora_inicio TIMESTAMPTZ NOT NULL,
    hora_fin TIMESTAMPTZ NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'confirmada', 'cancelada')),
    
    -- REGLA CRITICA: Prevención de Double Booking a nivel de Base de Datos
    CONSTRAINT evitar_double_booking UNIQUE (id_profesional, hora_inicio)
);
--indices (cusquedas comunes)
CREATE INDEX IF NOT EXISTS idx_citas_profesional_fecha ON citas(id_profesional, hora_inicio);
CREATE INDEX IF NOT EXISTS idx_servicios_profesional ON servicios(id_profesional);