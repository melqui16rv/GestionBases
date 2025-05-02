SELECT * FROM visualizar_alertas;

SELECT * FROM visualizar_rutas;

SELECT * FROM estados;

EXEC visualizar_rutas_estado 4;

SELECT
	R.estado_id AS estado_ruta,
  ER.nombre AS estado_nombre_ruta,
  V.estado_id AS estado_vehiculo,
  EV.nombre AS estado_nombre_vehiculo,
  P.estado_id AS estado_persona,
  EP.nombre estado_nombre_persona
FROM
	rutas R
INNER JOIN estados ER ON R.estado_id = ER.estado_id
INNER JOIN vehiculos V ON R.vehiculo_id = V.vehiculo_id
INNER JOIN estados EV ON V.estado_id = EV.estado_id
INNER JOIN empleados E ON V.empleado_id = E.empleado_id
INNER JOIN personas P ON E.persona_id = P.cedula
INNER JOIN estados EP ON P.estado_id = EP.estado_id
WHERE R.ruta_id = 4;


UPDATE rutas SET estado_id = 28
WHERE rutas.ruta_id = 4;
