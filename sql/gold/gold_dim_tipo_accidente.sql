CREATE OR REPLACE TABLE `fullproject-510120.gold.dim_tipo_accidente` AS
SELECT clase_accidente, etiqueta
FROM UNNEST([
  STRUCT('CHOQUE' AS clase_accidente, 'Choque' AS etiqueta),
  ('ATROPELLO', 'Atropello'),
  ('CAIDA OCUPANTE', 'Caída de ocupante'),
  ('VOLCAMIENTO', 'Volcamiento'),
  ('OTRO', 'Otro'),
  ('INCENDIO', 'Incendio')
])