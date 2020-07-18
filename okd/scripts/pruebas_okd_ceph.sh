#!/bin/bash

## En alguno de los nodos de Ceph


## Creacion de usuarios
sudo ceph auth get-or-create client.kevin.gomez mon 'allow *' osd 'allow *'  -o kevin.gomez.keyring
sudo ceph auth get-or-create client.mauricio.melendez mon 'allow *' osd 'allow *'  -o mauricio.melendez.keyring

## Creacion de un pool, los pools son las particiones que crea Ceph, en las cuales se almacenaran los datos
## amxga-pool ---> nombre del pool
## 10 ----> Numero de placement group para ese pool
## 10 ----> Numero de placement group que pueden ser usados, lo ideal es que sea igual al numero anterior
## Los Placement groups son una implementacion de Ceph que permiten la distribucion de los datos, son grupos creados en los cuales
## se hace una distribucion de los datos.
ceph osd pool create amxga-pool 10 10
# [kevin.gomez@okdamxceph1-2 ceph-pruebas]$ sudo ceph osd pool create amxga-pool 10 10
# pool 'amxga-pool' created

## Iniciamos el pool creado en el paso anterior
rbd pool init amxga-pool

## Creamos un block device en el pool creado
## --size ---> tamaño del bloque en megabytes
## amxga-pool/prueba ---> pool donde se creara el bloque / nombre del bloque
rbd create --size 100 amxga-pool/prueba