from TestRedis import TestRedis
from argparse import ArgumentParser
import time

# Ejemplo de ejecucion
# python main.py --host 127.0.0.1 --password mypassword -i 500

parser = ArgumentParser(description='%(prog)s Pruebas Redis')
# Argumentos
parser.add_argument('--host',help='Host of Database', type=str, default="127.0.0.1")
parser.add_argument('-p','--port',help='Port of Database', type=str, default=6379)
parser.add_argument('-db','--database',help='Index of Database', type=int, default=0)
parser.add_argument('--password',help='Password of Database', type=str, default=None)
parser.add_argument('-i','--inserts',help='Number of inserts', type=int, default=1)
args = parser.parse_args()

# Datos para la conexion con Redis
host = args.host
port = args.port
password = args.password
db = args.database
inserts = args.inserts

# Iniciamos una conexion
testRedis = TestRedis(host,port,password,db)
testRedis.connect()

# Insertamos datos
inicio_de_tiempo = time.time()

for i in range(0,inserts):
    key = "key_" + str(i)
    value = "value_key_" + str(i)
    testRedis.setKey(key,value)

tiempo_final = time.time()
tiempo_transcurrido = tiempo_final - inicio_de_tiempo
print "La insercion de datos tomo %d segundos." % (tiempo_transcurrido)

# Verificamos que los datos se hayan insertado
print "Total de datos que hay en la base de datos: %d " % (testRedis.getSize())

# Ejemplo de dato insertado
print "Ultimo dato insertado %s:%s " % (key,testRedis.getKey(key))