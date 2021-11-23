#! /bin/bash
#Nos movemos al directorio donde se encuentra el build de sbt y hacemos el comando package
#Antes se ha tenido que ejecutar entrenamiento_user.sh, ya que necesitamos los requerimientos que ese nos da ( exports y la variable var path...)
echo 'Ejecutamos sbt para crear el jar'
cd ~/practica_big_data_2019/flight_prediction
. ~/fbid_venv/bin/activate
sbt package