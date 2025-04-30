-- Insertar en estados (requisito para personas y vehiculos)
INSERT INTO "estados" ("nombre", "descripcion")
VALUES ('Activo', 'Registro activo en el sistema');

-- Insertar en cargos
INSERT INTO "cargos" ("nombre", "descripcion")
VALUES ('Conductor', 'Encargado de conducir el vehículo');

-- Insertar en niveles_riesgo
INSERT INTO "niveles_riesgo" ("nombre", "descripcion")
VALUES ('Alto', 'Ruta con alto nivel de riesgo');

-- Insertar en personas
-- Nota: La contraseña se inserta como varbinary, en un caso real debería estar hasheada
INSERT INTO "personas" ("cedula", "nombre", "apellido", "telefono", "correo", "contrasena", "estado_id")
VALUES ('1234567890', 'Juan', 'Pérez', '3000000000', 'juan@example.com', 0x123456, 1);

-- Insertar en empleados
-- Nota: El empleado_id es identity, no necesitamos especificarlo
INSERT INTO "empleados" ("persona_id", "cargo_id")
VALUES ('1234567890', 1);

-- Insertar en vehiculos
INSERT INTO "vehiculos" ("tipo", "placa", "estado_id", "color", "empleado_id")
VALUES ('Camión', 'ABC123', 1, 'Rojo', 1);

-- Insertar en rutas
INSERT INTO "rutas" ("origen", "destino", "nivel_riesgo_id", "vehiculo_id")
VALUES ('Bogotá', 'Cali', 1, 1);

-- Verificar que Ruta se creó
SELECT * FROM "rutas";

-- Insertar en eventos (esto debe disparar el trigger y crear una alerta)
INSERT INTO "eventos" ("tipo", "ruta_id", "nombre", "descripcion")
VALUES ('Accidente', 1, 'Choque en vía', 'Se reporta choque en la ruta Bogotá-Cali');

-- Verificar que se generó una alerta
SELECT * FROM "alertas";
