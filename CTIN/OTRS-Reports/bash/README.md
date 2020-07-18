# Script para automatización de la creación del reporte

El script **script_main.sh** tiene como finalidad dar comienzo a la creación y envio del reporte. El contenido de dicho script es el siguiente:

*script_main.sh*:
```bash
#!/bin/bash
#mysql -ujasperserver -h 10.0.57.35 -pMysqlroottoypassw0rd69play! -e"use basejasper;CALL ingresar_registros();"
python main.python
chmod 755 report.sh
sh report.sh
echo "Reporte enviado"
```

Es importante señalar que este script debe contar con los permisos de ejecución pertinentes.
