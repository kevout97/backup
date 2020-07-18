# pip install redis
import random
import string
import sys
import redis

class TestRedis:

    def __init__(self,host,port,password=None,db=0):
        self.host = host
        self.port = port
        self.password = password
        self.db = db
            
    def connect(self):
        try:
            if self.password is not None:
                self.r = redis.Redis(host=str(self.host), port=self.port,password=str(self.password),db=self.db)
            else:
                self.r = redis.Redis(host=str(self.host), port=self.port,db=self.db)
            print "Established connection"
        except:
            print "An error occurred when establishing the connection to the Database"

    def setKey(self,key,value):
        self.r.set(str(key),str(value))
    
    def getKey(self,key):
        return self.r.get(str(key))

    
    def deleteKey(self,key):
        self.r.delete(str(key))
    
    def dropDatabase(self):
        self.r.flushdb()
    
    def getSize(self):
        return self.r.dbsize()