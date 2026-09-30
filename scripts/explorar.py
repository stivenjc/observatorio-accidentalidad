import pandas as pd

RUTA = "data/raw/accidentalidad_completo.jsonl"
df = pd.read_json(RUTA, lines=True, dtype=False, convert_dates=False)

# print("Filas y columnas:", df.shape)
# print("\nNulos por columna:\n", df.isna().sum())
# print("\nMuestra:\n", df.head(5).to_string())
# print("\nFilas completamente duplicadas:", df.duplicated().sum())
# print("\nFecha mínima y máxima (como texto):",
#       df["fecha_de_accidente"].min(), df["fecha_de_accidente"].max())
# print("\ncantidad_accidentes:\n", df["cantidad_accidentes"].value_counts().head(10))
# for col in ["clase_accidente", "servicio_vehiculo_accidentado", "clase_vehiculo_accidentado"]:
#     print(f"\n{col}: {df[col].nunique()} valores distintos")
#     print(df[col].value_counts().head(8))



# print("Filas duplicadas (todas las copias):")
# print(df[df.duplicated(keep=False)].sort_values(list(df.columns)).to_string())
#
# print("\nTodas las clases de vehículo:")
# print(df["clase_vehiculo_accidentado"].value_counts().to_string())
#
# print("\nFilas por año:")
# print(df["fecha_de_accidente"].str[:4].value_counts().sort_index())
#
# print("\n¿Todas las fechas a medianoche?:",
#       df["fecha_de_accidente"].str.endswith("T00:00:00.000").all())


df["cantidad"] = df["cantidad_accidentes"].astype(float)

# 1) ¿Se repite la combinación completa (sin contar cantidad)?
clave = ["fecha_de_accidente", "direccion_accidente", "clase_accidente",
         "servicio_vehiculo_accidentado", "clase_vehiculo_accidentado"]
g = df.groupby(clave, dropna=False)["cantidad"].agg(filas="size", total="sum")
print("Combinaciones repetidas:", (g["filas"] > 1).sum())
print(g[g["filas"] > 1])

# 2) Prueba de la hipótesis de "vehículos": total por evento y clase de accidente
evento = ["fecha_de_accidente", "direccion_accidente", "clase_accidente"]
ev = df.groupby(evento)["cantidad"].sum().reset_index(name="total_evento")
print(pd.crosstab(ev["clase_accidente"], ev["total_evento"].clip(upper=5)))