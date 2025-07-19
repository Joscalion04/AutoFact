# generador_compras.py
import csv, random, uuid
from faker import Faker
from datetime import datetime

faker = Faker()
file_name = f"compras/compras_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"

with open(file_name, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile, delimiter=';')
    writer.writerow([
        "id_transaccion", "fecha_emision", "nombre", "correo", "telefono",
        "direccion", "ciudad", "cantidad", "monto", "pago", "estado_pago", "ip", "timestamp", "observaciones"
    ])
    
    for _ in range(10):
        nombre = faker.name()
        correo = faker.email()
        telefono = faker.phone_number()
        direccion = faker.address().replace('\n', ' ')
        ciudad = faker.city()
        cantidad = random.randint(1, 5)
        monto = round(random.uniform(1000, 10000), 2)
        pago = random.choice(["completo", "fraccionado"])
        estado_pago = random.choice(["exitoso", "fallido"])
        ip = faker.ipv4()
        timestamp = datetime.now().isoformat()
        observaciones = random.choice(["cliente frecuente", "promo aplicada", ""])

        writer.writerow([
            str(uuid.uuid4()), datetime.now().date(), nombre, correo, telefono,
            direccion, ciudad, cantidad, monto, pago, estado_pago, ip, timestamp, observaciones
        ])
