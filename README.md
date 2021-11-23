# FBID
Para la ejecución de la práctica se ha desplegado una máquina virtual con la versión 20.04 de Ubuntu. </br>

# 📝 Objetivos
Tenemos un dataset (todos los vuelos desde 2015) que contiene información de vuelos pasados, incluyendo si han salido con retraso o no. A partir de esta información, queremos predecir si va a haber retrasos en un vuelo futuro.


<p align="center">
<img src="https://github.com/ging/practica_big_data_2019/raw/master/images/front_end_realtime_architecture.png" title="Arquitectura Front-end" width="500" height="500" />
</p>

### Arquitectura Front-end
El diagrama anterior muestra cómo funciona la arquitectura front-end de la aplicación de predicción de retrasos de vuelo:

1.	El usuario a través de la interfaz web, llena un formulario con información básica del vuelo a predecir que se envía al servidor web de Flask.
2.	El servidor completa algunos campos necesarios derivados de los del formato "día del año" y emite un mensaje de Kafka que contiene una solicitud de predicción.
3.	Spark Streaming está escuchando en una cola de Kafka estas solicitudes y hace la predicción, almacenando el resultado en MongoDB.
4.	Mientras tanto, el cliente ha recibido un UUID en la respuesta del formulario y ha estado sondeando otro punto final cada segundo.
5.	Una vez que los datos están disponibles en Mongo, la siguiente solicitud del cliente los recoge. 
6.	¡Finalmente, el cliente muestra el resultado de la predicción al usuario!

<p align="center">
<img src="https://github.com/ging/practica_big_data_2019/raw/master/images/back_end_realtime_architecture.png" title="Arquitectura Back-end" width="500" height="200"/>
</p>

### Arquitectura Back-end
El diagrama de la arquitectura de back-end nos permite entender cómo entrenamos un modelo de clasificador con el dataset en disco (HDFS o Amazon S3, etc.) para predecir retrasos en los vuelos por batchs en Spark. Esta arquitectura es extremadamente poderosa y es un gran beneficio que podamos usar el mismo código por lotes y en tiempo real con PySpark Streaming. Para ello seguimos los siguientes pasos:

1.	Guardamos el modelo en disco.
2.	Lanzamos Zookeeper y una cola de Kafka.
3.	Usamos Spark Streaming para cargar el modelo de clasificador y luego escuchamos las solicitudes de predicción en una cola de Kafka.
4.	Cuando llega una solicitud de predicción, Spark Streaming (el job) realiza la predicción y almacena el resultado en MongoDB, donde la aplicación web puede recogerlo.
5.	La aplicación web está constantemente haciendo polling sobre la base de datos para comprobar si se ha realizado ya la predicción. En caso afirmativo, se muestra la predicción en la interfaz

## ✅ Lograr el funcionamiento de la práctica sin realizar modificaciones (4 ptos)
La práctica se ha realizado sobre una máquina virtual con el sistema operativo Ubuntu 20.04. 

### ⚙️ Preparación

En primer lugar descargamos el repositorio de la practica y ejecutamos los scripts que nos permiten descargar los datos de vuelos pasados y las distancias.

```
echo 'Clonamos el repositorio git'
cd ~
git clone https://github.com/ging/practica_big_data_2019.git
cd practica_big_data_2019

echo 'Descargamos los datos de vuelo e importamos las distancias'
resources/download_data.sh
resources/import_distances.sh
```

Continuamos con la preparación del entorno y las aplicaciones necesarias:

Añadimos las variables de entorno en  ~/.bashrc:

```
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export SPARK_HOME=/home/dit/spark/spark-3.2.0-bin-hadoop3.2
export PROJECT_HOME=/home/dit/practica_big_data_2019
```

Procedemos a la instalación de los requerimientos de la práctica:
+ El paquete openjdk-8-jre que contiene el Java Runtime Environment

```
echo 'Hacemos update e instalamos el openjdk'
apt -yq update
apt -yq install git curl openjdk-8-jre-headless
```
+ Python 3.6 y pip para usar y manejar Python y sus paquetes.
```
echo 'instalamos python desde ppa para tener la posibilidad de tener varias versiones de python'
add-apt-repository -y ppa:deadsnakes/ppa
apt -yq update
apt -yq install python3.6 python3-pip
```
+ SBT para compilar el código Scala.
```
echo 'instalamos sbt'
sudo apt-get update
sudo apt-get install apt-transport-https curl gnupg -yqq
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
sudo apt-get update
sudo apt-get install sbt
```
+ Instalamos y lanzamos MongoDB para almacenar las predicciones.
```
echo 'instalamos mongo-db, en su version 4.4 ya que la 5.X nos estaba dando error de compatibilidad con la máquina virtual'
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt -yq update
apt -yq install mongodb-org
echo 'lanzamos el servicio mongo'
systemctl start mongod.service
```
+ Spark para el procesamiento de datos en streaming.
```
echo 'Descargamos spark y lo colocamos en una carpeta del directorio raiz ~/spark'
wget https://dlcdn.apache.org/spark/spark-3.2.0/spark-3.2.0-bin-hadoop3.2.tgz
#wget https://dlcdn.apache.org/spark/spark-3.1.2/spark-3.1.2-bin-hadoop2.7.tgz
tar -xvzf spark-3.2.0-bin-hadoop3.2.tgz
mkdir -p ~/spark
mv spark-3.2.0-bin-hadoop3.2 ~/spark
```
+ Para comunicar el servicio web con el job de predicción utilizamos Kafka. Kafka es una herramienta de Apache para crear pipelines de streaming de datos en tiempo real. Cada vez que un usuario inicia una nueva predicción, le llega al job a través de Kafka. Zokeeper viene incluido en la instalación porque es necesario para el funcionamiento de Kafka.
```
echo 'Descargamos kafka y lo colocamos en una carpeta del directorio raiz ~/kafka, utilizamos la versión 2.12 ya que la 3.X nos da error al ejecutar zookeper ( que viene con kafka )'
wget https://archive.apache.org/dist/kafka/2.3.0/kafka_2.12-2.3.0.tgz
tar -xvzf kafka_2.12-2.3.0.tgz
mkdir ~/kafka
mv kafka_2.12-2.3.0 ~/kafka
```
+ Creamos un entorno virtual para Python e instalamos las librerías necesarias.
```
echo 'Creamos el entorno virtual para la ejeución del escenario y dentro de él instalamos los requisitos'
rm -rf ~/fbid_venv
yes | python3.6 -m pip install virtualenv
python3.6 -m virtualenv ~/fbid_venv
# directorio que corresponda
source /home/dit/fbid_venv/bin/activate 
cd ~/practica_big_data_2019
yes | python -m pip install -r requirements.txt
deactivate
```

### 🧠 Entrenamiento
Procedemos al entrenamiento del modelo de ML usando el dataset. Para ello, entrenamos un modelo predictivo basado en el algoritmo RandomForest utilizando los datos que tenemos de vuelos antiguos. Todo el proceso de entrenamiento lo vamos a realizar en batch utilizando PySpark. Como resultado tendremos un modelo que para un nuevo vuelo dado, va a predecir si va a tener o no retraso.

En primer lugar es necesario modificar el archivo *~/practica_big_data_2019/flight_prediction/src/main/scala/es/upm/dit/ging/predictor/MakePrediction.scala* donde hemos modificado la línea val base_path. con el directorio de la práctica en nuestro equipo.

Para finalmente ejecutar el script de entrenamiento y observar como que se han guardado los modelos creados:
```
cd ~/practica_big_data_2019
. ~/fbid_venv/bin/activate
python resources/train_spark_mllib_model.py .

ls ../models
```

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%201.png" title="Modelos" width="500" height="150"/>
</p>

Tenemos que desplegar una arquitectura completa que nos permita, utilizando el modelo predictivo que hemos creado, realizar predicciones en tiempo real para nuevos vuelos.

### 📨 Cola de kafka
Para la transmisión del flujo de datos es necesario lanzar una cola de kafka, sin embargo, es necesario lanzar primero ZooKeeper.

```
cd ~/kafka/kafka_2.12-2.3.0/
bin/zookeeper-server-start.sh config/zookeeper.properties

cd ~/kafka/kafka_2.12-2.3.0/
bin/kafka-server-start.sh config/server.properties
```

Tras arrancar kafka y Zookerper creamos el tópico flight_delay_classification_request y una ventana con un consumidor del tópico para poder observar los mensajes transmitidos bajo ese tópico. 

```
echo 'Creamos el topic: flight_delay_classification_request. Debe aparecer created al final'
cd ~/kafka/kafka_2.12-2.3.0/
. ~/fbid_venv/bin/activate
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request

echo 'Creamos un visor de mensajes de kafka'
cd ~/kafka/kafka_2.12-2.3.0/
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic flight_delay_classification_request --from-beginning
```

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2012.png" title="Kafka"/>
</p>

### 🔮 Ejecutar el predictor
Para habilitar el cálculo de predicciones en tiempo real vamos a utilizar Spark Streaming y el modelo predictivo que hemos entrenado anteriormente. Hemos ejecutado el predictor de vuelos de 2 maneras distintas, con:

 + IntelliJ

```
echo 'Abrimos la aplicación'
intellij-idea-community
echo 'Configurar los ajustes del IDE, compilar y ejecutar el proyecto'
```

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%204.png" title="IntelliJ" height="300" />
</p>

 + Spark Submit

## ✅ Ejecución del job de predicción con Spark Submit en vez de IntelliJ  (1 pto)

Para desplegar el job de Spark que predice el retraso de los vuelos usando el modelo creado con Spark Submit en vez de IntelliJ, hemos tenido que compilar el código y crear un JAR usando SBT.

```
cd ~/practica_big_data_2019/flight_prediction
. ~/fbid_venv/bin/activate
sbt compile
sbt package
``` 

```
cd ~/practica_big_data_2019/flight_prediction/target/scala-2.12

$SPARK_HOME/bin/spark-submit --class es.upm.dit.ging.predictor.MakePrediction --master local --packages org.mongodb.spark:mongo-spark-connector_2.12:3.0.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 flight_prediction_2.12-0.1.jar
```

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2014.png" title="Spark Submit" height="300" />
</p>

### 🧑🏻‍💻 Servidor web
Como se ha comentado anteriormente, el servidor web está implementado con Flask, un microframework de Python para desarrollar servicios web sencillos. Para lanzarlo sólo es necesario ejecutar el siguiente script:

```
echo 'Ejecutamos el servidor web'
cd ~/practica_big_data_2019/resources/web
. ~/fbid_venv/bin/activate
python predict_flask.py
```

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%207.png" title="Servidor"  height="200"/>
</p>

### 🗂 Resultados
Finalmente, obtenemos la respuesta en el navegador. A través de la consola de Javascript podemos monitorizar el proceso.

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%203.png" title="Servidor" height="400"/>
</p>

A través de mongo verificamos los registros de predicciones insertadas en MongoDB:

```
$ mongo
  > use agile_data_science;
  >db.flight_delay_classification_response.find();
```
<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2011.png" title="Mongo" height="300"/>
</p>

En el consumidor de kafka podemos ver los mensajes enviados:
<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2010.png" title="Kafka" height="150"/>
</p>

Finalmente hemos comprobado en el navegador que la ejecución funciona correctamente mediante IntelliJ:

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%209.png" title="IntelliJ" height="300" />
</p>

Finalmente hemos comprobado en el navegador que la ejecución funciona correctamente mediante Spark Submit:

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2013.png" title="Spark Submit" height="300" />
</p>

## ✅ Dockerizar cada uno de los servicios que componen la arquitectura completa (1 pto)

En este apartado hemos dockerizado, es decir, creado contenedores ligeros de los servicios que forman parte de la arquitectura para facilitar así su ejecución en cualquier máquina con Docker instalado, independientemente del sistema operativo que la máquina tenga por debajo, facilitando así también los despliegues. Para ello, hemos creado un DockerFile en cada servicio para poder crear las imágenes personalizadas de Docker. Hemos creado las imágenes de spark y flask. Las imágenes de mongo, zookeeper y kafka corresponden a mongo:4.42, wurstmeister/zookeeper y wurstmeister/kafka:2.12-2.3.0. Para ejecutar cada servicio se han añadido a la red host por defecto de Docker. Además, ha sido necesario cambiar el hostname de cada imagen por localhost:puerto para habilitar la intercomunicación en la misma red, estas modificacines se han realizado también en predictor.py, MakePrediction.scala y flask.
Los pasos seguidos han sido:

+ Instalar docker:
```
echo 'Descargamos docker.io'
sudo apt install docker.io
```

+ Activar el demonio de docker:
```
sudo systemctl enable docker
sudo service docker start
docker --version
```

+ Parar mongo:
```
systemctl stop mongod.service
```
+ Crear la imagen de spark:
```
docker build -t nacho/spark ./spark
```
+ Crear la imagen de flask:
```
docker build -t nacho/flask ./flask
```
+ Generar una instancia de la imagen de mongo y crear el volumen que permita mediante el comando docker exec importar en el contendor las distancias de los vuelos almacenadas en el archivo *ractica_big_data_2019/data/origin_dest_distances.jsonl*:
```
docker run --name mongo --volume=/home/dit/practica_big_data_2019/:/practica_big_data_2019 -p 27017:27017 mongo:4.4.2
docker exec -it mongo mongoimport -d agile_data_science -c origin_dest_distances --file / practica_big_data_2019/data/origin_dest_distances.jsonl
```
+ Generar una instancia de la imagen de zookeeper:
```
docker run -h zookeeper --net=host -p 2181:2181 --name zookeeper wurstmeister/zookeeper
```
+ Generar una instancia de la imagen de kafka:
```
docker run --name kafka --net=host -p 9092=9092 -e KAFKA_ADVERTISED_LISTENERS='PLAINTEXT://-localhost:9092' -e KAFKA_LISTENERS='PLAINTEXT://-localhost:9092' -e KAFKA_CREATE_TOPICS='"flight_delay_classification_request:1:1"' -e KAFKA_ZOOKEEPER_CONNECT='localhost:2181' -h wurstmeister/kafka:2.12-2.3.0
```
+ Generar una instancia de la imagen de spark:
```
docker run --name spark --net=host nacho/spark
```
+ Generar una instancia de la imagen de flask:
```
docker run --name flask -p 5000:5000 nacho/flask
```

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2016.png" title="Docker" height="300" />
</p>

### 🗂 Resultado

Finalmente observamos en el navegador el funcionamiento de la práctica con los contenedores desplegados:

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2015.png" title="Docker result" height="300" />
</p>

## ✅ Desplegar el escenario completo usando docker-compose (1 pto)

En primer lugar hemos instalado el Docker Compose:
```
echo 'Instalamos docker-compose'
sudo apt-get install curl
sudo wget -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.28.6/docker-compose-Linux-x86_64
sudo chmod +x /usr/local/bin/docker-compose
```
Una vez instalado Docker Compose se han construido las imágenes de flask, spark y hecho pull de las demás al igual que se hizo en el anterior apartado (sólo hacer en caso de no haberlo realizado). Sin embargo, en este apartado se ha construido una imagen mongo_data para alimentar el contenedor de mongo. Su finalidad es sustituir el comando docker exec utilizado en el apartado anterior y poder desplegar el escenario con mayor facilidad.

```
cd flask
docker build -t nacho/flask .
cd ..

cd spark
docker build -t nacho/spark .
cd ..

cd mongo_data
docker build -t nacho/mongo_data .
```
<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2018.png" title="Docker compose" height="300"/>
</p>

Finalmente con el siguiente comando construimos, creamos, iniciamos y conectamos los contenedores para ejecutarlos en un servicio.
```
docker-compose up
```
<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2019.png" title="Docker compose"  height="300"/>
</p>

### 🗂 Resultado

Verificamos que las imagenes hayan sido descargadas por docker:

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2021.png" title="Docker compose" height="300" />
</p>

Verificamos que los contenedores se han creado:

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2022.png" title="Docker compose" height="300" />
</p>

Finalmente observamos en el navegador el funcionamiento de la práctica tras ser desplegada con el docker-compose:

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2020.png" title="Docker compose" height="300" />
</p>

## ✅ Desplegar el escenario completo usando kubernetes (2 ptos)
En primer lugar hemos preparado las herramientas necesarias en la máquina para utilizar kubernetes.
```
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install apt-transport-https wget curl
sudo apt install virtualbox virtualbox-ext-pack
```
Para desplegar el escenario con kubernetes hemos utilizado las herramientas minikube, kubectl y kompose: 
+ Minikube es una herramienta que administra maquinas virtuales en donde corre un cluster o mejor dicho una instancia de Kubernetes en un solo nodo. Se apoya de un hypervisor, en nuestro caso el anteriormente descargado VirtualBox. 
```
# Instalamos minikube
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube
minikube version
```
+ kubectl es la línea de comandos de Kubernetes, utilizada para desplegar y gestionar aplicaciones en Kubernetes.
```
#instalamos kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version
```
```
#arrancamos minikube
sudo usermod -aG docker $USER && newgrp docker
minikube start
```
<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2023.png" title="Minikube" height="300" />
</p>

+ kompose es una herramienta que nos permite con el archivo docker-compose del apartado anterior, la implementación en clústeres de Kubernetes convirtiendo el recurso autoáticamente.
```
#Descargamos kompose
echo 'Descargamos kompose'
curl -L https://github.com/kubernetes/kompose/releases/download/v1.21.0/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose
kompose versión

cd k8s-ficheros
kompose convert
```
Una vez obtenido los ficheros yaml, ejecutamos el siguiente comando para conectarnos al demonio de docker y acceder a las imágenes sin tener que acceder a docker hub para obtener las imágenes.

```
#Para evitar errores de permisos
sudo usermod -aG docker $USER && newgrp docker
eval $(minikube docker-env)
```
En el directorio donde se encuentran los archivos .yaml, ejecutamos el siguiente comando para crear los objetos definidos en los archivos de configuración:
```
kubectl apply -f red1-networkpolicy.yaml,zookeeper-service.yaml,kafka-service.yaml,mongo-service.yaml,spark-service.yaml,flask-service.yaml,zookeeper-deployment.yaml,kafka-deployment.yaml,mongo-deployment.yaml,mongo-data-deployment.yaml,spark-deployment.yaml,flask-deployment.yaml
```
Desplegamos los recursos:
```
echo 'Desplegamos la información'
kubectl get deployment,svc,pods
```

Una vez se ha ejecutado todo correctamente, exponemos el puerto en el que se encuentra el servidor flask, para acceder externamente (navegador) mediante el siguiente comando:

```
kubectl port-forward svc/flask 5000:5000
```

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2024.png" title="kb8" height="300" />
</p>

### 🗂 Resultado

Finalmente observamos en el navegador el funcionamiento de la práctica tras ser desplegada con kubernetes:


<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2025.png" title="kb8" height="300" />
</p>

Para finalizar borramos el despliegue y paramos, o en caso deseado, borramos el cluster de kubernetes:
```
kubectl delete deployment,pods,svc --all
minikube stop
minikube delete
```

## ✅ Desplegar el escenario completo en Google Cloud (1 pto)
Se ha creado una instancia de Ubuntu 20.04 LTS en Google Cloud que se ha preparado para desplegar la práctica con kubernetes al igual que se realizó en el apartado anterior. Para mayor facilidad en la interacción y comprobación de resultados se le ha instalado una interfaz gráfica de usuario.

<p align="center">
<img src="https://github.com/feersantana5/FBID/blob/main/images/Imagen%2017.png" title="Google Cloud" height="300" />
</p>


