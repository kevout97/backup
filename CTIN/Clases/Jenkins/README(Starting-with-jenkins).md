# -Starting-with-Jenkins
starting with the continuous integration of jenkins
# JENKINS 

![logo](https://user-images.githubusercontent.com/42847572/45058899-b03d7700-b05f-11e8-8fa8-35256d339f5f.png)

## Qué es?

Jenkins es un servidor de integración continua, gratuito, open-source y actualmente uno de los más empleados para esta función. 

## Qué ofrece?

Ofrece la integración continua que es una práctica de desarrollo de software donde los miembros del equipo integran su trabajo frecuentemente.

## Cómo funciona?

Cada integración se verifica compilando el código fuente y obteniendo un ejecutable (a esto se le llama build, y debe hacerse de forma automatizada).Además también se pasan las pruebas y métricas de calidad para detectar los errores tan pronto como sea posible.

Al integrar frecuentemente el código, puedes saber el estado del software en todo momento. Saber qué funciona, qué no y qué errores hay. También puedes monitorizar la calidad del código y su cobertura de pruebas.

La base de Jenkins son las tareas, donde indicamos qué es lo que hay que hacer en un build. Por ejemplo, podríamos programar una tarea en la que se compruebe el repositorio de control de versiones cada cierto tiempo, y cuando un desarrollador quiera subir su código al control de versiones, este se compile y se ejecuten las pruebas.

Si el resultado no es el esperado o hay algún error, Jenkins notificará al desarrollador, al equipo de QA, por email o cualquier otro medio, para que lo solucione. Si el build es correcto, podremos indicar a Jenkins que intente integrar el código y subirlo al repositorio de control de versiones.

Actúa como herramienta que sirve de enlace en todo el proceso de desarrollo.

Desde Jenkins podrás indicar que se lancen métricas de calidad y visualizar los resultados dentro de la misma herramienta. También podrás ver el resultado de los tests, generar y visualizar la documentación del proyecto o incluso pasar una versión estable del software al entorno de QA para ser probado, a pre-producción o producción.

## Cómo es la arquitectura de Jenkins?

## 1) Ejemplo:
![diagrama-de-pasos-a-produccion](https://user-images.githubusercontent.com/42847572/45843360-060f5180-bce5-11e8-915e-7f4cb1023e5b.png)

## 2) Ejemplo:
![jenkinsic](https://user-images.githubusercontent.com/42847572/45843362-060f5180-bce5-11e8-9191-e5e03ab1e947.png)

## Usos:

Existen 3 formas de desplegar aṕlicaciones en jenkins
1. Despliegue de forma local
            Manejo de archivos de la VM directamente  (manejo del sistema de archivos etc, var)

![figura1](https://user-images.githubusercontent.com/42847572/45058805-681e5480-b05f-11e8-95ad-ba2d25c7996c.png)

2. Despliegue de forma remota
Comunicarse con las máquinas virtuales a través de ssh

![figura2](https://user-images.githubusercontent.com/42847572/45058806-681e5480-b05f-11e8-86a9-c02c9e219f06.png)

3. Despliegue por JNLP
levantar
conectar
controlar de forma local
compila
lo guarda en zip
docker img (dockerfile)

![figura3](https://user-images.githubusercontent.com/42847572/45058808-681e5480-b05f-11e8-92be-ff06a2339c2e.png)

## Cuál es la diferencia entre Job y pipeline?

Existen 3 diferencias principalmente:

### 1. Mantenibilidad
El Job que compone nuestro flujo se almacena junto al código. Con ello, se vuelve mucho más mantenible, ya que es modificable por cualquier desarrollador que tenga acceso al repositorio.
También ganamos todo el potencial que nos proporcionan Github, Bitbucket o cualquier herramienta similar, como ver el histórico de cambios, versionado del fichero…
La mantenibilidad y versionado es uno de los principales pilares cuando hablamos de Pipelines, pero algunos ya teníamos esto sin necesidad de ellos.
¿Qué ocurre si usamos un job típico de Jenkins, que llame a un script que a su vez ejecute cada uno de los comando necesarios de nuestro flujo? Que si almacenamos este script junto al código tenemos la misma mantenibilidad, control de versionado… que conseguimos con los Jobs.
En los Jobs no sólo almacenamos comandos necesarios. A parte de esto, podemos añadir muchos más elementos como: gestión de credenciales, ficheros, uso de plugins… que antes pertenecían más a la propia configuración del job.

### 2. Flexibilidad
Jenkins ofrece gran variedad de plugins que ayudan con las tareas más comunes. Los pipelines son compatibles con la gran mayoría de ellos y nos aportan una gran mejoría.
Al ser programáticos permiten controlar mejor los escenarios y añadir nuevas variantes que eran imposibles hasta ahora.
Esto tiene un punto negativo. Muchas veces es mucho más engorroso definir una una tarea usando un plugin desde un Job, de lo que lo era usando el mismo plugin desde la interfaz de Jenkins.

### 3. Visibilidad
Ofrecen una visualización completa de forma atractiva e intuitiva dándonos un feedback rápido del proceso. De un vistazo puede detectarse si hay algún problema y en qué parte de nuestro pipeline ha sucedido.
También ganamos gran visibilidad de los resultados a la hora de ver los logs. Podemos acceder a los de cada fase de forma individual sin tener que sumergirnos en los largos logs de salida de la consola. Gracias a esto ahorramos mucho tiempo a la hora localizar un error en la ejecución.
Para acceder a los logs solo hay que situarse sobre el stage del que queramos consultaros y hacer un clic.

## Cuántos tipos de jobs existen? 
### 1. Free style
### 2. Maven
### 3. Pipeline
### 4. External task
### 5. Multiconfiguration
### 6. MultiJob project
### 7. Folder
### 8. Multibranch pipeline

## Cuál es el uso de cada Job? 

### 1. Free style
Ejecuta el proyecto combinando cualquier tipo de repositorio de software (SCM) con cualquier modo de construcción o ejecución (make, ant, mvn, rake, script ...). Por tanto se podrá tanto compilar y empaquetar software, como ejecutar cualquier proceso que requiera monitorización

### 2. Maven
Ejecuta un proyecto maven. Jenkins es capaz de aprovechar la configuracion presente en los ficheros POM, reduciendo drásticamente la configuración.

### 3. Pipeline
Orquesta actividades de larga ejecución que pueden abarcar múltiples agentes de compilación. Adecuado para la construcción de tuberías (anteriormente conocidas como flujos de trabajo) y / u organización de actividades complejas que no se ajustan fácilmente al tipo de trabajo de estilo libre.

### 4. External task
Este tipo de tarea permite registar la ejecución de procesos que se ejecutan externamente a Jenkins, incluso en máquinas remotas. Está diseñado para que puedas utilizar Jenkins como un panel de control para tus sistemas de automatización de procesos.

### 5. Multiconfiguration
Adecuado para proyectos que requieran un gran número de configuraciones diferentes, como testear en multiples entornos, ejecutar sobre plataformas concretas, etc.

### 6. MultiJob project
Proyecto MultiJob, adecuado para ejecutar otros trabajos

### 7. Folder
Crea un contenedor que almacena elementos anidados en él. Útil para agrupar cosas. A diferencia de la vista, que es solo un filtro, una carpeta crea un espacio de nombre separado, por lo que puede tener varias cosas del mismo nombre, siempre y cuando estén en diferentes carpetas.

### 8. Multibranch pipeline
Crea un conjunto de proyectos Pipeline de acuerdo con las ramas detectadas en un repositorio SCM.

## Instalación ( Pasos a seguir) :
1. Instalar jenkins
2. instalar plugins
3. Conectar jenkins con el API de docker
4. Construir JNLP slaves
5. Pruebas
6. Realizar proyectos
7. Pipelines

### Paso 1: Instalar Jenkins

       a) Entrar a jenkins
       b) Crear un directorio en var/conteiners/jenkins
       c) Correr el comando :
          docker run -p 8080:8080 -p 5050:5050 -v /var/conteiners/jenkins -td
       d) Dar permisos al directorio
          chown 1000:1000 -R /var/conteiners/jenkins
       e) Ver estado del contenedor
          docker logs -f

### Paso 2: Instalar plugins 
      a) Ingresar al dominio
         https://jenkins.ctin.amxdigital.net
      b) Configurar el proxy
          Servidor -> 10.0.202.7
          Puerto -> 80:80
      c) Seleccionar plugins
         (seleccionar todos los plugins que se desean instalar)

     d) Crear primer usuario 

### Paso 3: Conectar con el Api docker

     a) Dentro de jablab
     b) Dentro de build
     c) abrir el archivo:
        vi  /etc/sysconfig/doker
        dentro hay que vandear todas las interfaces de docker 
        OPTIONS='--selinux-enabled -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2376'
     d) Reiniciar el servidor
         systemctl restart docker
     e) Revisar
         netstat -pantu

**NOTA: En caso de que aparezca la leyenda “No route to host” significa que esta prendido el firewall y me esta bloqueando**

**Solucion:**
*systemctl stop firewall
*systemctl restart docker 


### Paso 4: Construir JNLP slaves

      a) Dentro de builder
      b) Crear un directorio 
         mkdir -p /opt/Docker-files 
      c) Dentro de directorio, habra que descomprimir el archivo -->  slaves.tgr.gz
      d) Entrar a las carpetas:

      Entrar a --> centos73_base

      Entrar a --> O_openjdk8

      dentro contruir el dokerfile
      docker build -t openjdk:8-jdk --build-arg http_proxy=http://10.0.202.7:8080 --build-arg  https_proxy=https://10.0.202.7:8080 .

      Entrar a --> cd 1-openjdk8
      docker build -t jenkins/slave:3.16-1 --build-arg http_proxy=http://10.0.202.7:8080 --build-arg https_proxy=https://10.0.202.7:8080 .


      Entrar a --> cd 2-openjdk8.
      docker build -t ctin-slaves --build-arg http_proxy=http://10.0.202.7:8080 --build-arg https_proxy=https://10.0.202.7:8080 .


### Paso 5: Configurar la nube (Decirle a jenkins como comunicarse con esclavos)

      a) Dentro de jenkins
         administrar jenkins/ configurar el sistem/ añadir una nueva nube

         Name: dockernube
         Docker HostURL: tcp://10.0.57.32:2376
         Conteiner cap:5
         Docker images:ctin slaves
         Connect method: conect with JNLP
         Jenkins URL: https://jenkins.ctin.amxdigital.net/
         Establecer un tunel a travez de:
         10.0.8.152:50000
         Label: workers
         Extrahosts: https://jenkins.ctin.amxdigital.net:10.0.8.204

## Cómo verificar el funcionamiento de builder y slaves?
Verificar con el comando:
netstat-pantu
Marcará el siguiente error "NO ROUTE TO HOST"
Lo que en realidad nos esta diciendo es que el firewall esta prendido y nos esta bloqueando
A lo que se deberá realizar lo siguiente:
1. Detener el firewall: 
*systemctl stop firewall*
2. Reiniciar Docker: 
*systemctl restart docker*

Con estos pasos ya no existiria problema y el funcionamiento de builder y slaves, sería el correcto.

## Qué opciones ocupamos al construir un job y un slave?
1. Dentro de jenkins seleccionamos la opcion new item
![sin titulo0](https://user-images.githubusercontent.com/42847572/45972047-48e06a80-c000-11e8-94af-71f690857070.png)
2. Una vez dentro de esta opcion, escribiremos el nombre de nuestro Job y seleccionaremos "Freestyle project"
![sin titulo](https://user-images.githubusercontent.com/42847572/45972046-48e06a80-c000-11e8-8432-203492d5188e.png)
3. Seleccionamos las opciones marcadas en la imagen para permitir el intercambio de archivos y decir en que esclavos queremos que se ejecute el JOB.
![sin titulo1](https://user-images.githubusercontent.com/42847572/45972048-48e06a80-c000-11e8-9471-0402614886a0.png)
4. Una vez creado, se selecciona la opcion marcado en la imagen para lanzar el JOB 
![sin titulo3](https://user-images.githubusercontent.com/42847572/45973340-cce82180-c003-11e8-8357-c06a2d823e0b.png)


## Qué comandos precompilación y  pos compilación existen? 
### Precompilación

1. **create-view:**	Crea una nueva vista leyendo stdin como una configuración XML. &nbsp;
2. **create-node:**	Crea un nuevo nodo leyendo stdin como una configuración XML.&nbsp;
3. **create-job:**          Crea un nuevo trabajo leyendo stdin como un archivo XML de configuración.
4. **create-credentials-domain-by-xml:**	Crear credenciales de dominio por XML
5. **create-credentials-by-xml:**	Crear Credencial por XML
6. **copy-job:**	Copia un trabajo.
7. **build:**	Crea un trabajo y, opcionalmente, espera hasta su finalización.
8. **enable-job:**	Habilita un trabajo.
9. **enable-plugin:**	Permite uno o más complementos instalados de forma transitiva.
10. **get-credentials-as-xml:**	Obtenga una credencial como XML (secretos redactados)
11. **get-credentials-domain-as-xml:**	Obtener un dominio de credenciales como XML
12. **set-build-parameter:**	Actualiza / establece el parámetro de compilación de la compilación actual en progreso
13. **update-credentials-by-xml:**	Actualizar credenciales por XML
14. **update-credentials-domain-by-xml:**	Actualizar credenciales de dominio por XML
15. **update-job:**	Actualiza la definición del trabajo XML de stdin. Lo opuesto al comando get-job.
16. **update-node:**	Actualiza la definición del nodo XML de stdin. Lo opuesto al comando get-node.
17. **update-view:**	Actualiza la definición de vista XML desde stdin. Lo opuesto al comando get-view.
18. **wait-node-offline:**	Espere a que un nodo esté fuera de línea.
19. **set-build-result:**	Establece el resultado de la compilación actual. Funciona solo si se invoca desde una compilación.

### Poscompilación

1. **delete-builds:**	Elimina registro (s) de compilación.
2. **delete-credentials:**	Eliminar una credencial
3. **delete-credentials-domain:**	Eliminar un dominio de credenciales
4. **delete-job:**	Elimina trabajo (s).
5. **delete-node:**	Elimina nodo (s)
6. **delete-view:**	Elimina vista (s).
7. **disable-job:**	Desactiva un trabajo.
8. **disconnect-node:**	Se desconecta de un nodo.
9. **connect-node:**	Vuelva a conectar a un nodo (s)
10. **console:**	Recupera la salida de consola de una compilación.
11. **who-am-i:**	Informa tu credencial y permisos.
12. **set-external-build-result:**	Establezca el resultado del trabajo del monitor externo. 
13. **set-build-display-name:**	Establece la displayName de una compilación.
14. **set-build-description:**	Establece la descripción de una construcción.
15. **replay-pipeline:**	Reproducir una compilación de Pipeline con un guión editado tomado de una entrada estándar
16. **remove-job-from-view:**	Elimina los trabajos de la vista.
17. **reload-job:**	Recargar trabajo (s)
18. **list-changes:**	Devuelve el registro de cambios para la (s) compilación (es) especificada (s).
19. **get-job:**	Devuelve la definición de trabajo XML a stdout.
20. **get-node:**	Devuelve la definición de nodo XML a stdout.
21. **get-view:**	Devuelve la definición de vista XML a stdout.
	

## Qué hacer si un JOB que clona un repositorio y hace un commit no funciona, como repararlo? 
Primero habria que revisar los 3 pilares principales para  la clonacion de un repositorio Git.
1. Dentro del JOB en su apartado de configuración, tener la opción "Copy artifact" para permitir la clonacion que queremos realizar.
2. Revisar nuestra credencial de identificación, dependiendo el tipo de identificacion que tengamos, habra que checar su funcionalidad.
3. Revisar que el nombre y la dirección del repositorio que queremos clonar este escrito de una forma correcta.

## EJERCICIOS PROPUESTOS

### Intercambiar archivos entre esclavo - host
1. Crear llave al usuario:
Estando en el menu principal de jenkins, seleccionaremos la opcion "Credencials"
![1](https://user-images.githubusercontent.com/42847572/45977495-71bc2c00-c00f-11e8-9bb8-c68a214c0933.png)
Una vez dentro de la opción, podremos visualizar las llaves existentes, nos posicionaremos en la principal y seleccionaremos la opcion, "añadir credencial"
![2](https://user-images.githubusercontent.com/42847572/45978277-8e596380-c011-11e8-90ca-e8d5092d14fd.jpg)
Una vez dentro, se podra visualizar un formulario a llenar con la información que queremos para la nueva credencial
![3](https://user-images.githubusercontent.com/42847572/45978278-8e596380-c011-11e8-9d8d-bbbc0c5e43d9.jpg)
Seleccionamos el tipo de llave ssh y llenamos todos los campos con su respectiva información
![4](https://user-images.githubusercontent.com/42847572/45978279-8e596380-c011-11e8-850c-d339a092deda.jpg)
![5](https://user-images.githubusercontent.com/42847572/45978280-8e596380-c011-11e8-800b-e55d79739005.jpg)
Con esto quedará creada nuestra nueva credencial que se ocupará mas adelante
2. Configurar la opción ssh en Jenkins:
Situados nuevamente en el menu principal de Jenkins, seleccionaremos la opción "Manage Jenkins"
![6](https://user-images.githubusercontent.com/42847572/45978281-8ef1fa00-c011-11e8-84f7-4b28200538c9.jpg)
Ahora se nos presentara otro menu, en esta ocación seleccionaremos la opción "Configure system"
![7](https://user-images.githubusercontent.com/42847572/45978282-8ef1fa00-c011-11e8-8634-fe7c74e7ee4b.jpg)
Dentro de ese apartado, buscaremos la opción "SSH remote hosts", lo habilitamos y llenamos los campos correspondientes. Tendremos que colocar el nombre del host al que se va a conectar, asi como el puerto por el cual lo hará y la credencial que creamos anteriormente.
![8](https://user-images.githubusercontent.com/42847572/45978283-8ef1fa00-c011-11e8-97fa-3be983e88eff.jpg)
Seguiremos bajando hasta localizar la opción "Publish over SSH" en donde colocaremos la llave privada del usuario dentro del servidor al que queremos conectarnos, asi como el nombre del servidor
![9](https://user-images.githubusercontent.com/42847572/45978284-8ef1fa00-c011-11e8-8d1f-47e15e7c32c7.jpg)
![10](https://user-images.githubusercontent.com/42847572/45978285-8ef1fa00-c011-11e8-8919-cd3cd0b1c546.jpg)
Una vez realizado esto estará establecida nuestra configuraci+on en Jenkins

3. Configurar la opcion ssh dentro de la configuración del JOB

Situados dentro del Job que creamos, nos vamos a la opcion "Configuración"
![sin titulo4](https://user-images.githubusercontent.com/42847572/45980469-b350d500-c017-11e8-91c4-aee7a6397b09.png)
Dentro del apartado configuración buscaremos la opción "Send files or execute commands over SSH before the build starts" y la habilitaremos, dentro de esta colocaremos el nombre del archivo que queremos enviar, asi como el nombre del servidor, y si es que queremos ejecutar algun comando cuando se lance el JOB.
![ultima](https://user-images.githubusercontent.com/42847572/45980846-b5fffa00-c018-11e8-9ea3-9d224587d50c.png)
Una vez guardados los cambios, lanzaremos el JOB, cuando termine iremos al partado "CONSOLE OUTPUT" y visualizaremos que el archivo se envio correctamente.
![sin titulo 3png](https://user-images.githubusercontent.com/42847572/45980468-b350d500-c017-11e8-9b49-3009d18d29c1.png)
De esta forma queda completado el envió de archivos


### Como me traigo código al interior del esclavo
1. Una vez creado el JOB, dentro de el, en el apartado de configuracion, seleccionaremos la opcion marcado en la immagen para poder añadir el repositorio de git que queremos enviar, despues de esto habra que guardar los cambio y lanzar de nuevo el JOB.
![sin titulo2](https://user-images.githubusercontent.com/42847572/45974262-7c25f800-c006-11e8-8bb5-e76e5bbbe8fa.png)
2. Al término del lanzamiento del JOB, dentro de este, seleccionaremos la opcion "CONSOLE OUTPUT" para visualizar que se realizó de una forma correcta como en la siguiente imagen.
![2](https://user-images.githubusercontent.com/42847572/45974261-7c25f800-c006-11e8-9a6c-7355511ce57a.png)

### Montar volúmenes entre el esclavo y el builder

## Ejemplo práctico
El equipo de Claro Cobras pide realizar ajustes al código de su página principal utilizando la tarea jenkins. 
El esclavo debe traer el código del siguiente repositorio.........y modificar el archivo "index.html" para modificar el nombre de la marca de "ClaroCobras" a "Claro Cobras". 
Una vez que se realice la modificación del código, el esclavo debe enviar el sitio (el conjunto de HTMLs) al servidor JABLAB donde hay un vhost configurado ....... en el directorio ....... y debe verse la modificación realizada al interior del esclavo
Nol olvidar que debe recargar la configuración de nginx mediante el comando : *nginx -s reload* al interior de JABLAB



