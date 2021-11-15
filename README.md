# FBID
Para la ejecución de la práctica se ha desplegado una máquina virtual con la versión 20.04 de Ubuntu. </br>

## Objetivos
- [x] Lograr el funcionamiento de la práctica sin modificaciones
- [x] Ejecución del job de predicción con Spark Submit en vez de IntelliJ
- [ ] Dockerizar cada uno de los servicios que componen la arquitectura completa
- [ ] Desplegar el escenario completo usando docker-compose
- [ ] Desplegar el escenario completo usando kubernetes
- [ ] Desplegar el escenario completo en Google Cloud/AWS
- [ ] Entrenar el modelo con Apache Airflow


## Proceso
### Lograr el funcionamiento de la práctica sin modificaciones

#### Descargar los datos de vuelos pasados

Para la preparación del material, partiendo del repositorio original de la práctica(https://github.com/ging/practica_big_data_2019/blob/master/README.md), se ha clonado el repositorio y ejecutado el script que permite descargar los datos.
```
git clone https://github.com/ging/practica_big_data_2019/blob/master/README.md
```
```
resources/download_data.sh
```
#### Instalación

Se han instalado los siguientes programas y liberías que forman parte de la arquitectura del sistema:</br>

+ Intellij (jdk_1.8) </br>
```
apt -yq install git curl openjdk-8-jre-headless 
```
+ Pyhton3 (version 3.6) </br>
```
apt -yq install python3.6
```
+ PIP </br>
```
apt -yq install python3-pip
```
+ SBT </br>
```
sudo apt-get update
sudo apt-get install apt-transport-https curl gnupg -yqq
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
sudo apt-get update
sudo apt-get install sbt
```
+ MongoDB (version 4.4) </br>
```
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt -yq update
apt -yq install mongodb-org
systemctl start mongod.service
```
E importamos las distancias en mongo:
```
cd practica_big_data_2019
./resources/import_distances.sh
```
+ Spark (version 3.2.0) & Scala </br>
```
wget https://dlcdn.apache.org/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz
tar -xvzf spark-3.2.0-bin-hadoop3.2.tgz
mkdir -p ~/spark
mv spark-3.2.0-bin-hadoop3.2 ~/spark
```
+ Kafka (version kafka_2.12-3.0.0) & Zookeeper </br>
```
wget https://archive.apache.org/dist/kafka/2.3.0/kafka_2.12-2.3.0.tgz
tar -xvzf kafka_2.12-2.3.0.tgz
mkdir ~/kafka
mv kafka_2.12-2.3.0 ~/kafka
```
Para facilitar la realización de la práctica se ha creado un entorno virtual de Python donde se han instalado las librerías necesarias.
```
python3.6 -m virtualenv ~/fbid_venv
source /home/dit/fbid_venv/bin/activate 
```
```
pip install -r requirements.txt
```
#### Entrenar modelo de ML utilizando los datos de vuelos
En primer lugar hemos configurado algunas variables en el entorno y la variable base_paht en la clase MakePrediction de scala.
```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export SPARK_HOME=/home/dit/spark/spark-3.2.0-bin-hadoop3.2
export PROJECT_HOME=/home/dit/practica_big_data_2019
```
```
gedit /practica_big_data_2019/flight_prediction/src/main/scala/es/upm/dit/ging/predictor/MakePrediction.scala
val base_path = "/home/dit/practica_big_data_2019"
```
Para finalmente ejecutar el script de entrenamiento:
```
python resources/train_spark_mllib_model.py .
```
#### Ejecutar el predictor de vuelos
Compilamos el código y creamos un archivo JAR usando sbt antes de usar Spark-submit.
```
cd ~/practica_big_data_2019/flight_prediction
sbt package
```
#### Ejecución de zookeeper y kafka
```
cd ~/kafka/kafka_2.12-2.3.0/
bin/zookeeper-server-start.sh config/zookeeper.properties
```
```
cd ~/kafka/kafka_2.12-2.3.0/
bin/kafka-server-start.sh config/server.properties
```
Finalmente creamos un tópico llamado flight_delay_classification_request y abrimos un consumidor para observar los mensajes enviado con ese tópico:
```
cd ~/kafka/kafka_2.12-2.3.0/
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic flight_delay_classification_request --from-beginning
```
#### Iniciar la aplicación web de predicción
```
cd ~/practica_big_data_2019/resources/web
python predict_flask.py
```
### Ejecución del job de predicción con Spark Submit
```
cd /practica_big_data_2019/flight_prediction/target/scala-2.12
$SPARK_HOME/bin/spark-submit --class es.upm.dit.ging.predictor.MakePrediction --master local --packages org.mongodb.spark:mongo-spark-connector_2.12:3.0.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 flight_prediction_2.12-0.1.jar
```
### Dockerizar cada uno de los servicios que componen la arquitectura completa

### Desplegar el escenario completo usando docker-compose

### Desplegar el escenario completo usando kubernetes

### Desplegar el escenario completo en Google Cloud/AWS

### Entrenar el modelo con Apache Airflow
