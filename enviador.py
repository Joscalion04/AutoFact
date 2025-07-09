# enviador.py
import csv, smtplib, os
from email.message import EmailMessage
import re

SMTP = "smtp.example.com"
USER = "usuario@example.com"
PASS = "tu_contraseña_segura"

def es_correo_valido(correo):
    return re.match(r"[^@]+@[^@]+\.[^@]+", correo)

lineas_exitosas = []

with open('pendientes_envio.csv', 'r') as infile, open('logs/log_envios.csv', 'a') as log:
    reader = csv.reader(infile)
    for pdf, correo in reader:
        if not es_correo_valido(correo) or not os.path.exists(f"facturas/{pdf}"):
            log.write(f"{pdf},{correo},fallido\n")
            continue

        msg = EmailMessage()
        msg["Subject"] = "Su factura electrónica"
        msg["From"] = USER
        msg["To"] = correo
        msg.set_content("Adjunto encontrará su factura.")

        with open(f"facturas/{pdf}", 'rb') as f:
            msg.add_attachment(f.read(), maintype='application', subtype='pdf', filename=pdf)

        try:
            with smtplib.SMTP(SMTP, 587) as smtp:
                smtp.starttls()
                smtp.login(USER, PASS)
                smtp.send_message(msg)
                log.write(f"{pdf},{correo},exitoso\n")
                lineas_exitosas.append(f"{pdf},{correo}")
        except Exception:
            log.write(f"{pdf},{correo},fallido\n")

# Eliminar líneas exitosas
with open('pendientes_envio.csv', 'r') as f:
    lineas = f.readlines()

with open('pendientes_envio.csv', 'w') as f:
    for linea in lineas:
        if linea.strip() not in lineas_exitosas:
            f.write(linea)
