#!/bin/bash

# Activar entorno virtual si es necesario
source venv/bin/activate

echo "Ejecutando generación de facturas..."
bash generador_facturas.sh

echo "Esperando 1 minuto antes de enviar correos..."
sleep 60

echo "Ejecutando envío de correos..."
python3 enviador.py

echo "Generando resumen diario..."
bash resumen_diario.sh

echo "Enviando resumen al administrador..."
python3 enviar_resumen.py

echo "Proceso completo."
