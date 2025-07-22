import smtplib
from email.message import EmailMessage

SMTP_HOST = "sandbox.smtp.mailtrap.io"
SMTP_PORT = 587
SMTP_USER = "107fdf1de1fdb3"
SMTP_PASS = "4743acf48cb5e8"

msg = EmailMessage()
msg["Subject"] = "Resumen Diario de Facturación"
msg["From"] = "no-reply@irsi.com"
msg["To"] = "admin@irsi.com"
msg.set_content("Adjunto encontrará el resumen diario de facturación y envíos.")

with open("logs/reporte_admin.txt", "rb") as f:
    msg.add_attachment(f.read(), maintype="text", subtype="plain", filename="reporte_admin.txt")

with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
    server.starttls()
    server.login(SMTP_USER, SMTP_PASS)
    server.send_message(msg)

print("✅ Reporte enviado al administrador.")
