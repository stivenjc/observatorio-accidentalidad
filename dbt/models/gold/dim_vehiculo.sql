SELECT
  clase_vehiculo,
  categoria_vehiculo,
  categoria_vehiculo = 'Motocicletas' AS es_motocicleta
FROM UNNEST([
  STRUCT('AUTOMOVIL' AS clase_vehiculo, 'Vehículos livianos' AS categoria_vehiculo),
  ('CAMPERO', 'Vehículos livianos'),
  ('CAMIONETA', 'Vehículos livianos'),

  ('MOTOCICLETA', 'Motocicletas'),
  ('MOTOCICLO', 'Motocicletas'),
  ('CICLOMOTOR', 'Motocicletas'),
  ('MOTOTRICICLO', 'Motocicletas'),
  ('TRICIMOTO', 'Motocicletas'),
  ('CUATRIMOTO', 'Motocicletas'),
  ('MOTOCARRO', 'Motocicletas'),
  ('CUADRICICLO', 'Motocicletas'),

  ('BUS', 'Buses'),
  ('BUSETA', 'Buses'),
  ('MICROBUS', 'Buses'),
  ('BUS ARTICULADO', 'Buses'),

  ('CAMION', 'Carga'),
  ('TRACTO/CAMION', 'Carga'),
  ('VOLQUETA', 'Carga'),
  ('REMOLQUE', 'Carga'),
  ('SEMIREMOLQUE', 'Carga'),

  ('BICICLETA', 'No motorizados'),
  ('CICLO TAXI', 'No motorizados'),
  ('TRACCION ANIMAL', 'No motorizados'),

  ('MAQUINARIA INDUSTRIAL', 'Maquinaria'),
  ('MAQUINARIA AGRICOLA', 'Maquinaria'),
  ('MONTACARGAS', 'Maquinaria'),
  ('RETROEXCAVADORA', 'Maquinaria'),
  ('MINI RETROEXCAVADORA', 'Maquinaria'),
  ('MINICARGADOR', 'Maquinaria'),
  ('MINI EXCAVADORA', 'Maquinaria'),
  ('BULDOZER', 'Maquinaria'),
  ('MANIPULADOR TELESCOPICO', 'Maquinaria'),
  ('PLATAFORMA DE ELEVACION', 'Maquinaria'),
  ('CARGADOR', 'Maquinaria'),
  ('TRACTOR', 'Maquinaria'),

  ('DESCONOCIDA', 'Sin información'),
  ('OTRAS', 'Sin información')
])