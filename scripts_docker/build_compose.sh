#!/bin/bash

echo 'Primero ejecutar el docker_install'

echo 'Construimos las imágenes de flask, spark y mongo_data, las demás hacemos pull en el docker-compose'
cd flask
docker build -t nacho/flask .
cd ..

cd spark
docker build -t nacho/spark .
cd ..

cd mongo_data
docker build -t nacho/mongo_data .
cd ..

echo 'Entramos en la carpeta raiz de nuestra dockerización, donde está el docker compose y hacemos el up'
docker-compose up