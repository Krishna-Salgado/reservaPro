-- ============================================
-- SEED DATA - Peluquería Canina "Patitas Felices"
-- ============================================

-- 1. Usuario Boss
INSERT INTO auth_users (id, email, password_hash) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'boss@patitas.cl', '$2b$12$fakehash');

-- 2. Negocio
INSERT INTO negocios (id_negocio, id_boss, nombre_negocio, slug, tipo_plan, zona_horaria) VALUES
('660e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440000', 'Patitas Felices', 'patitas-felices', 'pro', 'America/Santiago');

-- 3. Profesionales (Boss + 2 empleados)
INSERT INTO profesionales (id_profesional, id_auth, id_negocio, nombre, email, slug_publico, rol) VALUES
('770e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001', 'Carlos Boss', 'boss@patitas.cl', 'carlos-boss', 'boss'),
('880e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001', 'María Groomer', 'maria@patitas.cl', 'maria-groomer', 'profesional'),
('990e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440000', '660e8400-e29b-41d4-a716-446655440001', 'Juan Baños', 'juan@patitas.cl', 'juan-banos', 'profesional');

-- 4. Servicios
INSERT INTO servicios (id_servicio, id_negocio, id_profesional, nombre, duracion_minutos, precio, color) VALUES
('aa0e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440001', NULL, 'Baño Básico', 30, 15000, '#10B981'),
('bb0e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440001', NULL, 'Baño + Corte', 60, 25000, '#6366F1'),
('cc0e8400-e29b-41d4-a716-446655440007', '660e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440003', 'Full Spa', 90, 40000, '#F59E0B');

-- 5. Disponibilidad (Lunes a Sábado, 9:00-18:00)
INSERT INTO regla_disponibilidad (id_disp, id_profesional, dia_semana, hora_inicio, hora_fin) VALUES
('dd0e8400-e29b-41d4-a716-446655440008', '770e8400-e29b-41d4-a716-446655440002', 1, '09:00', '18:00'),
('ee0e8400-e29b-41d4-a716-446655440009', '770e8400-e29b-41d4-a716-446655440002', 2, '09:00', '18:00'),
('ff0e8400-e29b-41d4-a716-44665544000a', '770e8400-e29b-41d4-a716-446655440002', 3, '09:00', '18:00'),
('110e8400-e29b-41d4-a716-44665544000b', '770e8400-e29b-41d4-a716-446655440002', 4, '09:00', '18:00'),
('220e8400-e29b-41d4-a716-44665544000c', '770e8400-e29b-41d4-a716-446655440002', 5, '09:00', '18:00'),
('330e8400-e29b-41d4-a716-44665544000d', '770e8400-e29b-41d4-a716-446655440002', 6, '09:00', '14:00');

-- María (solo martes y jueves)
INSERT INTO regla_disponibilidad (id_disp, id_profesional, dia_semana, hora_inicio, hora_fin) VALUES
('440e8400-e29b-41d4-a716-44665544000e', '880e8400-e29b-41d4-a716-446655440003', 2, '10:00', '16:00'),
('550e8400-e29b-41d4-a716-44665544000f', '880e8400-e29b-41d4-a716-446655440003', 4, '10:00', '16:00');

-- Juan (miércoles y viernes)
INSERT INTO regla_disponibilidad (id_disp, id_profesional, dia_semana, hora_inicio, hora_fin) VALUES
('660e8400-e29b-41d4-a716-446655440010', '990e8400-e29b-41d4-a716-446655440004', 3, '09:00', '17:00'),
('770e8400-e29b-41d4-a716-446655440011', '990e8400-e29b-41d4-a716-446655440004', 5, '09:00', '17:00');

-- 6. Citas de prueba (próxima semana)
INSERT INTO citas (id_cita, id_negocio, id_profesional, id_servicio, nombre_cliente, email_cliente, telefono_cliente, hora_inicio, hora_fin, estado) VALUES
('880e8400-e29b-41d4-a716-446655440012', '660e8400-e29b-41d4-a716-446655440001', '770e8400-e29b-41d4-a716-446655440002', 'aa0e8400-e29b-41d4-a716-446655440005', 'Juan Pérez', 'juan@email.com', '+56912345678', '2026-06-16 14:00:00+00', '2026-06-16 14:30:00+00', 'confirmada'),
('990e8400-e29b-41d4-a716-446655440013', '660e8400-e29b-41d4-a716-446655440001', '880e8400-e29b-41d4-a716-446655440003', 'bb0e8400-e29b-41d4-a716-446655440006', 'Ana García', 'ana@email.com', '+56987654321', '2026-06-17 10:00:00+00', '2026-06-17 11:00:00+00', 'pendiente');