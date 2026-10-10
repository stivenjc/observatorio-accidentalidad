# Uso (desde la raíz del repositorio): source scripts/airflow_env.sh
export AIRFLOW_HOME="$(pwd)/airflow"
export AIRFLOW__CORE__LOAD_EXAMPLES=False
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud-observatorio/application_default_credentials.json"
echo "AIRFLOW_HOME=$AIRFLOW_HOME"
echo "Credenciales: $GOOGLE_APPLICATION_CREDENTIALS"