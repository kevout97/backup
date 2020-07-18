#!/usr/bin/env python
# -*- coding: utf-8 -*-

from Nexus import Nexus
from collections import deque
import sys
import argparse

def checkArgs():
    if len(sys.argv) < 5:
        TAGSVALIDOS = 5
        return TAGSVALIDOS
    else:
        TAGSVALIDOS = int(sys.argv[4])
        return TAGSVALIDOS

# Tree class
class Arbol:
    def __init__(self, elemento):
        self.hijos = []
        self.elemento = elemento

# Function to add an element to the tree
def agregarElemento(arbol, elemento, elementoPadre):
    subarbol = buscarSubarbol(arbol, elementoPadre)
    subarbol.hijos.append(Arbol(elemento))

# Function to search an element on the tree
def buscarSubarbol(arbol, elemento):
    if arbol.elemento == elemento:
        return arbol
    for subarbol in arbol.hijos:
        arbolBuscado = buscarSubarbol(subarbol, elemento)
        if (arbolBuscado != None):
            return arbolBuscado
    return None

# Function to get the tree's deep
def profundidad(arbol):
    if len(arbol.hijos) == 0: 
        return 1
    return 1 + max(map(profundidad,arbol.hijos)) 

# Function to get the tree's grade
def grado(arbol):
    return max(map(grado, arbol.hijos) + [len(arbol.hijos)])

# Function to travel and print the tree by branches
def ejecutarProfundidadPrimero(arbol, funcion):
    funcion(arbol.elemento)
    for hijo in arbol.hijos:
        ejecutarProfundidadPrimero(hijo, funcion)

# Function to print an element on a tree
def printElement(element):
    print element

# Function to travel and print the tree by levels
def ejecutarAnchoPrimero(arbol, funcion, cola = deque()):
    funcion(arbol.elemento)
    if (len(arbol.hijos) > 0):
        cola.extend(arbol.hijos)
    if (len(cola) != 0):
        ejecutarAnchoPrimero(cola.popleft(), funcion, cola) 

# Function to verify if an image exists
def existeImagen(name):
    existe = 'no'
    for image in imagenes:
        if (name == image):
            existe = 'si'
    return existe

# Function to verify if a repository exists
def existeRepo(name):
    existe = 'no'
    for repo in repos:
        if (name == repo):
            existe = 'si'
    return existe

parser = argparse.ArgumentParser(description="Docker Images Life Cycle.")
parser.add_argument('--user', type=str,default="admin",help='Usuario Nexus (default: admin)')
parser.add_argument('--password', type=str,default="password",help='Password Nexus (default: admin)')
parser.add_argument('--host', type=str,default="http://127.0.0.1",help='Host Nexus (default: http://127.0.0.1)')
parser.add_argument('--images', type=int,default=5,help='Numero de versiones validas por imagen (default: 5)')
args = parser.parse_args()

user = args.user
password = args.password
url = args.host
TAGSVALIDOS = args.images

nexus = Nexus(user, password, url)
lista_imagenes = nexus.getAllImages()

raiz = 'nexus'
arbol = Arbol(raiz)
repos = []
imagenes = []

lista = sorted(lista_imagenes)

# Tree construction
for x in lista:
    if (existeRepo(x['Repository']) == 'no'):
        repos.append(x['Repository'])
        agregarElemento(arbol, x['Repository'], raiz)
    if (existeImagen(x['Name']) == 'no'):
        imagenes.append(x['Name'])
        agregarElemento(arbol, x['Name'], x['Repository'])
    #agregarElemento(arbol, x['Created'], x['Name'])
    agregarElemento(arbol, x['Id'], x['Name'])

# Delete all the images and layers out of range
for rep in arbol.hijos:
    for im in rep.hijos:
        num_tags = len(im.hijos)
        cont = num_tags - TAGSVALIDOS
        for tag in im.hijos:
            if cont > 0:
                nexus.deleteImageById(tag.elemento)
            cont -= 1

# Run tasks to clean docker and claim space            
nexus.runTasksCleanDocker()
nexus.runTasksCleanBlob()