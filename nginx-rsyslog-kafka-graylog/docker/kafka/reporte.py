# -*- coding: utf-8 -*-
import smtplib
import time
from datetime import datetime, date, time, timedelta
import os
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email import encoders
from Telegram import Telegram

telegram = Telegram("633793142:AAGNd-oWHS1pcARuaA7NWcW5-4fvFbJJPsQ")
idChat = "-347110562"
semana_inicio = 28
anio_inicio = 2019
num_reporte = (date.today().year - anio_inicio) * 52 - semana_inicio + datetime.now().isocalendar()[1]

fromaddr = 'Reportes OTRS'
toaddrs  = ['kevin.gomez@amxiniciativas.com','mauricio.melendez@amxiniciativas.com','edna.mora@amxiniciativas.com','patricio.dorantes@americamovil.com','ivan.alexander@amxiniciativas.com','fernando.martinez@amxiniciativas.com'] #Agregar los destinatarios deseados

#toaddrs  = ['kevin.gomez@amxiniciativas.com']

msg = MIMEMultipart()
msg['Subject'] = "Reporte semanal OTRS"
msg['From'] = "Reportes OTRS"
msg['To'] = ", ".join(toaddrs)

#message = "Envio de Reporte"
#msg.attach(MIMEText(message))

part_pdf = MIMEBase('application', "octet-stream")
part_pdf.set_payload(open("/opt/otrs-reports/Reporte_OTRS_"+str(num_reporte)+".pdf", "rb").read())
encoders.encode_base64(part_pdf)

part_pdf.add_header('Content-Disposition', 'attachment; filename="Reporte_OTRS_'+str(num_reporte)+'.pdf"')

msg.attach(part_pdf)


username = 'reportes@otrs.amxdigital.net '
password = '017Y6wLbTi8u'
server = smtplib.SMTP('mail.otrs.olympus.sps.com.mx:25')
server.ehlo()
#server.starttls()
server.login(username,password)
try:
  server.sendmail(fromaddr, toaddrs, msg.as_string())
  mensaje="⚠ REPORTE: Envio de correo."
  telegram.sendMessage(mensaje,idChat)
except:
  mensaje="⚠⚠ REPORTE: Error en la generación del reporte. ⚠⚠"
  telegram.sendMessage(mensaje,idChat)
server.quit()