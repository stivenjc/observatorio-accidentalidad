import json
import logging
import os
from pathlib import Path

import requests
from dotenv import load_dotenv
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

load_dotenv()
#https://www.datos.gov.co/api/v3/views/nfa3-wgxy/query.json
URL = "https://www.datos.gov.co/resource/nfa3-wgxy.json"
TAMANO_PAGINA = 10_000
SALIDA = Path("data/raw/accidentalidad_completo.jsonl")

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)


def crear_sesion() -> requests.Session:
    sesion = requests.Session()
    sesion.headers.update({"X-App-Token": os.environ["SOCRATA_APP_TOKEN"]})
    reintentos = Retry(total=5, backoff_factor=2, status_forcelist=[429, 500, 502, 503, 504])
    sesion.mount("https://", HTTPAdapter(max_retries=reintentos))
    return sesion


def contar_filas(sesion: requests.Session) -> int:
    r = sesion.get(URL, params={"$select": "count(*)"}, timeout=60)
    r.raise_for_status()
    return int(r.json()[0]["count"])


def descargar_todo(sesion: requests.Session) -> list[dict]:
    filas, offset = [], 0
    while True:
        params = {"$limit": TAMANO_PAGINA, "$offset": offset, "$order": ":id"}
        r = sesion.get(URL, params=params, timeout=120)
        r.raise_for_status()
        lote = r.json()
        filas.extend(lote)
        log.info("Descargadas %s filas (acumulado: %s)", len(lote), len(filas))
        if len(lote) < TAMANO_PAGINA:
            break
        offset += TAMANO_PAGINA
    return filas


def main() -> None:
    sesion = crear_sesion()
    esperado = contar_filas(sesion)
    log.info("La API reporta %s filas", esperado)

    filas = descargar_todo(sesion)

    SALIDA.parent.mkdir(parents=True, exist_ok=True)
    with SALIDA.open("w", encoding="utf-8") as f:
        for fila in filas:
            f.write(json.dumps(fila, ensure_ascii=False) + "\n")

    if len(filas) != esperado:
        log.error("Descargué %s filas pero la API reporta %s", len(filas), esperado)
        raise SystemExit(1)
    log.info("Listo: %s filas guardadas en %s", len(filas), SALIDA)


if __name__ == "__main__":
    main()