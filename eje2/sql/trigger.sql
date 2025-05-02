CREATE TRIGGER trg_insert_alerta_on_evento
ON "eventos"
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO "alertas" ("empleado_id", "evento_id", "fecha_creacion")
    SELECT
        V."empleado_id",         -- Obtenemos el empleado_id desde el vehículo asociado a la ruta
        I."evento_id",           -- id_evento recién insertado
        GETDATE()                -- fecha actual del servidor
    FROM
        INSERTED I
    INNER JOIN "rutas" R ON R."ruta_id" = I."ruta_id"
    INNER JOIN "vehiculos" V ON V."vehiculo_id" = R."vehiculo_id";
END;


CREATE TRIGGER trg_cambio_estado_ruta
ON "rutas"
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON; -- NO MUESTRE LAS TABLAS ALTERADAS

	DECLARE @estado_id INT = (SELECT estado_id FROM inserted);
  DECLARE @ruta_id INT = (SELECT ruta_id FROM inserted);
  DECLARE @vehiculo_id INT = (SELECT vehiculo_id FROM rutas WHERE ruta_id = @ruta_id);
  DECLARE @empleado_id INT = (SELECT empleado_id FROM vehiculos WHERE vehiculo_id = @vehiculo_id);
  DECLARE @persona_id CHAR(10) = (SELECT persona_id FROM empleados WHERE empleado_id = @empleado_id)

  IF @estado_id = 27 OR @estado_id = 28 or @estado_id = 31
    BEGIN
      UPDATE vehiculos SET estado_id = 3
      WHERE vehiculos.vehiculo_id = @vehiculo_id;

      UPDATE personas SET estado_id = 1
      WHERE personas.cedula = @persona_id;
    END
  ELSE IF @estado_id = 26 OR @estado_id = 29 OR @estado_id = 30
  	BEGIN
    	UPDATE vehiculos SET estado_id = 7
      WHERE vehiculos.vehiculo_id = @vehiculo_id;

      UPDATE personas SET estado_id = 7
      WHERE personas.cedula = @persona_id;
    END
  ELSE IF @estado_id = 25
  	BEGIN
      UPDATE vehiculos SET estado_id = 12
      WHERE vehiculos.vehiculo_id = @vehiculo_id;

      UPDATE personas SET estado_id = 12
      WHERE personas.cedula = @persona_id;
  	END
END;
