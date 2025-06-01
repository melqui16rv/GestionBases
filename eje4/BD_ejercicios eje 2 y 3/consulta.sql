SELECT 
    A."id_alerta",
    A."Fecha",
    E."id_evento",
    E."Tipo" AS "Tipo_Evento",
    E."Nombre" AS "Nombre_Evento",
    E."Descripcion" AS "Descripcion_Evento",
    R."id_ruta",
    R."Origen",
    R."Destino",
    R."nivelRiesgo",
    V."id_vehiculo",
    V."tipo" AS "Tipo_Vehiculo",
    V."placa",
    V."color",
    P."Cedula",
    P."Nombre" AS "Nombre_Empleado",
    P."Apellido",
    P."Telefono",
    P."Correo"
FROM 
    "Alerta" A
INNER JOIN "Evento" E ON A."id_evento" = E."id_evento"
INNER JOIN "Ruta" R ON E."id_ruta" = R."id_ruta"
INNER JOIN "Vehiculo" V ON R."id_vehiculo" = V."id_vehiculo"
INNER JOIN "Empleado" EM ON A."id_empleado" = EM."id_empleado"
INNER JOIN "Persona" P ON EM."id_persona" = P."Cedula"
WHERE A."id_alerta" = 1;