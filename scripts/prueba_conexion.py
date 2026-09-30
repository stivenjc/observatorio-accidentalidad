from google.cloud import storage

PROYECTO = "fullproject-510120"
BUCKET = "portafolio-accidentalidad-raw-24"

cliente = storage.Client(project=PROYECTO)
bucket = cliente.bucket(BUCKET)

print("Conectado. Archivos en el bucket:")
for blob in cliente.list_blobs(BUCKET):
    print(" -", blob.name)
print("Listo (si no salió ningún archivo, es normal: el bucket está vacío).")