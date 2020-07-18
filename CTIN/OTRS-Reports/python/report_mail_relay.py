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

# Reporte Indicadores de Resultados (Graficas) Pdf y Xls
part_pdf = MIMEBase('application', "octet-stream")
part_pdf.set_payload(open(os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+".pdf", "rb").read())
encoders.encode_base64(part_pdf)
part_pdf.add_header('Content-Disposition', 'attachment; filename="Reporte_Indicadores_Resultados_'+str(datetime.now().isocalendar()[1])+'.pdf"')
msg.attach(part_pdf)

part_xls = MIMEBase('application', "octet-stream")
part_xls.set_payload(open(os.getcwd()+"/Reporte_Indicadores_Resultados_"+str(datetime.now().isocalendar()[1])+".xls", "rb").read())
encoders.encode_base64(part_xls)
part_xls.add_header('Content-Disposition', 'attachment; filename="Reporte_Indicadores_Resultados_'+str(datetime.now().isocalendar()[1])+'.xls"')
msg.attach(part_xls)

# Reporte Actividades (Excel) Pdf y Xls

part_pdf = MIMEBase('application', "octet-stream")
part_pdf.set_payload(open(os.getcwd()+"/Reporte_Actividades_Mercaderias_"+str(datetime.now().isocalendar()[1])+".pdf", "rb").read())
encoders.encode_base64(part_pdf)
part_pdf.add_header('Content-Disposition', 'attachment; filename="Reporte_Actividades_Mercaderias_'+str(datetime.now().isocalendar()[1])+'.pdf"')
msg.attach(part_pdf)

part_xls = MIMEBase('application', "octet-stream")
part_xls.set_payload(open(os.getcwd()+"/Reporte_Actividades_Mercaderias_"+str(datetime.now().isocalendar()[1])+".xls", "rb").read())
encoders.encode_base64(part_xls)
part_xls.add_header('Content-Disposition', 'attachment; filename="Reporte_Actividades_Mercaderias_'+str(datetime.now().isocalendar()[1])+'.xls"')
msg.attach(part_xls)

part_pdf = MIMEBase('application', "octet-stream")
part_pdf.set_payload(open(os.getcwd()+"/Reporte_Actividades_Financieros_"+str(datetime.now().isocalendar()[1])+".pdf", "rb").read())
encoders.encode_base64(part_pdf)
part_pdf.add_header('Content-Disposition', 'attachment; filename="Reporte_Actividades_Financieros_'+str(datetime.now().isocalendar()[1])+'.pdf"')
msg.attach(part_pdf)

part_xls = MIMEBase('application', "octet-stream")
part_xls.set_payload(open(os.getcwd()+"/Reporte_Actividades_Financieros_"+str(datetime.now().isocalendar()[1])+".xls", "rb").read())
encoders.encode_base64(part_xls)
part_xls.add_header('Content-Disposition', 'attachment; filename="Reporte_Actividades_Financieros_'+str(datetime.now().isocalendar()[1])+'.xls"')
msg.attach(part_xls)

part_pdf = MIMEBase('application', "octet-stream")
part_pdf.set_payload(open(os.getcwd()+"/Reporte_Actividades_Telcos_"+str(datetime.now().isocalendar()[1])+".pdf", "rb").read())
encoders.encode_base64(part_pdf)
part_pdf.add_header('Content-Disposition', 'attachment; filename="Reporte_Actividades_Telcos_'+str(datetime.now().isocalendar()[1])+'.pdf"')
msg.attach(part_pdf)

part_xls = MIMEBase('application', "octet-stream")
part_xls.set_payload(open(os.getcwd()+"/Reporte_Actividades_Telcos_"+str(datetime.now().isocalendar()[1])+".xls", "rb").read())
encoders.encode_base64(part_xls)
part_xls.add_header('Content-Disposition', 'attachment; filename="Reporte_Actividades_Telcos_'+str(datetime.now().isocalendar()[1])+'.xls"')
msg.attach(part_xls)

# Reporte Indicadores de Rendimiento (Fabi) Pdf y Xls

part_pdf = MIMEBase('application', "octet-stream")
part_pdf.set_payload(open(os.getcwd()+"/Reporte_Indicadores_Rendimiento_"+str(datetime.now().isocalendar()[1])+".pdf", "rb").read())
encoders.encode_base64(part_pdf)
part_pdf.add_header('Content-Disposition', 'attachment; filename="Reporte_Indicadores_Rendimiento_'+str(datetime.now().isocalendar()[1])+'.pdf"')
msg.attach(part_pdf)

part_xls = MIMEBase('application', "octet-stream")
part_xls.set_payload(open(os.getcwd()+"/Reporte_Indicadores_Rendimiento_"+str(datetime.now().isocalendar()[1])+".xls", "rb").read())
encoders.encode_base64(part_xls)
part_xls.add_header('Content-Disposition', 'attachment; filename="Reporte_Indicadores_Rendimiento_'+str(datetime.now().isocalendar()[1])+'.xls"')
msg.attach(part_xls)

username = 'reportes.ctin.infraestructura@gmail.com'
password = 'UmVwb3J0ZXMuQ1RJTi5JbmZyYWVzdHJ1Y3R1cmEK'
server = smtplib.SMTP('smtp.gmail.com:587')
server.ehlo()
server.starttls()
server.login(username,password)
server.sendmail(fromaddr, toaddrs, msg.as_string())
server.quit()