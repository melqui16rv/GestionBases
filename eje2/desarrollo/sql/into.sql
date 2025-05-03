-- Insertar en Estado (requisito para Persona y Vehiculo)
INSERT INTO "Estado" ("nombre") VALUES ('Activo');

-- Insertar en Persona
INSERT INTO "Persona" ("Cedula", "Nombre", "Apellido", "Telefono", "Correo", "Contrseña", "id_estado")
VALUES ('1234567890', 'Juan', 'Pérez', '3000000000', 'juan@example.com', 0x123456, 1);

-- Insertar en Cargo
INSERT INTO "Cargo" ("nombre", "descripcion")
VALUES ('Conductor', 'Encargado de conducir el vehículo');

-- Insertar en Empleado
INSERT INTO "Empleado" ("id_persona", "id_cargo")
VALUES ('1234567890', 1);

-- Insertar en Vehiculo
INSERT INTO "Vehiculo" ("tipo", "placa", "id_estado", "color", "id_empleado")
VALUES ('Camión', 'ABC123', 1, 'Rojo', 1);

-- Insertar en Ruta
INSERT INTO "Ruta" ("Origen", "Destino", "nivelRiesgo", "id_vehiculo", "id_empleado")
VALUES ('Bogotá', 'Cali', 'Alto', 1, 1);

-- Verificar que Ruta se creó
SELECT * FROM "Ruta";

-- Insertar en Evento (esto debe disparar el trigger y crear una alerta)
INSERT INTO "Evento" ("Tipo", "id_ruta", "Nombre", "Descripcion")
VALUES ('Accidente', 1, 'Choque en vía', 'Se reporta choque en la ruta Bogotá-Cali');

-- Verificar que se generó una alerta
SELECT * FROM "Alerta";