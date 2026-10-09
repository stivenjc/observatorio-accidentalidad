import logging
import os
import sys

import requests
from dotenv import load_dotenv
from google.api_core.exceptions import NotFound
from google.cloud import bigquery

load_dotenv()

URL = "https://www.datos.gov.co/resource/nfa3-wgxy.json"
PROYECTO = os.environ["GCP_PROJECT_ID"]
TABLA_BRONZE = f"{PROYECTO}.bronze.accidentalidad_raw"
SIN_DATOS_NUEVOS = 99  # código que Airflow interpreta como "omitir el resto"

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)


def total_api() -> int:
    r = requests.get(
        URL,
        params={"$select": "count(*)"},
        headers={"X-App-Token": os.environ["SOCRATA_APP_TOKEN"]},
        timeout=60,
    )
    r.raise_for_status()
    return int(r.json()[0]["count"])


def total_bronze() -> int:
    cliente = bigquery.Client(project=PROYECTO, location="us-central1")
    try:
        filas = cliente.query(f"SELECT COUNT(*) AS n FROM `{TABLA_BRONZE}`").result()
        return next(iter(filas)).n
    except NotFound:
        log.warning("La tabla bronze no existe todavía: se asume 0 filas")
        return 0


def main() -> int:
    api, bronze = total_api(), total_bronze()
    log.info("API: %s filas | bronze: %s filas", api, bronze)
    if api == bronze:
        log.info("Sin cambios: se omite el resto del flujo")
        return SIN_DATOS_NUEVOS
    log.info("Hay cambios: continuar con la descarga")
    return 0


if __name__ == "__main__":
    sys.exit(main())
