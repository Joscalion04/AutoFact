import smtplib
import csv
import os
import time  # <--- NUEVO
from email.message import EmailMessage
from email.utils import formataddr
from email_validator import validate_email, EmailNotValidError

# Configuración SMTP de Mailtrap
SMTP_HOST = "sandbox.smtp.mailtrap.io"
SMTP_PORT = 587
SMTP_USER = "107fdf1de1fdb3"
SMTP_PASS = "4743acf48cb5e8"

PENDIENTES = "pendientes_envio.csv"
LOG_ENVIO = "logs/log_envios.csv"
CARPETA_FACTURAS = "facturas"

def correo_valido(correo):
    try:
        validate_email(correo, check_deliverability=False)  
        return True
    except EmailNotValidError:
        return False

if not os.path.exists(PENDIENTES):
    print("No se encontró el archivo pendientes_envio.csv.")
    exit()

nuevas_lineas = []
resultados = []

with open(PENDIENTES, newline='') as f:
    reader = csv.reader(f)
    for row in reader:
        if len(row) != 2:
            continue
        pdf, correo = row
        pdf_path = os.path.join(CARPETA_FACTURAS, pdf)

        if not os.path.exists(pdf_path):
            print(f"⚠ No se encontró el archivo: {pdf_path}")
            resultados.append([pdf, correo, "fallido"])
            continue

        if not correo_valido(correo):
            print(f"❌ Correo inválido: {correo}")
            resultados.append([pdf, correo, "fallido"])
            continue

        try:
            msg = EmailMessage()
            msg["Subject"] = "Factura Mercado IRSI"
            msg["From"] = formataddr(("Mercado IRSI", "no-reply@irsi.com"))
            msg["To"] = correo
            msg.set_content("Adjunto encontrará su factura electrónica. Gracias por su compra.")

            with open(pdf_path, "rb") as fpdf:
                msg.add_attachment(
                    fpdf.read(),
                    maintype="application",
                    subtype="pdf",
                    filename=pdf
                )

            with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
                server.starttls()
                server.login(SMTP_USER, SMTP_PASS)
                server.send_message(msg)

            print(f"✅ Enviado: {pdf} → {correo}")
            resultados.append([pdf, correo, "exitoso"])

            time.sleep(1.2)  

        except Exception as e:
            print(f"❌ Error enviando {pdf} → {correo}: {e}")
            resultados.append([pdf, correo, "fallido"])

# Actualizar pendientes_envio.csv
with open(PENDIENTES, newline='') as f:
    lineas_originales = list(csv.reader(f))

with open(PENDIENTES, "w", newline='') as f:
    writer = csv.writer(f)
    for linea in lineas_originales:
        if linea not in [r[:2] for r in resultados if r[2] == "exitoso"]:
            writer.writerow(linea)

# Guardar log_envios.csv
with open(LOG_ENVIO, "a", newline='') as f:
    writer = csv.writer(f)
    for r in resultados:
        writer.writerow(r)
