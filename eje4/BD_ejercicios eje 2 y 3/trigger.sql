CREATE TRIGGER trg_insert_alerta_on_evento
ON "Evento"
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO "Alerta" ("id_empleado", "id_evento", "Fecha")
    SELECT
        R."id_empleado",         -- id_empleado desde Ruta asociada al Evento insertado
        I."id_evento",           -- id_evento recién insertado
        GETDATE()                -- fecha actual del servidor
    FROM
        INSERTED I
    INNER JOIN "Ruta" R ON R."id_ruta" = I."id_ruta";
END;