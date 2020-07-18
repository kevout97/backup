#!/bin/bash
#mysql -ujasperserver -h 10.0.57.35 -pMysqlroottoypassw0rd69play! -e"use basejasper;CALL ingresar_registros();"
python main.python
chmod 755 report.sh
sh report.sh
echo "Reporte enviado"