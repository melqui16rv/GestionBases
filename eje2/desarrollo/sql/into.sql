-- INSERT TABLA ESTADOS
INSERT INTO estados (nombre, descripcion) VALUES
('Activo', 'Registro activo en el sistema'),
('Inactivo', 'Registro inactivo en el sistema');

-- Estados adicionales para vehículos
INSERT INTO estados (nombre, descripcion) VALUES
('Disponible', 'Vehículo disponible para asignar a una ruta o un empleado'),
('En reparación', 'Vehículo en taller para reparaciones'),
('Dañado', 'Vehículo con daños que impiden su uso'),
('En inspección', 'Vehículo en proceso de inspección técnica'),
('En ruta', 'Vehículo o empleado actualmente en ruta'),
('En pico y placa', 'Vehículo restringido por normativa de circulación'),
('En préstamo', 'Vehículo asignado temporalmente a otra entidad'),
('En limpieza', 'Vehículo en proceso de limpieza y desinfección'),
('Sin combustible', 'Vehículo no disponible por falta de combustible'),
('Reservado', 'Vehículo y persona asignado para una ruta futura'),
('Baja técnica', 'Vehículo fuera de servicio por problemas mecánicos'),
('En proceso de baja', 'Vehículo en trámite de ser dado de baja del sistema'),
('Secuestrado', 'Vehículo retenido por orden judicial'),
('En robo', 'Vehículo reportado como robado'),
('En garantía', 'Vehículo en taller por reclamo de garantía'),
('Sin documentación', 'Vehículo sin papeles al día');

-- Estados adicionales para personas/empleados
INSERT INTO estados (nombre, descripcion) VALUES
('En vacaciones', 'Empleado en período vacacional'),
('En permiso', 'Empleado con permiso temporal'),
('Licencia médica', 'Empleado con licencia por enfermedad'),
('Capacitación', 'Empleado en proceso de capacitación'),
('En asignación', 'Empleado asignado a vehículo reservado para ruta futura'),
('En espera', 'Empleado en espera de inicio de ruta');

-- Estados adicionales para rutas
INSERT INTO estados (nombre, descripcion) VALUES
('Programada', 'Ruta programada pero no iniciada'),
('En progreso', 'Ruta actualmente en ejecución'),
('Completada', 'Ruta finalizada exitosamente'),
('Cancelada', 'Ruta cancelada antes o durante su ejecución'),
('Retrasada', 'Ruta con retraso en su horario previsto'),
('En emergencia', 'Ruta con situación de emergencia reportada'),
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
('Camión', 'ABC123', 3, 'Blanco', 1),  -- Disponible (3)
('Furgoneta', 'DEF456', 3, 'Azul', 2),   -- Disponible (3)
('Pickup', 'GHI789', 4, 'Rojo', 3),      -- En reparación (4)
('Camioneta', 'JKL012', 3, 'Negro', 4),  -- Disponible (3)
('Trailer', 'MNO345', 6, 'Verde', 5);    -- En inspección (6)

-- INSERT TABLA RUTAS
INSERT INTO rutas (origen, destino, nivel_riesgo_id, vehiculo_id, estado_id) VALUES
('Quito', 'Guayaquil', 2, 1, 15),  -- Programada (15)
('Guayaquil', 'Cuenca', 1, 2, 15),  -- Programada (15)
('Cuenca', 'Manta', 3, 3, 16),  -- En progreso (16)
('Manta', 'Esmeraldas', 4, 4, 15),  -- Programada (15)
('Esmeraldas', 'Quito', 2, 5, 15);  -- Programada (15)

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
