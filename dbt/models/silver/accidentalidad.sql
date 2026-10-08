-- =====================================================================
-- CAPA SILVER: accidentalidad (Barranquilla, detalle de vehículos)
-- =====================================================================
-- Qué hace:
--   Crea (o reemplaza) la tabla silver.accidentalidad a partir de la
--   tabla cruda bronze.accidentalidad_raw, aplicando limpieza y tipos.
--
-- Origen:  fullproject-510120.bronze.accidentalidad_raw
--          (todo en texto, tal como llegó de la API de datos.gov.co)
-- Destino: fullproject-510120.silver.accidentalidad
--
-- Requisitos:
--   - El dataset "silver" debe existir, en la misma ubicación que bronze
--     (us-central1). Se crea una sola vez, aparte de este archivo.
--
-- Comportamiento:
--   - CREATE OR REPLACE: se puede ejecutar las veces que se quiera; siempre
--     reconstruye silver completa desde bronze (idempotente).
--   - No descarta filas: silver debe tener las mismas filas que bronze
--     (51.483 en la carga inicial).
--   - Bronze nunca se modifica.
--
-- Decisiones tomadas al perfilar los datos:
--   - fecha_de_accidente viene como texto "2018-01-01T00:00:00.000",
--     siempre a medianoche -> se guarda como DATE (solo el día).
--   - cantidad_accidentes viene como texto "2.0" -> se guarda como entero.
--   - Textos: se pasan a mayúsculas y se quitan espacios sobrantes.
--   - servicio_vehiculo_accidentado tenía nulos (~2 %) -> se marcan
--     como 'SIN_DATO' para que no desaparezcan en filtros y gráficos.
--   - Los duplicados exactos NO se eliminan: probablemente son accidentes
--     distintos y el dataset no tiene identificador para distinguirlos.
--
-- Pendiente / limitaciones conocidas:
--   - No se normalizan aún las abreviaturas de dirección (CL/CLLE/CALLE,
--     CR/CRA/CARRERA).
--   - La agrupación de las 37 clases de vehículo en categorías de análisis
--     se hará en la capa gold, no aquí.
--   - No está confirmado qué cuenta cantidad_accidentes: los datos sugieren
--     que son vehículos de esa clase y servicio en el evento, no accidentes.
--     Por eso la columna conserva su nombre original.
--   - Las conversiones usan SAFE: si un valor no se puede convertir queda
--     NULL en vez de romper la consulta. Hay que verificar que no haya
--     NULL nuevos tras convertir (fechas y cantidades).
-- =====================================================================

WITH limpio AS (
  SELECT
    -- Fecha: primeros 10 caracteres (AAAA-MM-DD), se descarta la hora (siempre 00:00:00).
    -- SAFE.: si no se puede convertir, devuelve NULL en lugar de fallar.
    SAFE.PARSE_DATE('%Y-%m-%d', SUBSTR(fecha_de_accidente, 1, 10)) AS fecha_accidente,

    -- Dirección: mayúsculas, sin espacios al inicio/final y sin espacios dobles
    -- (\s+ = uno o más espacios seguidos -> se reemplazan por uno solo).
    REGEXP_REPLACE(UPPER(TRIM(direccion_accidente)), r'\s+', ' ') AS direccion_accidente,

    -- Clase de accidente: mayúsculas y sin espacios sobrantes
    -- (en bronze venía en formato título, p. ej. "Caida Ocupante").
    UPPER(TRIM(clase_accidente)) AS clase_accidente,

    -- Servicio del vehículo: mayúsculas, y si queda vacío o nulo -> 'SIN_DATO'.
    -- NULLIF convierte '' en NULL; COALESCE reemplaza NULL por 'SIN_DATO'.
    COALESCE(NULLIF(UPPER(TRIM(servicio_vehiculo_accidentado)), ''), 'SIN_DATO')
      AS servicio_vehiculo_accidentado,

    -- Clase de vehículo: mayúsculas y sin espacios sobrantes.
    UPPER(TRIM(clase_vehiculo_accidentado)) AS clase_vehiculo_accidentado,

    -- Cantidad: texto "2.0" -> decimal -> entero.
    -- Verificar antes que no existan decimales reales (p. ej. 2.5).
    SAFE_CAST(SAFE_CAST(cantidad_accidentes AS FLOAT64) AS INT64) AS cantidad_accidentes
  FROM {{ source('bronze', 'accidentalidad_raw') }}
)
SELECT * FROM limpio