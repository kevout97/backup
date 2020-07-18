from Nexus import Nexus

nexus = Nexus("admin","abcd1234","http://10.23.143.8:8081")
lista_imagenes = nexus.getAllImages()
print(lista)
print("\nTamanio: %d" % (len(lista)))

# lista = []
# lista = n.getRepositories()
# print(lista)

nexus.deleteAllImagesByRepository("registry")
# nexus.deleteImageById("cmVnaXN0cnk6MTNiMjllNDQ5ZjBlM2I4ZDkyMjIyNDhjMDM4YTM1MTM")
# nexus.deleteImageById("cmVnaXN0cnk6MGFiODBhNzQzOTIxZTQyNmZjZjNlZWVkZmIwN2ZkMDQ")

lista = []
lista = n.searchTasksCleanDocker()
for x in range(0,len(lista["items"])):
    n.runTaskById(lista["items"][x]["id"])

lista = []
lista = n.searchTasksCleanBlob()
for x in range(0,len(lista["items"])):
    n.runTaskById(lista["items"][x]["id"])

lista = []
lista = n.getAllImages()
print(lista)
print("\nTamanio: %d" % (len(lista)))

# lista = []
# lista = n.getAllImages()
# if lista:
#     print(lista)
#     print("\nTamanio: %d" % (len(lista)))
