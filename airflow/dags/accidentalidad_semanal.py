from datetime import timedelta
from pathlib import Path

import pendulum
from airflow.providers.standard.operators.bash import BashOperator
from airflow.sdk import DAG

BASE = Path(__file__).resolve().parents[2]    # raíz del repositorio
PY = BASE / ".venv" / "bin" / "python"        # Python del pipeline (otro entorno)
DBT = BASE / ".venv" / "bin" / "dbt"

with DAG(
    dag_id="accidentalidad_semanal",
    description="Revisa si hay datos nuevos y, si los hay, recarga bronze, silver y gold",
    schedule="0 6 * * 1",  # lunes a las 6:00
    start_date=pendulum.datetime(2026, 10, 1, tz="America/Bogota"),
    catchup=False,
    max_active_runs=1,
    tags=["accidentalidad"],
) as dag:

    revisar_datos_nuevos = BashOperator(
        task_id="revisar_datos_nuevos",
        bash_command=f"cd {BASE} && {PY} src/revisar_datos_nuevos.py",
        skip_on_exit_code=99,
        retries=3,
        retry_delay=timedelta(minutes=5),
    )

    descargar = BashOperator(
        task_id="descargar",
        bash_command=f"cd {BASE} && {PY} src/descargar_data.py",
        retries=2,
        retry_delay=timedelta(minutes=5),
    )

    subir_a_bucket = BashOperator(
        task_id="subir_a_bucket",
        bash_command=f"cd {BASE} && {PY} src/subir_a_bucket.py",
        retries=2,
        retry_delay=timedelta(minutes=5),
    )

    cargar_bronze = BashOperator(
        task_id="cargar_bronze",
        bash_command=f"cd {BASE} && {PY} src/cargar_a_bigquery.py",
        retries=2,
        retry_delay=timedelta(minutes=5),
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {BASE}/dbt && {DBT} run --target prod",
        retries=1,
        retry_delay=timedelta(minutes=5),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {BASE}/dbt && {DBT} test --target prod",
        retries=0,
    )

    (
        revisar_datos_nuevos
        >> descargar
        >> subir_a_bucket
        >> cargar_bronze
        >> dbt_run
        >> dbt_test
    )