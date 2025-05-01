-- INSERT TABLA ESTADOS
INSERT INTO estados (nombre, descripcion) VALUES
('Activo', 'Registro activo en el sistema'),
('Inactivo', 'Registro inactivo en el sistema'),
('En mantenimiento', 'Equipo o vehículo en mantenimiento'),
('En ruta', 'Vehículo o empleado actualmente en ruta'),
('Pendiente', 'Estado pendiente de aprobación o revisión');

-- INSERT TABLA CARGOS
INSERT INTO cargos (nombre, descripcion) VALUES
('Conductor', 'Responsable de operar vehículos de transporte'),
('Supervisor', 'Supervisa operaciones logísticas y personal'),
('Coordinador', 'Coordina rutas y asignaciones de transporte'),
('Analista', 'Analiza datos de seguridad y riesgos'),
('Administrador', 'Gestiona usuarios y configuraciones del sistema');

-- INSERT TABLA NIVELES_RIESGO
INSERT INTO niveles_riesgo (nombre, descripcion) VALUES
('Bajo', 'Ruta con riesgo mínimo, condiciones estables'),
('Moderado', 'Ruta con algunos riesgos controlables'),
('Alto', 'Ruta con riesgos significativos que requieren precaución'),
('Muy Alto', 'Ruta con peligros extremos, solo para emergencias'),
('Crítico', 'Ruta prohibida por condiciones extremadamente peligrosas');

-- INSERT TABLA TIPOS_ACCESO
INSERT INTO tipos_acceso (nombre, descripcion) VALUES
('Administrativo', 'Acceso completo a todas las funciones del sistema'),
('Operativo', 'Acceso a funciones operativas y de seguimiento'),
('Consulta', 'Acceso solo para consultar información'),
('Reportes', 'Acceso limitado a generación de reportes'),
('Monitoreo', 'Acceso a paneles de monitoreo en tiempo real');

-- INSERT TABLA PERSONAS
INSERT INTO personas (cedula, nombre, apellido, telefono, correo, contrasena, estado_id) VALUES
('1234567890', 'Juan', 'Pérez', '0991234567', 'juan.perez@empresa.com', CONVERT(VARBINARY(MAX), 'password123'), 1),
('2345678901', 'María', 'Gómez', '0987654321', 'maria.gomez@empresa.com', CONVERT(VARBINARY(MAX), 'securepass'), 1),
('3456789012', 'Carlos', 'Rodríguez', '0976543210', 'carlos.rod@empresa.com', CONVERT(VARBINARY(MAX), 'mypass123'), 1),
('4567890123', 'Ana', 'Martínez', '0965432109', 'ana.martinez@empresa.com', CONVERT(VARBINARY(MAX), 'anapass456'), 1),
('5678901234', 'Luis', 'García', '0954321098', 'luis.garcia@empresa.com', CONVERT(VARBINARY(MAX), 'luispass789'), 1);

-- INSERT TABLA EMPLEADOS
INSERT INTO empleados (persona_id, cargo_id) VALUES
('1234567890', 1),  -- Juan Pérez como Conductor
('2345678901', 2),  -- María Gómez como Supervisor
('3456789012', 3),  -- Carlos Rodríguez como Coordinador
('4567890123', 4),  -- Ana Martínez como Analista
('5678901234', 5);  -- Luis García como Administrador

-- INSERT TABLA VEHICULOS
INSERT INTO vehiculos (tipo, placa, estado_id, color, empleado_id) VALUES
('Camión', 'ABC123', 1, 'Blanco', 1),
('Furgoneta', 'DEF456', 1, 'Azul', 2),
('Pickup', 'GHI789', 3, 'Rojo', 3),
('Camioneta', 'JKL012', 1, 'Negro', 4),
('Trailer', 'MNO345', 1, 'Verde', 5);

-- INSERT TABLA RUTAS
INSERT INTO rutas (origen, destino, nivel_riesgo_id, vehiculo_id, estado_id) VALUES
('Quito', 'Guayaquil', 2, 1, 1),
('Guayaquil', 'Cuenca', 1, 2, 1),
('Cuenca', 'Manta', 3, 3, 4),
('Manta', 'Esmeraldas', 4, 4, 1),
('Esmeraldas', 'Quito', 2, 5, 1);

-- INSERT TABLA EVENTOS
INSERT INTO eventos (tipo, ruta_id, nombre, descripcion) VALUES
('Accidente', 1, 'Colisión menor', 'Choque lateral con otro vehículo sin heridos'),
('Retraso', 2, 'Demora por clima', 'Lluvias intensas retrasaron el viaje 2 horas'),
('Falla mecánica', 3, 'Sobrecalentamiento', 'Motor sobrecalentado, requiere reparación'),
('Robo', 4, 'Intento de asalto', 'Intento de robo frustrado por seguridad'),
('Ruta alternativa', 5, 'Cierre de vía', 'Derrumbe obligó a tomar ruta alternativa');

-- INSERT TABLA ROLES
INSERT INTO roles (nombre, descripcion, persona_id) VALUES
('Admin', 'Administrador del sistema con todos los permisos', '5678901234'),
('Supervisor', 'Supervisa operaciones y personal', '2345678901'),
('Conductor', 'Acceso a información de rutas y vehículos', '1234567890'),
('Analista', 'Acceso a reportes y datos históricos', '4567890123'),
('Coordinador', 'Coordina asignaciones y rutas', '3456789012');

-- INSERT TABLA ROLES_TIPOS_ACCESO
INSERT INTO roles_tipos_acceso (tipo_acceso_id, rol_id) VALUES
(1, 1),  -- Admin tiene acceso Administrativo
(2, 2),  -- Supervisor tiene acceso Operativo
(3, 3),  -- Conductor tiene acceso de Consulta
(4, 4),  -- Analista tiene acceso a Reportes
(5, 2);  -- Supervisor también tiene acceso a Monitoreo
