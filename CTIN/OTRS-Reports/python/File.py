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