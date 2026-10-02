CREATE OR REPLACE TABLE `fullproject-510120.gold.dim_fecha` AS
WITH rango AS (
  SELECT MIN(fecha_accidente) AS fecha_min, MAX(fecha_accidente) AS fecha_max
  FROM `fullproject-510120.silver.accidentalidad`
),
calendario AS (
  SELECT fecha, fecha_max
  FROM rango, UNNEST(GENERATE_DATE_ARRAY(fecha_min, fecha_max)) AS fecha
),
base AS (
  SELECT
    fecha,
    fecha_max,
    EXTRACT(YEAR FROM fecha)    AS anio,
    EXTRACT(QUARTER FROM fecha) AS trimestre,
    EXTRACT(MONTH FROM fecha)   AS mes,
    EXTRACT(DAY FROM fecha)     AS dia_del_mes,
    CAST(FORMAT_DATE('%u', fecha) AS INT64) AS dia_semana
  FROM calendario
)
SELECT
  fecha,
  anio,
  trimestre,
  mes,
  ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto',
   'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'][OFFSET(mes - 1)] AS nombre_mes,
  dia_del_mes,
  dia_semana,
  ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']
    [OFFSET(dia_semana - 1)] AS nombre_dia,
  dia_semana >= 6 AS es_fin_de_semana,
  fecha_max >= DATE(anio, 12, 31) AS es_anio_completo
FROM base