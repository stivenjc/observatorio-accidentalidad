SELECT
  f.fecha,
  d.anio,
  d.trimestre,
  d.mes,
  d.nombre_mes,
  d.dia_semana,
  d.nombre_dia,
  d.es_fin_de_semana,
  d.es_anio_completo,
  t.etiqueta AS tipo_accidente,
  s.etiqueta AS servicio,
  v.clase_vehiculo,
  v.categoria_vehiculo,
  v.es_motocicleta,
  f.direccion_accidente,
  f.vehiculos_involucrados
FROM {{ ref('fact_vehiculos_accidente') }} AS f
LEFT JOIN {{ ref('dim_fecha') }} AS d ON f.fecha = d.fecha
LEFT JOIN {{ ref('dim_tipo_accidente') }} AS t ON f.clase_accidente = t.clase_accidente
LEFT JOIN {{ ref('dim_servicio') }} AS s ON f.servicio = s.servicio
LEFT JOIN {{ ref('dim_vehiculo') }} AS v ON f.clase_vehiculo = v.clase_vehiculo