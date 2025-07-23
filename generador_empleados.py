from faker import Faker
import csv
import random

# Cantidad de empleados a generar
NUM_EMPLEADOS = 10

# Dominio institucional
DOMINIO = "empresa.com"

# Inicializar Faker
fake = Faker('es_MX')  # Puedes usar 'es_CR' si lo soporta tu sistema

# Crear archivo CSV
with open('empleados.csv', mode='w', newline='', encoding='utf-8') as archivo:
    writer = csv.writer(archivo)
    writer.writerow(['Nombre', 'Correo'])  # Encabezados

    for _ in range(NUM_EMPLEADOS):
        nombre = fake.name()
        base_correo = nombre.lower().replace(" ", ".").replace("ñ", "n")
        correo = f"{base_correo}@{DOMINIO}"

        writer.writerow([nombre, correo])

print(f"Archivo 'empleados.csv' generado con {NUM_EMPLEADOS} empleados.")
