import argparse
import logging
import os
from datetime import date

from dotenv import load_dotenv
from google.cloud import bigquery

load_dotenv()

PROYECTO = os.environ["GCP_PROJECT_ID"]
BUCKET = os.environ["GCS_BUCKET"]
UBICACION = "us-central1"
DATASET = "bronze"
TABLA = "accidentalidad_raw"
COLUMNAS = [
    "fecha_de_accidente", "direccion_accidente", "clase_accidente",
    "servicio_vehiculo_accidentado", "clase_vehiculo_accidentado", "cantidad_accidentes",
]

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fecha", default=date.today().isoformat(),
                        help="fecha de ingesta (AAAA-MM-DD), por defecto hoy")
    fecha = date.fromisoformat(parser.parse_args().fecha)

    uri = (f"gs://{BUCKET}/raw/accidentalidad/ingestion_date={fecha:%Y-%m-%d}/"
           "accidentalidad_completo.jsonl")
    tabla_id = f"{PROYECTO}.{DATASET}.{TABLA}"

    cliente = bigquery.Client(project=PROYECTO, location=UBICACION)

    esquema = [bigquery.SchemaField(c, "STRING") for c in COLUMNAS]
    tabla = bigquery.Table(tabla_id, schema=esquema)
    tabla.time_partitioning = bigquery.TimePartitioning(type_=bigquery.TimePartitioningType.DAY)
    cliente.create_table(tabla, exists_ok=True)

    config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        schema=esquema,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )
    log.info("Cargando %s", uri)
    job = cliente.load_table_from_uri(uri, f"{tabla_id}${fecha:%Y%m%d}", job_config=config)
    job.result()
    log.info("Carga terminada: %s filas en la partición %s", job.output_rows, fecha)


if __name__ == "__main__":
    main()