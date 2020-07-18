# Archivos python utilizados para automatizar la creación del reporte

Tanto los archivos *DBMysql.py* y *File.py* tienen como finalidad contener clases que permitirán realizar consultas a una base remota y la creación de un segundo script respectivamente.

El contenido de cada archivo es el siguiente:

*DBMysql.py*
```python
import pymysql
class DBClass:
    host=""
    user=""
    passwd=""
    database=""
    db = None
    cursor = None

    def __init__(self,host,user,passwd,database):
        self.host = host
        self.user = user
        self.passwd = passwd
        self.database = database
        try:
            self.db = pymysql.connect(self.host,self.user,self.passwd,self.database)
            self.cursor = self.db.cursor()
            print("Conexion establecida")
        except Exception:
            print("Fallo la conexion con la base de datos")
    
    def closeConnection(self):
        self.cursor.close()
        self.db.close()
        print("Conexion cerrada")
    
    def executeSelect(self,query):
        self.cursor.execute(query)
        return self.cursor.fetchall()
```

*File.py*
```python
import os
class FileClass:
    nombre = ""
    permisos = ""
    f = None

    def __init__(self,nombre,permisos):
        self.nombre = nombre
        self.permisos = permisos
    
    def getPath(self):
        return os.getcwd()
    
    def openFile(self):
        try:
            self.f = open(os.getcwd()+"/"+self.nombre,self.permisos)
        except IOError:
            os.remove(os.getcwd()+"/"+self.nombre)
            self.f = open(os.getcwd()+"/"+self.nombre,self.permisos)
            pass
    
    def closeFile(self):
        self.f.close()
    
    def writeFile(self,texto):
        self.f.write(texto)
    
    def apendFile(self,texto):
        self.f.apend(texto)
    
    def readFile(self):
        return self.f.read()
```

Es importante señalar que el archivo *DBMysql.py* utiliza los modulos integrados en el paquete **pymysql** por lo que es necesaria la previa instalación de dicho paquete.

```bash
pip install pymysql
```

En cuanto al archivo *report_mail_relay.py* podemos destacar que este tiene como finalidad el envio via email del reporte previamente creado y descargado en el mismo directorio donde se ubica este archivo.
Los paquetes utilizados por este archivo son: *smtplib*, *email*. por lo que es importante tenerlos previamente instalados.

```bash
pip install smtplib email
```

El contenido de este archivo es el siguiente:

*report_mail_relay.py*
```python
import smtplib
import time
from datetime import datetime, date, time, timedelta
import os
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

fromaddr = 'Reportes OTRS'
toaddrs  = ['email@email.com'] #Agregar los destinatarios deseados

msg = MIMEMultipart()
msg['Subject'] = "Reporte semanal OTRS"
msg['From'] = "Reportes OTRS"
msg['To'] = ", ".join(toaddrs)

part_pdf = MIMEBase('application', "octet-stream")
part_pdf.set_payload(open(os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+".pdf", "rb").read())
encoders.encode_base64(part_pdf)
part_pdf.add_header('Content-Disposition', 'attachment; filename="Reporte_Indicadores_Resultados_'+str(datetime.now().isocalendar()[1])+'.pdf"')
msg.attach(part_pdf)

part_pdf = MIMEBase('application', "octet-stream")
part_pdf.set_payload(open(os.getcwd()+"/Reporte_Actividades_Mercaderias_"+str(datetime.now().isocalendar()[1])+".pdf", "rb").read())
encoders.encode_base64(part_pdf)
part_pdf.add_header('Content-Disposition', 'attachment; filename="Reporte_Actividades_Mercaderias_'+str(datetime.now().isocalendar()[1])+'.pdf"')
msg.attach(part_pdf)

username = 'reportes.ctin.infraestructura@gmail.com'
password = 'UmVwb3J0ZXMuQ1RJTi5JbmZyYWVzdHJ1Y3R1cmEK'
server = smtplib.SMTP('smtp.gmail.com:587')
server.ehlo()
server.starttls()
server.login(username,password)
server.sendmail(fromaddr, toaddrs, msg.as_string())
server.quit()
```

Finalemente el archivo *main.py* es el encargado de la creación de un script el cual realiza la petición a JasperServer para la descarga y posteriormente el envio del reporte. El contenido de dicho archivo es el siguiente:

*main.py* 
```python
from File import FileClass
from DBMysql import DBClass
from datetime import datetime, date, time, timedelta
import calendar
import os

db = DBClass("10.0.57.35","jasperserver","Mysqlroottoypassw0rd69play!","basejasper") #Ver usuario, host y contraseña


meses = ["enero","febrero","marzo","abril","mayo","junio","julio","agosto","septiembre","octubre","noviembre","diciembre"]
dia_corte = datetime.now().day
mes_corte = meses[(datetime.now().month) - 1]
anio_corte = datetime.now().year


tendencia = "positiva"

query = 'SELECT porcentaje FROM solicitudes_pendientes_semanal WHERE DATE_FORMAT("2018-08-13 18:00:00","%Y-%m-%d") = DATE_FORMAT(fecha,"%Y-%m-%d")' #Cambiar la fecha por NOW()
mycursor = db.executeSelect(query)
tendencia_porcentaje = mycursor[0][0]

query = 'SELECT porcentaje FROM solicitudes_pendientes_semanal WHERE DATE_FORMAT(DATE_SUB("2018-08-20 18:00:00", INTERVAL 7 DAY),"%Y-%m-%d") = DATE_FORMAT(fecha,"%Y-%m-%d")' #Cambiar la fecha por NOW()
mycursor = db.executeSelect(query)
porcentaje_semana_anterior = mycursor[0][0]

query = "SELECT sum(total_abiertos) as total_abiertos, sum(total_cerrados) as total_cerrados FROM tickets_abiertos_cerrados"
mycursor = db.executeSelect(query)
total_cerrados = mycursor[0][1]
total_abiertos = mycursor[0][0]


dia_informe_anterior = (date.today() - timedelta(days=7)).day
mes_informe_anterior = meses[(date.today() - timedelta(days=7)).month - 1]


query = "select sum(total_solicitudes) from solicitudes_estado where estado_nombre like '%pending reminder%'"
mycursor = db.executeSelect(query)
query = "select sum(total_abiertos) from tickets_abiertos_cerrados"
mycursor2 = db.executeSelect(query)

if mycursor[0][0] is None:
    porcentaje_solicitudes_pendientes = 0.0
elif mycursor2[0][0] is None:
    porcentaje_solicitudes_pendientes = -1
else:
    porcentaje_solicitudes_pendientes = round(float(((mycursor[0][0])*100)/mycursor2[0][0]),1)


query = "select sum(estado_pending_reminder), sum(estado_L1_follow_up_pending_reminder) from gerencias_estados where idGerencia = 27"
mycursor = db.executeSelect(query)
query = "select sum(total_abiertos) from tickets_abiertos_cerrados where idGerencia = 27"
mycursor2 = db.executeSelect(query)

if mycursor[0][0] is None and mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_claro_pagos = 0.0
elif mycursor[0][0] is None:
    porcentaje_solicitudes_pendientes_claro_pagos = round(float(((mycursor[0][1])*100)/mycursor2[0][0]),1)
elif mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_claro_pagos = round(float(((mycursor[0][0])*100)/mycursor2[0][0]),1)
elif mycursor2[0][0] is None:
    porcentaje_solicitudes_pendientes_claro_pagos = -1
else:
    porcentaje_solicitudes_pendientes_claro_pagos = round(float(((mycursor[0][0]+mycursor[0][1])*100)/mycursor2[0][0]),1)


query = "select sum(estado_pending_reminder), sum(estado_L1_follow_up_pending_reminder) from gerencias_estados where idGerencia in (14,16,28)"
mycursor = db.executeSelect(query)
query = "select sum(total_abiertos) from tickets_abiertos_cerrados where idGerencia in (14,16,28)"
mycursor2 = db.executeSelect(query)

if mycursor[0][0] is None and mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_claro_shop = 0.0
elif mycursor[0][0] is None:
    porcentaje_solicitudes_pendientes_claro_shop = round(float(((mycursor[0][1])*100)/mycursor2[0][0]),1)
elif mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_claro_shop = round(float(((mycursor[0][0])*100)/mycursor2[0][0]),1)
elif mycursor2[0][0] is None:
    porcentaje_solicitudes_pendientes_claro_shop = -1
else:
    porcentaje_solicitudes_pendientes_claro_shop = round(float(((mycursor[0][0]+mycursor[0][1])*100)/mycursor2[0][0]),1)


query = "select sum(estado_pending_reminder), sum(estado_L1_follow_up_pending_reminder) from gerencias_estados where idGerencia in (5,8,15,16,20,21,22,23)"
mycursor = db.executeSelect(query)
query = "select sum(total_abiertos) from tickets_abiertos_cerrados where idGerencia in (5,8,15,16,20,21,22,23)"
mycursor2 = db.executeSelect(query)

if mycursor[0][0] is None and mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_tramites = 0.0
elif mycursor[0][0] is None:
    porcentaje_solicitudes_pendientes_tramites = round(float(((mycursor[0][1])*100)/mycursor2[0][0]),1)
elif mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_tramites = round(float(((mycursor[0][0])*100)/mycursor2[0][0]),1)
elif mycursor2[0][0] is None:
    porcentaje_solicitudes_pendientes_tramites = -1
else:
    porcentaje_solicitudes_pendientes_tramites = round(float(((mycursor[0][0]+mycursor[0][1])*100)/mycursor2[0][0]),1)


query = "select sum(estado_pending_reminder), sum(estado_L1_follow_up_pending_reminder) from gerencias_estados where idGerencia in (28,29)"
mycursor = db.executeSelect(query)
query = "select sum(total_abiertos) from tickets_abiertos_cerrados where idGerencia in (28,29)"
mycursor2 = db.executeSelect(query)

if mycursor[0][0] is None and mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_subdireccion = 0.0
elif mycursor[0][0] is None:
    porcentaje_solicitudes_pendientes_subdireccion = round(float(((mycursor[0][1])*100)/mycursor2[0][0]),1)
elif mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_subdireccion = round(float(((mycursor[0][0])*100)/mycursor2[0][0]),1)
elif mycursor2[0][0] is None:
    porcentaje_solicitudes_pendientes_subdireccion = -1
else:
    porcentaje_solicitudes_pendientes_subdireccion = round(float(((mycursor[0][0]+mycursor[0][1])*100)/mycursor2[0][0]),1)


query = "select sum(estado_pending_reminder), sum(estado_L1_follow_up_pending_reminder) from gerencias_estados where idGerencia = 18"
mycursor = db.executeSelect(query)
query = "select sum(total_abiertos) from tickets_abiertos_cerrados where idGerencia = 18"
mycursor2 = db.executeSelect(query)

if mycursor[0][0] is None and mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_triara = 0.0
elif mycursor[0][0] is None:
    porcentaje_solicitudes_pendientes_triara = round(float(((mycursor[0][1])*100)/mycursor2[0][0]),1)
elif mycursor[0][1] is None:
    porcentaje_solicitudes_pendientes_triara = round(float(((mycursor[0][0])*100)/mycursor2[0][0]),1)
elif mycursor2[0][0] is None:
    porcentaje_solicitudes_pendientes_triara = -1
else:
    porcentaje_solicitudes_pendientes_triara = round(float(((mycursor[0][0]+mycursor[0][1])*100)/mycursor2[0][0]),1)

db.closeConnection()
print("Conexion Cerrada")

contentFile = "#!/usr/bin/env sh\n"
contentFile += "curl -o "+os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+".pdf -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteIndicadoresResultados.pdf?"
contentFile += "dia_corte="+str(dia_corte)+"\&mes_corte="+str(mes_corte)+"\&anio_corte="+str(anio_corte)+"\&tendencia="+str(tendencia)+"\&tendencia_porcentaje="+str(tendencia_porcentaje)+"\&total_cerrados="+str(total_cerrados)+"\&"
contentFile += "total_abiertos="+str(total_abiertos)+"\&dia_informe_anterior="+str(dia_informe_anterior)+"\&mes_informe_anterior="+str(mes_informe_anterior)+"\&porcentaje_semana_anterior="+str(porcentaje_semana_anterior)+"\&"
contentFile += "porcentaje_solicitudes_pendientes="+str(porcentaje_solicitudes_pendientes)+"\&porcentaje_solicitudes_pendientes_claro_pagos="+str(porcentaje_solicitudes_pendientes_claro_pagos)+"\&porcentaje_solicitudes_pendientes_claro_shop="+str(porcentaje_solicitudes_pendientes_claro_shop)+"\&"
contentFile += "porcentaje_solicitudes_pendientes_tramites="+str(porcentaje_solicitudes_pendientes_tramites)+"\&porcentaje_solicitudes_pendientes_subdireccion="+str(porcentaje_solicitudes_pendientes_subdireccion)+"\&porcentaje_solicitudes_pendientes_triara="+str(porcentaje_solicitudes_pendientes_triara)+"\n"
contentFile += "file="+os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+".pdf\n"
contentFile += "curl -o "+os.getcwd()+"/Reporte_Actividades_Mercaderias_"+str(datetime.now().isocalendar()[1])+".pdf -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteActividadesMercaderias.pdf\n"
contentFile += 'echo "====> File:${file}"\n'
contentFile += 'if [ -f "${file}" ]; then'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Indicadores_Resultados_'+str(datetime.now().isocalendar()[1])+'.pdf" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Actividades_Mercaderias_'+str(datetime.now().isocalendar()[1])+'.pdf" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tpython report_mail_relay.py\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+'.pdf\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Actividades_Mercaderias_"+str(datetime.now().isocalendar()[1])+'.pdf\n'
contentFile += 'else\n'
contentFile += 'echo "${file} not found."\n'
contentFile += 'fi\n'

file = FileClass("report.sh","w")
file.openFile()
file.writeFile(contentFile)
file.closeFile()
```