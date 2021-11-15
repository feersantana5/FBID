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
+ Descargar los datos de vuelos pasados

Para la preparación del material, partiendo del repositorio original de la práctica (https://github.com/ging/practica_big_data_2019/blob/master/README.md), se ha clonado el repositorio y ejecutado el script que permite descargar los datos.
```
git clone https://github.com/ging/practica_big_data_2019/blob/master/README.md
```
```
resources/download_data.sh
```
+ Instalación

Se han instalado los siguientes componentes de la arquitectura del sistema:</br>

- Intellij (jdk_1.8) </br>
```
apt -yq install git curl openjdk-8-jre-headless 
```
- Pyhton3 (version 3.6) </br>
```
apt -yq install python3.6
```
- PIP </br>
```
apt -yq install python3-pip
```
- SBT </br>
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
- MongoDB (version 4.4) </br>
```
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt -yq update
apt -yq install mongodb-org
systemctl start mongod.service
```
- Spark (version 3.2.0) & Scala </br>
```
wget https://dlcdn.apache.org/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz
tar -xvzf spark-3.2.0-bin-hadoop3.2.tgz
mkdir -p ~/spark
mv spark-3.2.0-bin-hadoop3.2 ~/spark
```
- Kafka (version kafka_2.12-3.0.0) & Zookeeper </br>
```
wget https://archive.apache.org/dist/kafka/2.3.0/kafka_2.12-2.3.0.tgz
tar -xvzf kafka_2.12-2.3.0.tgz
mkdir ~/kafka
mv kafka_2.12-2.3.0 ~/kafka
```

+ Entrenar modelo de ML utilizando los datos de vuelos

+ Desplegar el job de Spark que predice el retraso de los vuelos usando el modelo creado
+ Por medio de una interfaz web, el usuario introducirá los datos del vuelo a predecir, que se enviarán al servidor web de Flask
+ El servidor web enviará estos datos al job de predicción a través de Kafka
+ El job realizará la predicción y la guardará en Mongo
+ La interfaz web está constantemente haciendo polling para comprobar si se ha realizado ya la predicción
+ En caso afirmativo, se muestra la predicción en la interfaz





### Lograr el funcionamiento de la práctica sin modificaciones

Primero de todo se ha decidido utilizar el sistema operativo Ubuntu debido a las recomendaciones de los profesores, por lo que se deplego una maquina virtual con este sistema operativo instalado.
En dicha máquina virtual, se debe instalar la siguiente lista de programas con sus respectivas versiones:

- Intellij (jdk_1.8)
- Pyhton3 (version 3.6)
- PIP
- SBT
- MongoDB (version 4.4)
- Spark (version 3.1.2)
- Scala(version 2.12)
- Zookeeper
- Kafka (version kafka_2.12-3.0.0)

### Ejecución del job de predicción con Spark Submit
### Dockerizar cada uno de los servicios que componen la arquitectura completa
### Desplegar el escenario completo usando docker-compose
### Desplegar el escenario completo usando kubernetes
### Desplegar el escenario completo en Google Cloud/AWS
### Entrenar el modelo con Apache Airflow
