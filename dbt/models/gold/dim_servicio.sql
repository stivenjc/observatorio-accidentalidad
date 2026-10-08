SELECT servicio, etiqueta
FROM UNNEST([
  STRUCT('PARTICULAR' AS servicio, 'Particular' AS etiqueta),
  ('PUBLICO', 'Público'),
  ('OFICIAL', 'Oficial'),
  ('OTROS', 'Otros'),
  ('DIPLOMATICO', 'Diplomático'),
  ('CONSULAR', 'Consular'),
  ('SIN_DATO', 'Sin dato')
])