SELECT
  fecha_accidente               AS fecha,
  direccion_accidente,
  clase_accidente,
  servicio_vehiculo_accidentado AS servicio,
  clase_vehiculo_accidentado    AS clase_vehiculo,
  cantidad_accidentes           AS vehiculos_involucrados
FROM {{ ref('accidentalidad') }}