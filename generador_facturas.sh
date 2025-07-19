#!/bin/bash

# Rutas
carpeta_compras="compras"
carpeta_facturas="facturas"
carpeta_logs="logs"
plantilla="plantilla_factura.tex"
csv_file=$(ls $carpeta_compras/*.csv | tail -n1)

# Crear carpetas si no existen
mkdir -p "$carpeta_facturas" "$carpeta_logs"

# Limpiar log diario anterior
log_diario="$carpeta_logs/log_diario.log"
> "$log_diario"

# Procesar cada línea del CSV
tail -n +2 "$csv_file" | while IFS=';' read -r id fecha nombre correo telefono direccion ciudad cantidad monto pago estado ip timestamp obs
do
    id_sanitizado="${id// /_}"
    tex_out="$carpeta_facturas/factura_${id_sanitizado}.tex"

    cp "$plantilla" "$tex_out"

    # Reemplazos campo a campo
    sed -i "s|{id_transaccion}|$id|g" "$tex_out"
    sed -i "s|{fecha_emision}|$fecha|g" "$tex_out"
    sed -i "s|{nombre}|$nombre|g" "$tex_out"
    sed -i "s|{correo}|$correo|g" "$tex_out"
    sed -i "s|{telefono}|$telefono|g" "$tex_out"
    sed -i "s|{direccion}|$direccion|g" "$tex_out"
    sed -i "s|{ciudad}|$ciudad|g" "$tex_out"
    sed -i "s|{cantidad}|$cantidad|g" "$tex_out"
    sed -i "s|{monto}|$monto|g" "$tex_out"
    sed -i "s|{pago}|$pago|g" "$tex_out"
    sed -i "s|{estado_pago}|$estado|g" "$tex_out"
    sed -i "s|{ip}|$ip|g" "$tex_out"
    sed -i "s|{timestamp}|$timestamp|g" "$tex_out"
    sed -i "s|{observaciones}|$obs|g" "$tex_out"

    pdflatex -interaction=nonstopmode -output-directory="$carpeta_facturas" "$tex_out" > "$carpeta_logs/log_factura_${id_sanitizado}.log" 2>&1

    if grep -q "!" "$carpeta_logs/log_factura_${id_sanitizado}.log"; then
        echo "$id,$correo,ERROR EN COMPILACIÓN" >> "$log_diario"
    else
        echo "factura_${id_sanitizado}.pdf,$correo" >> pendientes_envio.csv
        echo "$id,$correo,OK" >> "$log_diario"
    fi
done
