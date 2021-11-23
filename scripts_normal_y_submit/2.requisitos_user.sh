#! /bin/bash

echo 'Descargamos spark y lo colocamos en una carpeta del directorio raiz ~/spark'
wget https://dlcdn.apache.org/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz
#wget https://dlcdn.apache.org/spark/spark-3.1.2/spark-3.1.2-bin-hadoop2.7.tgz
tar -xvzf spark-3.2.0-bin-hadoop3.2.tgz
mkdir -p ~/spark
mv spark-3.2.0-bin-hadoop3.2 ~/spark

echo 'Descargamos kafka y lo colocamos en una carpeta del directorio raiz ~/kafka, utilizamos la versión 2.12 ya que la 3.X nos da error al ejecutar zookeper ( que viene con kafka )'
wget https://archive.apache.org/dist/kafka/2.3.0/kafka_2.12-2.3.0.tgz
#wget https://archive.apache.org/dist/kafka/3.0.0/kafka_2.12-3.0.0.tgz
tar -xvzf kafka_2.12-2.3.0.tgz
mkdir ~/kafka
mv kafka_2.12-2.3.0 ~/kafka

echo 'Clonamos el repositorio git'
cd ~
git clone https://github.com/ging/practica_big_data_2019.git
cd practica_big_data_2019

echo 'Descargamos los datos de vuelo e importamos las distancias'
resources/download_data.sh
resources/import_distances.sh

echo 'Creamos el entorno virtual para la ejeución del escenario y dentro de él instalamos los requisitos'
rm -rf ~/fbid_venv
yes | python3.6 -m pip install virtualenv
python3.6 -m virtualenv ~/fbid_venv
# directorio
source /home/dit/fbid_venv/bin/activate 
cd ~/practica_big_data_2019
## cd desktop
yes | python -m pip install -r requirements.txt
deactivate


