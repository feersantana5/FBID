#! /bin/bash
#! /bin/bash
#DEBEMOS EXPORTAR CIERTAS VARIABLES PREVIAMENTE Y CAMBIAR UNA LÍNEA DE CONFIGURACIÓN:
#
#Colocamos en el fichero ~/.bashrc al final las siguientes líneas:
#
### DIRECTORIO QUE TAL
#export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
#export SPARK_HOME=/home/ubuntu/spark/spark-3.2.0-bin-hadoop3.2
#export PROJECT_HOME=/home/ubuntu/practica_big_data_2019
#
#Para que se exporten correctamente debemos reiniciar el terminal.
#
#Ahora debemos añadir al fichero: ~/practica_big_data_2019/flight_prediction/src/main/scala/es/upm/dit/ging/predictor/MakePrediction.scala
##DESKTOP
#La línea val path... por val base_path = "/home/ubuntu/practica_big_data_2019"
#
echo 'Comenzamos el entrenamiento'
cd ~/practica_big_data_2019
. ~/fbid_venv/bin/activate
python resources/train_spark_mllib_model.py .

