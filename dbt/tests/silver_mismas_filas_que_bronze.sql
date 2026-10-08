SELECT *
FROM (
  SELECT
    (SELECT COUNT(*) FROM {{ source('bronze', 'accidentalidad_raw') }}) AS filas_bronze,
    (SELECT COUNT(*) FROM {{ ref('accidentalidad') }}) AS filas_silver
)
WHERE filas_bronze != filas_silver