CREATE OR REPLACE TABLE `fullproject-510120.gold.dim_servicio` AS
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