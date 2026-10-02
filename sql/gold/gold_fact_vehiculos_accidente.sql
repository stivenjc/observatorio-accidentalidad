CREATE OR REPLACE TABLE `fullproject-510120.gold.fact_vehiculos_accidente` AS
SELECT
  fecha_accidente               AS fecha,
  direccion_accidente,
  clase_accidente,
  servicio_vehiculo_accidentado AS servicio,
  clase_vehiculo_accidentado    AS clase_vehiculo,
  cantidad_accidentes           AS vehiculos_involucrados
FROM `fullproject-510120.silver.accidentalidad`