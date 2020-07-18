# Ejercicio Jenkins
El problema es el siguiente:

*El equipo de Claro Cobras nos pide realizar ajustes al código de su página principal utilizando la tarea jenkins. El esclavo debe traer el código del siguiente repositorio.........y modificar el archivo "index.html" para modificar el nombre de la marca de "ClaroCobras" a "Claro Cobras". Una vez que se realice la modificación del código, el esclavo debe enviar el sitio (el conjunto de HTMLs) al servidor JABLAB donde hay un vhost configurado ....... en el directorio ....... y debe verse la modificación realizada al interior del esclavo*

A continuación se muestra una propuesta de solución a dicho problema:

## Creación de la tarea.
Como primer punto procederemos a crear una tarea en blanco.
Desde el panel de control seleccionamos **Nueva Tarea**

![Creación de Tarea](jenkins_imagenes/ejercicio_jenkins/creacion_tarea.png)

A continuación le asignamos un nombre y seleccionamos la opción de **Crear un proyecto de estilo libre**

![Nombre Tarea](jenkins_imagenes/ejercicio_jenkins/nombre_tarea.png)

Damos click en **Ok** y tendremos creada nuestra primer tarea.

## Clonar un repositorio

Para poder clonar un repositorio ingresamos a nuestra tarea, y una vez dentro seleccionamos la opción de **Configurar**

![Configurar](jenkins_imagenes/ejercicio_jenkins/configurar.png)

A contincuación nos situamos en el apartado **Configurar el origen del código fuente** y seleccionamos *Git*

**NOTA:** Para este ejercicio clonaremos el siguiente repositorio https://gitlab.ctin-uat.amxdigital.net/berryrreb/NGINX.git

En la opción **Repository URL** colocamos la URL del repositorio que se desea clonar.

![Clonar repo](jenkins_imagenes/ejercicio_jenkins/clonar_repo.png)

Enseguida damos click en **Guardar** y procedemos a construir la tarea

![Construir tarea](jenkins_imagenes/ejercicio_jenkins/construir_ahora.png)

Esperamos a que la tarea termine de construirse.

![Termino de la construccion](jenkins_imagenes/ejercicio_jenkins/tarea1.png)

Verificamos en la salida de la tarea, que el repositorio se haya clonado.

![Salida Tarea1](jenkins_imagenes/ejercicio_jenkins/salida1.png)

Al igual que en el espacio de trabajo de la tarea.

![Espacio de trabajo](jenkins_imagenes/ejercicio_jenkins/workspace1.png)

## Transferencia de Archivos

Para transferir un archivo, seleccionamos nuevamente la opcion de **Configurar** de dicha tarea.

![Configurar](jenkins_imagenes/ejercicio_jenkins/configurar.png)

Situados en el apartado **Entorno de Ejecución** seleccionamos la opción de *Send files or execute commands over SSH before the build starts*.
En la parte de **Source files** indicamos el nombre del archivo del espacio de trabajo que deseamos enviar, en nuestro caso *Index.html*

![Entorno Ejecucion](jenkins_imagenes/ejercicio_jenkins/entorno_ejecucion.png)

Damos click en **Guardar** y construimos el proyecto.

![Tarea2](jenkins_imagenes/ejercicio_jenkins/tarea2.png)

Una vez finalizada la construcción verificamos que el archivo se haya enviado correctamente.

![Salida2](jenkins_imagenes/ejercicio_jenkins/salida2.png)

## Ejecución de Comandos en un servidor remoto

Para este ejercicio copiaremos el archivo transferido al servidor remoto.

Nuevamente seleccionamos la opción de **Configurar** 

![Configurar](jenkins_imagenes/ejercicio_jenkins/configurar.png)

Situados en el apartado **Entorno de Ejecución** seleccionamos la opción de *Execute shell script on remote host using ssh*.

Para este ejemplo los comandos que ejecutaremos en el servidor remoto (Jablab) son:

```bash
sudo chown root:root /home/jenkins/index.html
sudo cp /home/jenkins/index.html /var/containers/nginx/etc/nginx/vhosts/
```

![Ejecutar comando](jenkins_imagenes/ejercicio_jenkins/ejecutar_comando.png)

Damos click en **Guardar** y procedemos a construir la tarea.

![Tarea3](jenkins_imagenes/ejercicio_jenkins/tarea3.png)

A continuación verificamos que la tarea se haya ejecutado correctamente.

![Salida3](jenkins_imagenes/ejercicio_jenkins/salida3.png)

Finalmente visualizamos la pagina en el navegador.

![Pagina](jenkins_imagenes/ejercicio_jenkins/pagina.png)
http://prueba.jenkins.digital.net/

## Issues.
* Añadir en el archivo **/etc/hosts** la siguiente entrada:

```bash
201.161.97.8 prueba.jenkins.digital.net
```
* Jenkins al momento de ejecutar el comando **mv** rompe los permisos del archivo, por lo que la forma de transferir archivos entre directorios es a traves de **cp**

* Para nuestro caso es necesario cambiar el usuario y el grupo de los archivos a **root:root** ya que son el único grupo y usuario que el contendor de **nginx** conoce internamente.