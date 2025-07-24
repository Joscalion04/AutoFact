from faker import Faker
import csv
import unicodedata
import re

NUM_EMPLEADOS = 10
DOMINIO = "empresa.com"

fake = Faker('es_MX')

def limpiar_texto(texto):
    texto = unicodedata.normalize('NFKD', texto).encode('ASCII', 'ignore').decode('utf-8')
    texto = re.sub(r"[^\w\s\.]", "", texto)  
    texto = re.sub(r"\s+", " ", texto).strip()  
    return texto

def limpiar_correo(correo):
    correo = correo.lower()
    correo = re.sub(r"\s+", "", correo) 
    correo = re.sub(r"\.{2,}", ".", correo)  
    correo = correo.strip(".") 
    return correo

with open('empleados.csv', mode='w', newline='', encoding='utf-8') as archivo:
    writer = csv.writer(archivo)
    writer.writerow(['Nombre', 'Correo'])

    for _ in range(NUM_EMPLEADOS):
        nombre_real = fake.name()
        nombre_limpio = limpiar_texto(nombre_real)
        correo_base = nombre_limpio.lower().replace(" ", ".")
        correo_base = limpiar_correo(correo_base)
        correo = f"{correo_base}@{DOMINIO}"
        writer.writerow([nombre_limpio, correo])

print(f"Archivo 'empleados.csv' generado con {NUM_EMPLEADOS} empleados.")
