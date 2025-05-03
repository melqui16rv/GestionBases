CREATE OR ALTER PROCEDURE visualizar_rutas_estado
    @estado INT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @variable_local INT = @estado;

        SELECT
          P."nombre",
          P."apellido",
          p."correo",
          C."nombre" AS "nombre_cargo",
          V."tipo" AS "tipo_vehiculo",
          V."placa",
          EV."nombre" AS "estado_vehiculo",
          R."origen",
          R."destino",
          NR."nombre" AS "riesgo_ruta",
          ER."nombre" AS "estado_ruta"
        FROM
            "rutas" R
        INNER JOIN "vehiculos" V ON R."vehiculo_id" = V."vehiculo_id"
        INNER JOIN "empleados" E ON V."empleado_id" = E."empleado_id"
        INNER JOIN "cargos" C ON E."cargo_id" = C."cargo_id"
        INNER JOIN "personas" P ON E."persona_id" = P."cedula"
        INNER JOIN "niveles_riesgo" NR ON R."nivel_riesgo_id" = NR."nivel_riesgo_id"
        INNER JOIN "estados" EV ON V."estado_id" = EV."estado_id"
        INNER JOIN "estados" ER ON R."estado_id" = ER."estado_id";
        WHERE ET."estado_id" = @estado;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
