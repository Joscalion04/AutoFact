# cron_job.sh
0 1 * * * bash /ruta/generador_facturas.sh
0 2 * * * python3 /ruta/enviador.py
