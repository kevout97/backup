# Administración de Credenciales en Jenkins

El script para la administración de credenciales, acepta las siguientes opciones, (dichas opciones son visibles con la bandera **-h** o **--help**):

```bash
Options:
-h, --help                                                      Show brief help
--user=USER, --user USER                                        User to connect to Jenkins
--password=PASSWORD, --password PASSWORD                        Password to connect to Jenkins
--host=PASSWORD, --host PASSWORD                                Host where is Jenkins (E.g. https://jenkins.example.com)
--id=ID, --id ID                                                User id to modify
--domain=DOMAIN, --domain DOMAIN                                Domain where are credentials (Default: _)
--new-username=USERNAME, --new-username USERNAME                New username
--new-password=PASSWORD, --new-password PASSWORD                New password
--new-scope=SCOPE, --new-scope SCOPE                            New scope
--new-description=DESCRIPTION, --new-description DESCRIPTION    New description, NOTE: Put it in quotes
--new-id=ID, --new-id ID                                        New id
``` 

Es importante señalar que las opciones **--host**, **--user**, **--password** y **--id** son opciones obligatorias, de lo contrario el script no funcionará.

Para el caso de la bandera **--host** es importante especificar el protocolo, ya sea http o https.

En caso de querer modificar la descripción de la credencial, es importante que dicha descripción se encuentre entre comillas.

Otro aspecto a considerar, es que el usuario colocado en la bandera **--user** deberá tener los permisos suficientes para la administración de credenciales, caso contrario el script también fallará.

A continuación se muestra un ejemplo de ejecución del script

```bash
$ ./jenkinsManageCredentials.sh --id jon.doe1556 --host https://jenkins.san.gadt.amxdigital.net --user amxga --password abcd1234 --new-description "Nueva descripcion Jon" --new-username jhon.doe
```
