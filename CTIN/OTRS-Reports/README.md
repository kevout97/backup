# OTRS-Reports
El repositorio tiene como finalidad almacenar los diferentes archivos utilizados para la creación y envio del reporte semanal correspondiente a las solicitudes de la Mesa de Servicios.

La estructura del repositorio es la siguiente:
* **bash**: Contiene el script que da comienzo a la creación y envio del reporte.
* **jasper**: Integra todos los archivos que permiten el modelado del reporte con el uso de la herramienta JasperReports
* **python**: Reune los archivos python que crea y modela un segundo script el cual realiza la petición a JasperServer asi como el envio a un grupo de Telegram y correo electronico.
* **querys**: Scripts que permiten el modelado de una base de datos a la cual JasperServer realiza las consultas necesarias para el modelado del reporte.

**NOTA**: Para llevar a cabo la creación del reporte, es necesario que los archivos *DBMysql.py*, *File.py*, *report_mail_relay.py*, *main.py*, *script_main.sh* se encuentren ubicados en el mismo directorio, de igual forma es necesario otorgarle permisos de ejecución al archivo *script_main.sh*.