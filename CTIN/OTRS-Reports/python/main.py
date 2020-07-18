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

# Reporte Indicadores de Resultados (Graficas) Pdf y Xls
contentFile = "#!/usr/bin/env sh\n"
contentFile += "curl -o "+os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+".pdf -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteIndicadoresResultados.pdf?"
contentFile += "dia_corte="+str(dia_corte)+"\&mes_corte="+str(mes_corte)+"\&anio_corte="+str(anio_corte)+"\&tendencia="+str(tendencia)+"\&tendencia_porcentaje="+str(tendencia_porcentaje)+"\&total_cerrados="+str(total_cerrados)+"\&"
contentFile += "total_abiertos="+str(total_abiertos)+"\&dia_informe_anterior="+str(dia_informe_anterior)+"\&mes_informe_anterior="+str(mes_informe_anterior)+"\&porcentaje_semana_anterior="+str(porcentaje_semana_anterior)+"\&"
contentFile += "porcentaje_solicitudes_pendientes="+str(porcentaje_solicitudes_pendientes)+"\&porcentaje_solicitudes_pendientes_claro_pagos="+str(porcentaje_solicitudes_pendientes_claro_pagos)+"\&porcentaje_solicitudes_pendientes_claro_shop="+str(porcentaje_solicitudes_pendientes_claro_shop)+"\&"
contentFile += "porcentaje_solicitudes_pendientes_tramites="+str(porcentaje_solicitudes_pendientes_tramites)+"\&porcentaje_solicitudes_pendientes_subdireccion="+str(porcentaje_solicitudes_pendientes_subdireccion)+"\&porcentaje_solicitudes_pendientes_triara="+str(porcentaje_solicitudes_pendientes_triara)+"\n"

contentFile += "curl -o "+os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+".xls -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteIndicadoresResultados.xls?"
contentFile += "dia_corte="+str(dia_corte)+"\&mes_corte="+str(mes_corte)+"\&anio_corte="+str(anio_corte)+"\&tendencia="+str(tendencia)+"\&tendencia_porcentaje="+str(tendencia_porcentaje)+"\&total_cerrados="+str(total_cerrados)+"\&"
contentFile += "total_abiertos="+str(total_abiertos)+"\&dia_informe_anterior="+str(dia_informe_anterior)+"\&mes_informe_anterior="+str(mes_informe_anterior)+"\&porcentaje_semana_anterior="+str(porcentaje_semana_anterior)+"\&"
contentFile += "porcentaje_solicitudes_pendientes="+str(porcentaje_solicitudes_pendientes)+"\&porcentaje_solicitudes_pendientes_claro_pagos="+str(porcentaje_solicitudes_pendientes_claro_pagos)+"\&porcentaje_solicitudes_pendientes_claro_shop="+str(porcentaje_solicitudes_pendientes_claro_shop)+"\&"
contentFile += "porcentaje_solicitudes_pendientes_tramites="+str(porcentaje_solicitudes_pendientes_tramites)+"\&porcentaje_solicitudes_pendientes_subdireccion="+str(porcentaje_solicitudes_pendientes_subdireccion)+"\&porcentaje_solicitudes_pendientes_triara="+str(porcentaje_solicitudes_pendientes_triara)+"\n"


# Reporte Actividades (Excel) Pdf y Xls
contentFile += "curl -o "+os.getcwd()+"/Reporte_Actividades_Mercaderias_"+str(datetime.now().isocalendar()[1])+".pdf -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteActividadesMercaderias.pdf\n"
contentFile += "curl -o "+os.getcwd()+"/Reporte_Actividades_Financieros_"+str(datetime.now().isocalendar()[1])+".pdf -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteActividadesFinancieros.pdf\n"
contentFile += "curl -o "+os.getcwd()+"/Reporte_Actividades_Telcos_"+str(datetime.now().isocalendar()[1])+".pdf -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteActividadesTelcos.pdf\n"

contentFile += "curl -o "+os.getcwd()+"/Reporte_Actividades_Mercaderias_"+str(datetime.now().isocalendar()[1])+".xls -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteActividadesMercaderias.xls\n"
contentFile += "curl -o "+os.getcwd()+"/Reporte_Actividades_Financieros_"+str(datetime.now().isocalendar()[1])+".xls -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteActividadesFinancieros.xls\n"
contentFile += "curl -o "+os.getcwd()+"/Reporte_Actividades_Telcos_"+str(datetime.now().isocalendar()[1])+".xls -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteActividadesTelcos.xls\n"

# Reporte Indicadores de Rendimiento (Fabi) Pdf y Xls
contentFile += "curl -o "+os.getcwd()+"/Reporte_Indicadores_Rendimiento_"+str(datetime.now().isocalendar()[1])+".pdf -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteIndicadoresRendimiento.pdf\n"
contentFile += "curl -o "+os.getcwd()+"/Reporte_Indicadores_Rendimiento_"+str(datetime.now().isocalendar()[1])+".xls -v -X GET https://user:JasperUserCentos7..@jasperserver.ctin.amxdigital.net/jasperserver/rest_v2/reports/Reports/OTRS/ReporteIndicadoresRendimiento.xls\n"


contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Indicadores_Resultados_'+str(datetime.now().isocalendar()[1])+'.pdf" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Indicadores_Resultados_'+str(datetime.now().isocalendar()[1])+'.xls" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Actividades_Mercaderias_'+str(datetime.now().isocalendar()[1])+'.pdf" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Actividades_Mercaderias_'+str(datetime.now().isocalendar()[1])+'.xls" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Actividades_Financieros_'+str(datetime.now().isocalendar()[1])+'.pdf" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Actividades_Financieros_'+str(datetime.now().isocalendar()[1])+'.xls" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Actividades_Telcos_'+str(datetime.now().isocalendar()[1])+'.pdf" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Actividades_Telcos_'+str(datetime.now().isocalendar()[1])+'.xls" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Indicadores_Rendimiento_'+str(datetime.now().isocalendar()[1])+'.pdf" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'
contentFile += '\tcurl -i -v -X POST -H "Content-Type: multipart/form-data" -F "chat_id=-1001325452676" -F "document=@'+os.getcwd()+'/Reporte_Indicadores_Rendimiento_'+str(datetime.now().isocalendar()[1])+'.xls" https://api.telegram.org/bot513974686\:AAF4aeVUDtv80yLx2fFdiQJLa9\_mrGr\_cXU/sendDocument\n'

contentFile += '\tpython report_mail_relay.py\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+'.pdf\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+'.xls\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Actividades_Mercaderias_"+str(datetime.now().isocalendar()[1])+'.pdf\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Actividades_Mercaderias_"+str(datetime.now().isocalendar()[1])+'.xls\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Actividades_Financieros_"+str(datetime.now().isocalendar()[1])+'.pdf\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Actividades_Financieros_"+str(datetime.now().isocalendar()[1])+'.xls\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Actividades_Telcos_"+str(datetime.now().isocalendar()[1])+'.pdf\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Actividades_Telcos_"+str(datetime.now().isocalendar()[1])+'.xls\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Indicadores_Rendimiento_"+str(datetime.now().isocalendar()[1])+'.pdf\n'
contentFile += 'rm -f '+os.getcwd()+"/Reporte_Indicadores_Rendimiento_"+str(datetime.now().isocalendar()[1])+'.xls\n'

file = FileClass("report.sh","w")
file.openFile()
file.writeFile(contentFile)
file.closeFile()