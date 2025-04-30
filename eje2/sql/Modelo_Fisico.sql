-- Crear base de datos
CREATE DATABASE "seguridad_logistica";

-- Seleccionar la base de datos
USE "seguridad_logistica";

-- Creación tabla estado
CREATE TABLE "estados" (
    "estado_id" INT IDENTITY(1,1) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL,
    "descripcion" VARCHAR(255) NULL
);
ALTER TABLE
    "estados" ADD CONSTRAINT "pk_estados" PRIMARY KEY("estado_id");

-- Creación tabla persona
CREATE TABLE "personas" (
    "cedula" CHAR(10) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL,
    "apellido" VARCHAR(55) NOT NULL,
    "telefono" VARCHAR(25) NOT NULL,
    "correo" VARCHAR(100) NOT NULL,
    "contrasena" VARBINARY(MAX) NOT NULL,
    "estado_id" INT NOT NULL
);
ALTER TABLE
    "personas" ADD CONSTRAINT "pk_personas" PRIMARY KEY("cedula");
CREATE UNIQUE INDEX "idx_personas_correo_unique" ON
    "personas"("correo");

-- Creación tabla cargo
CREATE TABLE "cargos" (
    "cargo_id" INT IDENTITY(1,1) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL,
    "descripcion" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "cargos" ADD CONSTRAINT "pk_cargos" PRIMARY KEY("cargo_id");

-- Creación tabla empleado
CREATE TABLE "empleados" (
    "empleado_id" INT IDENTITY(1,1) NOT NULL,
    "persona_id" CHAR(10) NOT NULL,
    "cargo_id" INT NOT NULL
);
ALTER TABLE
    "empleados" ADD CONSTRAINT "pk_empleados" PRIMARY KEY("empleado_id");
CREATE UNIQUE INDEX "idx_empleados_persona_unique" ON "empleados"("persona_id");

-- Creación tabla vehiculo
CREATE TABLE "vehiculos" (
    "vehiculo_id" INT IDENTITY(1,1) NOT NULL,
    "tipo" VARCHAR(55) NOT NULL,
    "placa" CHAR(6) NOT NULL,
    "estado_id" INT NOT NULL,
    "color" VARCHAR(55) NOT NULL,
    "empleado_id" INT NOT NULL
);
ALTER TABLE
    "vehiculos" ADD CONSTRAINT "pk_vehiculos" PRIMARY KEY("vehiculo_id");
CREATE UNIQUE INDEX "idx_vehiculos_placa_unique" ON
    "vehiculos"("placa");

-- Creación tabla nivel_riesgo
CREATE TABLE "niveles_riesgo" (
    "nivel_riesgo_id" INT IDENTITY(1,1) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL,
    "descripcion" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "niveles_riesgo" ADD CONSTRAINT "pk_niveles_riesgo" PRIMARY KEY("nivel_riesgo_id");

-- Creación tabla ruta
CREATE TABLE "rutas" (
    "ruta_id" INT IDENTITY(1,1) NOT NULL,
    "origen" VARCHAR(255) NOT NULL,
    "destino" VARCHAR(255) NOT NULL,
    "nivel_riesgo_id" INT NOT NULL,
    "vehiculo_id" INT NOT NULL
);
ALTER TABLE
    "rutas" ADD CONSTRAINT "pk_rutas" PRIMARY KEY("ruta_id");
CREATE INDEX "idx_rutas_nivel_riesgo" ON "rutas"("nivel_riesgo_id");

-- Creación tabla evento
CREATE TABLE "eventos" (
    "evento_id" INT IDENTITY(1,1) NOT NULL,
    "tipo" VARCHAR(55) NOT NULL,
    "ruta_id" INT NOT NULL,
    "nombre" VARCHAR(55) NOT NULL,
    "descripcion" TEXT NOT NULL
);
ALTER TABLE
    "eventos" ADD CONSTRAINT "pk_eventos" PRIMARY KEY("evento_id");

-- Creación tabla alerta
CREATE TABLE "alertas" (
    "alerta_id" INT IDENTITY(1,1) NOT NULL,
    "empleado_id" INT NOT NULL,
    "evento_id" INT NOT NULL,
    "fecha_creacion" DATETIME2 NOT NULL
);
ALTER TABLE
    "alertas" ADD CONSTRAINT "pk_alertas" PRIMARY KEY("alerta_id");

-- Creación tabla rol
CREATE TABLE "roles" (
    "rol_id" INT IDENTITY(1,1) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL,
    "descripcion" VARCHAR(255) NOT NULL,
    "persona_id" CHAR(10) NOT NULL
);
ALTER TABLE
    "roles" ADD CONSTRAINT "pk_roles" PRIMARY KEY("rol_id");

-- Creación tabla tipo_acceso
CREATE TABLE "tipos_acceso" (
    "tipo_acceso_id" INT IDENTITY(1,1) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL,
    "descripcion" VARCHAR(255) NOT NULL
);
ALTER TABLE
    "tipos_acceso" ADD CONSTRAINT "pk_tipos_acceso" PRIMARY KEY("tipo_acceso_id");

-- Creación tabla tipo_accion
CREATE TABLE "tipos_accion" (
    "tipo_accion_id" INT IDENTITY(1,1) NOT NULL,
    "nombre" VARCHAR(55) NOT NULL
);
ALTER TABLE
    "tipos_accion" ADD CONSTRAINT "pk_tipos_accion" PRIMARY KEY("tipo_accion_id");

-- Creación tabla historial_acceso
CREATE TABLE "historiales_acceso" (
    "historial_acceso_id" INT IDENTITY(1,1) NOT NULL,
    "fecha" DATETIME2 NOT NULL,
    "direccion_ip" VARCHAR(55) NOT NULL,
    "tipo_acceso_id" INT NOT NULL,
    "persona_id" CHAR(10) NOT NULL,
    "estado_id" INT NOT NULL,
    "tipo_accion_id" INT NOT NULL
);
ALTER TABLE
    "historiales_acceso" ADD CONSTRAINT "pk_historiales_acceso" PRIMARY KEY("historial_acceso_id");

-- Creación tabla rol_tipo_acceso
CREATE TABLE "roles_tipos_acceso" (
    "rol_tipo_acceso_id" INT IDENTITY(1,1) NOT NULL,
    "tipo_acceso_id" INT NOT NULL,
    "rol_id" INT NOT NULL
);
ALTER TABLE
    "roles_tipos_acceso" ADD CONSTRAINT "pk_roles_tipos_acceso" PRIMARY KEY("rol_tipo_acceso_id");

-- Creación de relaciones (foreign keys)
ALTER TABLE "vehiculos"
    ADD CONSTRAINT "fk_vehiculos_estado"
    FOREIGN KEY("estado_id") REFERENCES "estados"("estado_id")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "vehiculos"
    ADD CONSTRAINT "fk_vehiculos_empleado"
    FOREIGN KEY("empleado_id") REFERENCES "empleados"("empleado_id")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "roles_tipos_acceso"
    ADD CONSTRAINT "fk_roles_tipos_acceso_tipo"
    FOREIGN KEY("tipo_acceso_id") REFERENCES "tipos_acceso"("tipo_acceso_id")
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "empleados"
    ADD CONSTRAINT "fk_empleados_cargo"
    FOREIGN KEY("cargo_id") REFERENCES "cargos"("cargo_id")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "alertas"
    ADD CONSTRAINT "fk_alertas_evento"
    FOREIGN KEY("evento_id") REFERENCES "eventos"("evento_id")
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "historiales_acceso"
    ADD CONSTRAINT "fk_historiales_acceso_persona"
    FOREIGN KEY("persona_id") REFERENCES "personas"("cedula")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "rutas"
    ADD CONSTRAINT "fk_rutas_vehiculo"
    FOREIGN KEY("vehiculo_id") REFERENCES "vehiculos"("vehiculo_id")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "rutas"
    ADD CONSTRAINT "fk_rutas_nivel_riesgo"
    FOREIGN KEY("nivel_riesgo_id") REFERENCES "niveles_riesgo"("nivel_riesgo_id")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "historiales_acceso"
    ADD CONSTRAINT "fk_historiales_acceso_tipo_acceso"
    FOREIGN KEY("tipo_acceso_id") REFERENCES "tipos_acceso"("tipo_acceso_id")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "roles_tipos_acceso"
    ADD CONSTRAINT "fk_roles_tipos_acceso_rol"
    FOREIGN KEY("rol_id") REFERENCES "roles"("rol_id")
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "personas"
    ADD CONSTRAINT "fk_personas_estado"
    FOREIGN KEY("estado_id") REFERENCES "estados"("estado_id")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "historiales_acceso"
    ADD CONSTRAINT "fk_historiales_acceso_tipo_accion"
    FOREIGN KEY("tipo_accion_id") REFERENCES "tipos_accion"("tipo_accion_id")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "roles"
    ADD CONSTRAINT "fk_roles_persona"
    FOREIGN KEY("persona_id") REFERENCES "personas"("cedula")
    ON DELETE NO ACTION ON UPDATE NO ACTION;

ALTER TABLE "eventos"
    ADD CONSTRAINT "fk_eventos_ruta"
    FOREIGN KEY("ruta_id") REFERENCES "rutas"("ruta_id")
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "empleados"
    ADD CONSTRAINT "fk_empleados_persona"
    FOREIGN KEY("persona_id") REFERENCES "personas"("cedula")
    ON DELETE NO ACTION ON UPDATE NO ACTION;
