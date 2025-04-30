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
