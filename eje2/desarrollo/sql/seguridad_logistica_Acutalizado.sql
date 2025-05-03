CREATE DATABASE seguridad_logistica;

USE seguridad_logistica;

CREATE TABLE "Empleado"(
    "id_empleado" INT IDENTITY(1,1) NOT NULL,
    "id_persona" CHAR(10) NOT NULL,
    "id_cargo" INT NOT NULL
);
ALTER TABLE
    "Empleado" ADD CONSTRAINT "empleado_id_empleado_primary" PRIMARY KEY("id_empleado");



CREATE TABLE "Persona"(
    "Cedula" CHAR(10) NOT NULL,
    "Nombre" VARCHAR(55) NOT NULL,
    "Apellido" VARCHAR(55) NOT NULL,
    "Telefono" VARCHAR(25) NOT NULL,
    "Correo" VARCHAR(100) NOT NULL,
    "Contrseña" VARBINARY(MAX) NOT NULL,
    "id_estado" INT NOT NULL
);
ALTER TABLE
    "Persona" ADD CONSTRAINT "persona_cedula_primary" PRIMARY KEY("Cedula");
CREATE UNIQUE INDEX "persona_correo_unique" ON
    "Persona"("Correo");


CREATE TABLE "Cargo"(
    "id_cargo" INT IDENTITY(1,1) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL,
    "descripcion" VARCHAR(55) NOT NULL
);
ALTER TABLE
    "Cargo" ADD CONSTRAINT "cargo_id_cargo_primary" PRIMARY KEY("id_cargo");


CREATE TABLE "Vehiculo"(
    "id_vehiculo" INT IDENTITY(1,1) NOT NULL,
    "tipo" VARCHAR(55) NOT NULL,
    "placa" CHAR(6) NOT NULL,
    "id_estado" INT NOT NULL,
    "color" CHAR(55) NOT NULL,
    "id_empleado" INT NOT NULL
);
ALTER TABLE
    "Vehiculo" ADD CONSTRAINT "vehiculo_id_vehiculo_primary" PRIMARY KEY("id_vehiculo");
CREATE UNIQUE INDEX "vehiculo_placa_unique" ON
    "Vehiculo"("placa");


CREATE TABLE "Evento"(
    "id_evento" INT IDENTITY(1,1) NOT NULL,
    "Tipo" VARCHAR(55) NOT NULL,
    "id_ruta" INT NOT NULL,
    "Nombre" VARCHAR(55) NOT NULL,
    "Descripcion" TEXT NOT NULL
);
ALTER TABLE
    "Evento" ADD CONSTRAINT "evento_id_evento_primary" PRIMARY KEY("id_evento");


CREATE TABLE "Alerta"(
    "id_alerta" INT IDENTITY(1,1) NOT NULL,
    "id_empleado" INT NOT NULL,
    "id_evento" INT NOT NULL,
    "Fecha" DATETIME NOT NULL
);
ALTER TABLE
    "Alerta" ADD CONSTRAINT "alerta_id_alerta_primary" PRIMARY KEY("id_alerta");


CREATE TABLE "Estado"(
    "id_estado" INT IDENTITY(1,1) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL
);
ALTER TABLE
    "Estado" ADD CONSTRAINT "estado_id_estado_primary" PRIMARY KEY("id_estado");


CREATE TABLE "Rol"(
    "id_rol" INT IDENTITY(1,1) NOT NULL,
    "Nombre" VARCHAR(55) NOT NULL,
    "Descripcion" VARCHAR(255) NOT NULL,
    "id_persona" CHAR(10) NOT NULL,
    "id_tipoAcceso" INT NOT NULL
);
ALTER TABLE
    "Rol" ADD CONSTRAINT "rol_id_rol_primary" PRIMARY KEY("id_rol");


CREATE TABLE "TipoAcceso"(
    "id_tipoAcceso" INT IDENTITY(1,1) NOT NULL,
    "Nombre" VARCHAR(55) NOT NULL,
    "Descripcion" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "TipoAcceso" ADD CONSTRAINT "tipoacceso_id_tipoacceso_primary" PRIMARY KEY("id_tipoAcceso");


CREATE TABLE "HistorialAcceso"(
    "id_historialAcceso" INT IDENTITY(1,1) NOT NULL,
    "fecha" DATETIME2 NOT NULL,
    "ip" VARCHAR(55) NOT NULL,
    "id_tipoAcceso" INT NOT NULL,
    "id_persona" CHAR(10) NOT NULL,
    "id_estado" INT NOT NULL,
    "id_tipoAccion" INT NOT NULL
);
ALTER TABLE
    "HistorialAcceso" ADD CONSTRAINT "historialacceso_id_historialacceso_primary" PRIMARY KEY("id_historialAcceso");


CREATE TABLE "Ruta"(
    "id_ruta" INT IDENTITY(1,1) NOT NULL,
    "Origen" VARCHAR(255) NOT NULL,
    "Destino" VARCHAR(255) NOT NULL,
    "nivelRiesgo" VARCHAR(55) NOT NULL,
    "id_vehiculo" INT NOT NULL,
    "id_empleado" INT NOT NULL
);
ALTER TABLE
    "Ruta" ADD CONSTRAINT "ruta_id_ruta_primary" PRIMARY KEY("id_ruta");
CREATE TABLE "rolTipoAcceso"(
    "id_rolTipoAcceso" INT IDENTITY(1,1) NOT NULL,
    "id_tipoAcceso" INT NOT NULL,
    "id_rol" INT NOT NULL
);
ALTER TABLE
    "rolTipoAcceso" ADD CONSTRAINT "roltipoacceso_id_roltipoacceso_primary" PRIMARY KEY("id_rolTipoAcceso");
CREATE TABLE "tipoAccion"(
    "id_tipoAccion" INT IDENTITY(1,1) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL
);
ALTER TABLE
    "tipoAccion" ADD CONSTRAINT "tipoaccion_id_tipoaccion_primary" PRIMARY KEY("id_tipoAccion");


ALTER TABLE
    "Vehiculo" ADD CONSTRAINT "vehiculo_id_estado_foreign" FOREIGN KEY("id_estado") REFERENCES "Estado"("id_estado");
ALTER TABLE
    "Vehiculo" ADD CONSTRAINT "vehiculo_id_empleado_foreign" FOREIGN KEY("id_empleado") REFERENCES "Empleado"("id_empleado");
ALTER TABLE
    "rolTipoAcceso" ADD CONSTRAINT "roltipoacceso_id_tipoacceso_foreign" FOREIGN KEY("id_tipoAcceso") REFERENCES "TipoAcceso"("id_tipoAcceso");
ALTER TABLE
    "Empleado" ADD CONSTRAINT "empleado_id_cargo_foreign" FOREIGN KEY("id_cargo") REFERENCES "Cargo"("id_cargo");
ALTER TABLE
    "Alerta" ADD CONSTRAINT "alerta_id_evento_foreign" FOREIGN KEY("id_evento") REFERENCES "Evento"("id_evento");
ALTER TABLE
    "HistorialAcceso" ADD CONSTRAINT "historialacceso_id_persona_foreign" FOREIGN KEY("id_persona") REFERENCES "Persona"("Cedula");
ALTER TABLE
    "Ruta" ADD CONSTRAINT "ruta_id_vehiculo_foreign" FOREIGN KEY("id_vehiculo") REFERENCES "Vehiculo"("id_vehiculo");
ALTER TABLE
    "HistorialAcceso" ADD CONSTRAINT "historialacceso_id_tipoacceso_foreign" FOREIGN KEY("id_tipoAcceso") REFERENCES "TipoAcceso"("id_tipoAcceso");
ALTER TABLE
    "rolTipoAcceso" ADD CONSTRAINT "roltipoacceso_id_rol_foreign" FOREIGN KEY("id_rol") REFERENCES "Rol"("id_rol");
ALTER TABLE
    "Persona" ADD CONSTRAINT "persona_id_estado_foreign" FOREIGN KEY("id_estado") REFERENCES "Estado"("id_estado");
ALTER TABLE
    "HistorialAcceso" ADD CONSTRAINT "historialacceso_id_tipoaccion_foreign" FOREIGN KEY("id_tipoAccion") REFERENCES "tipoAccion"("id_tipoAccion");
ALTER TABLE
    "Rol" ADD CONSTRAINT "rol_id_persona_foreign" FOREIGN KEY("id_persona") REFERENCES "Persona"("Cedula");
ALTER TABLE
    "Evento" ADD CONSTRAINT "evento_id_ruta_foreign" FOREIGN KEY("id_ruta") REFERENCES "Ruta"("id_ruta");
ALTER TABLE
    "Empleado" ADD CONSTRAINT "empleado_id_persona_foreign" FOREIGN KEY("id_persona") REFERENCES "Persona"("Cedula");