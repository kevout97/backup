import requests
import json

class Nexus:

    # Constructor de la clase, recibe user, password y host del Nexus (ej. http://10.23.143.8:8081) para conectarse a Graylog
    def __init__(self,username,password,host):
        self.username = username
        self.password = password
        self.host = host
    
    # Devuelve todos los repositorios tipo Docker en una lista
    """
    Ejemplo de Salida
    [{u'url': u'http://10.23.143.8:8081/repository/registry', u'attributes': {}, u'type': u'hosted', u'name': u'registry', u'format': u'docker'}]
    """
    def getRepositories(self):
        url = self.host + "/service/rest/v1/repositories"
        try:
            response = requests.get(url, auth=(str(self.username), str(self.password)))
            data_response = json.loads(response.content)
            repositories_list = []
            for x in range(0,len(data_response)):
                if data_response[x]["format"] == "docker":
                    repositories_list.append(data_response[x])
            return repositories_list
        except:
            return None

    # Elimina un Asset a partir de su Id
    def deleteAssetById(self,idAsset):
        url = self.host + "/service/rest/v1/assets/" + str(idAsset)
        try:
            response = requests.delete(url, auth=(str(self.username), str(self.password)))
            return True
        except:
            return False
    
    # Busca todos los Tasks del tipo "Docker - Delete unused manifests and images"
    def searchTasksCleanDocker(self):
        url = self.host + "/service/rest/v1/tasks?type=repository.docker.gc"
        try:
            response = requests.get(url, auth=(str(self.username), str(self.password)))
            data_response = json.loads(response.content)
            return data_response
        except:
            return None
    
    # Busca todos los Tasks del tipo "Admin - Compact blob store"
    def searchTasksCleanBlob(self):
        url = self.host + "/service/rest/v1/tasks?type=blobstore.compact"
        try:
            response = requests.get(url, auth=(str(self.username), str(self.password)))
            data_response = json.loads(response.content)
            return data_response
        except:
            return None
    
    # Corre todos los tasks de tipo "Docker - Delete unused manifests and images"
    def runTasksCleanDocker(self):
        try:
            list_task = self.searchTasksCleanDocker()
            for x in range(0,len(list_task["items"])):
                self.runTaskById(list_task["items"][x]["id"])
            return True
        except:
            return False
    
    # Corre todos los tasks de tipo "Admin - Compact blob store"
    def runTasksCleanBlob(self):
        try:
            list_task = self.searchTasksCleanBlob()
            for x in range(0,len(list_task["items"])):
                self.runTaskById(list_task["items"][x]["id"])
            return True
        except:
            return False

    # Ejecuta un Task en especifico, recibe como parametro el Id del Task
    def runTaskById(self,idTask):
        try:
            # url = self.host + "/service/rest/v1/tasks/" + str(tasks_list["items"][x]["id"]) +"/run"
            url = self.host + "/service/rest/v1/tasks/" + idTask +"/run"
            response = requests.post(url, auth=(str(self.username), str(self.password)))
            return True
        except:
            return False
    
    # Eimina todas las imagenes de todos los repositorios Docker
    def deleteAllImages(self):
        try:
            repositories_list = self.getRepositories()
            for x in range(0,len(repositories_list)):
                self.deleteAllImagesByRepository(repositories_list[x]["name"])
            return True
        except:
            return False
    
    # Eimina todas las imagenes de un repositorio en especifico, como parametro recibe el nombre del repositorio
    def deleteAllImagesByRepository(self,nameRepository):
        try:
            images_list = self.getImagesByRepository(nameRepository)
            for x in range(0,len(images_list)):
                self.deleteImageById(images_list[x]["Id"])
            assets_list = self.getAssetsByRepository(str(nameRepository))
            for x in range(0,len(assets_list["items"])):
                self.deleteAssetById(assets_list["items"][x]["id"])
            return True
        except:
            return False
    
    # Obtiene el Id de todos los Assets que hay en una imagen, como parametro recibe el id de la imagen (id del componente) 
    def getIdAssets(self,id):
        url = self.host + "/service/rest/v1/components/" + str(id)
        try:
            response = requests.get(url, auth=(str(self.username), str(self.password)))
            data_response = json.loads(response.content)
            assets_list = []
            for x in range(0,len(data_response["assets"])):
                assets_list.append({"Id_asset":str(data_response["assets"][x]["id"])})
            return assets_list
        except:
            return None
    
    # Obtiene todos los Assets que hay en un repositorio, como parametro recibe el nombre del repositorio
    def getAssetsByRepository(self,nameRepository):
        url = self.host + "/service/rest/v1/assets?repository=" + str(nameRepository)
        try:
            response = requests.get(url, auth=(str(self.username), str(self.password)))
            data_response = json.loads(response.content)
            return data_response
        except:
            return None
    
    # Obtiene la hora de creacion de una imagen, como parametro recibe la url del manifest de la imagen
    def getCreated(self,manifest):
        try:
            response = requests.get(manifest, auth=(str(self.username), str(self.password)))
            data_response = json.loads(response.content)
            return json.loads(data_response["history"][0]["v1Compatibility"])["created"]
        except:
            return None
    
    # Obtiene todas las imagenes que existen en todos los repositorios
    """
    Ejemplo de lo que devuelve
    [{'Created': '2019-12-04T16:49:37.923825726Z', 'Name': 'repository/claro/rhel7-light', 'Repository': 'claro', 'Id': 'cmVnaXN0cnk6MTNiMjllNDQ5ZjBlM2I4ZDYzZGU3YWFlYjY2Yjg1Y2U'}, 
    {'Created': '2019-12-04T16:50:05.499015845Z', 'Name': 'repository/amx/rhel7-light', 'Repository': 'amx', 'Id': 'cmVnaXN0cnk6MGFiODBhNzQzOTIxZTQyNmJjMDlhMTg2ZjcwYjY2MTQ'}]
    """
    def getAllImages(self):
        url = self.host + "/service/rest/v1/search?format=docker"
        try:
            response = requests.get(url, auth=(str(self.username), str(self.password)))
            data_response = json.loads(response.content)
            images_list = []
            for x in range(0,len(data_response["items"])):
                images_list.append({"Name":str(data_response["items"][x]["name"]),"Id":str(data_response["items"][x]["id"]),"Repository":str(data_response["items"][x]["repository"]),"Created":str(self.getCreated(data_response["items"][x]["assets"][0]["downloadUrl"]))})
            return images_list
        except:
            return None
    
    # Obtiene las imagenes que hay en un repositorio espefico, como parametro recibe el nombre del repositorio
    """
    Ejemplo de lo que devuelve
    [{'Created': '2019-12-04T16:49:37.923825726Z', 'Name': 'repository/registry/rhel7-light', 'Repository': 'registry', 'Id': 'cmVnaXN0cnk6MTNiMjllNDQ5ZjBlM2I4ZDYzZGU3YWFlYjY2Yjg1Y2U'}, 
    {'Created': '2019-12-04T16:50:05.499015845Z', 'Name': 'repository/registry/rhel7-light', 'Repository': 'registry', 'Id': 'cmVnaXN0cnk6MGFiODBhNzQzOTIxZTQyNmJjMDlhMTg2ZjcwYjY2MTQ'}]
    """
    def getImagesByRepository(self,nameRepository):
        url = self.host + "/service/rest/v1/search?format=docker&repository=" + str(nameRepository)
        try:
            response = requests.get(url, auth=(str(self.username), str(self.password)))
            data_response = json.loads(response.content)
            images_list = []
            for x in range(0,len(data_response["items"])):
                images_list.append({"Name":str(data_response["items"][x]["name"]),"Id":str(data_response["items"][x]["id"]),"Repository":str(data_response["items"][x]["repository"]),"Created":str(self.getCreated(data_response["items"][x]["assets"][0]["downloadUrl"]))})
            return images_list
        except:
            return None
    
    # Elimina una imagen a partir de su id
    def deleteImageById(self,id):
        try:
            assets_list = []
            assets_list = self.getIdAssets(str(id))
            for x in range(0,len(assets_list)):
                self.deleteAssetById(str(assets_list[x]["Id_asset"]))
            return True
        except:
            return False