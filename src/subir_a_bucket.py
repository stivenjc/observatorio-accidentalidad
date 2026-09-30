import base64
import hashlib
import logging
import os
from datetime import date
from pathlib import Path

from dotenv import load_dotenv
from google.api_core.exceptions import PreconditionFailed
from google.cloud import storage

load_dotenv()

PROYECTO = os.environ["GCP_PROJECT_ID"]
BUCKET = os.environ["GCS_BUCKET"]
ARCHIVO_LOCAL = Path("data/raw/accidentalidad_completo.jsonl")

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)


def md5_local(ruta: Path) -> str:
    h = hashlib.md5()
    with ruta.open("rb") as f:
        for bloque in iter(lambda: f.read(1024 * 1024), b""):
            h.update(bloque)
    return base64.b64encode(h.digest()).decode()


def main() -> None:
    destino = (f"raw/accidentalidad/ingestion_date={date.today():%Y-%m-%d}/"
               f"{ARCHIVO_LOCAL.name}")
    cliente = storage.Client(project=PROYECTO)
    blob = cliente.bucket(BUCKET).blob(destino)

    try:
        blob.upload_from_filename(str(ARCHIVO_LOCAL), if_generation_match=0)
        log.info("Subido a gs://%s/%s", BUCKET, destino)
    except PreconditionFailed:
        log.warning("Ya existe gs://%s/%s; no se sobrescribe", BUCKET, destino)
        blob.reload()

    if blob.md5_hash != md5_local(ARCHIVO_LOCAL):
        log.error("El MD5 del bucket no coincide con el archivo local")
        raise SystemExit(1)
    log.info("Verificación OK: archivo idéntico al local (%s bytes)", blob.size)


if __name__ == "__main__":
    main()