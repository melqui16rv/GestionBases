SELECT
    A."alerta_id",
    A."fecha_creacion" AS "Fecha",
    E."evento_id",
    E."tipo" AS "Tipo_Evento",
    E."nombre" AS "Nombre_Evento",
    E."descripcion" AS "Descripcion_Evento",
    R."ruta_id",
    R."origen",
    R."destino",
    NR."nombre" AS "nivel_riesgo",
    V."vehiculo_id",
    V."tipo" AS "Tipo_Vehiculo",
    V."placa",
    V."color",
    P."cedula",
    P."nombre" AS "Nombre_Empleado",
    P."apellido" AS "Apellido",
    P."telefono",
    P."correo"
FROM
    "alertas" A
INNER JOIN "eventos" E ON A."evento_id" = E."evento_id"
INNER JOIN "rutas" R ON E."ruta_id" = R."ruta_id"
INNER JOIN "niveles_riesgo" NR ON R."nivel_riesgo_id" = NR."nivel_riesgo_id"
INNER JOIN "vehiculos" V ON R."vehiculo_id" = V."vehiculo_id"
INNER JOIN "empleados" EM ON A."empleado_id" = EM."empleado_id"
INNER JOIN "personas" P ON EM."persona_id" = P."cedula"
WHERE A."alerta_id" = 1;
