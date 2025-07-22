#!/bin/bash

log_envios="logs/log_envios.csv"
log_diario="logs/log_diario.log"
reporte="logs/reporte_admin.txt"

total_correos=$(wc -l < "$log_envios")
total_vendido=$(awk -F',' '{sum+=$1} END{print sum}' compras/*.csv | head -n 1)
pagados=$(awk -F';' '$11=="exitoso" && $10=="completo" {count++} END{print count}' compras/*.csv)
exitosos=$(awk -F',' '$3=="exitoso" {c++} END{print c}' "$log_envios")
fallidos=$(awk -F',' '$3=="fallido" {c++} END{print c}' "$log_envios")

echo "Resumen Diario de Facturación - $(date)" > "$reporte"
echo "--------------------------------------" >> "$reporte"
echo "Total de correos procesados: $total_correos" >> "$reporte"
echo "Total vendido (simulado): ₡$total_vendido" >> "$reporte"
echo "Pedidos pagados completamente: $pagados" >> "$reporte"
echo "Envíos exitosos: $exitosos" >> "$reporte"
echo "Envíos fallidos: $fallidos" >> "$reporte"

# Enviar el reporte al administrador vía Mailtrap (reutilizando el mismo sistema)
python3 enviar_resumen.py
