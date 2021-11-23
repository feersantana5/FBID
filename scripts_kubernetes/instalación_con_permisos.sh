#!/bin/bash

#
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install apt-transport-https wget curl
sudo apt install virtualbox virtualbox-ext-pack

#Instalamos minikube
wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube
minikube version


#instalamos kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version

#arrancamos minikube
sudo usermod -aG docker $USER && newgrp docker
minikube start

#Descargamos kompose
echo 'Descargamos kompose'
curl -L https://github.com/kubernetes/kompose/releases/download/v1.21.0/kompose-linux-amd64 -o kompose
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose
kompose version

#Ahora entramos en la carpeta donde está el compose para convertirlo con kompose
echo 'Entramos en la carpeta donde está el docker-composer para convertirlo'
echo 'Debemos ejecutarlo desde donde estça el compose o dará error'
cd k8s-ficheros
kompose convert
echo 'Ahora hay que hacer cambios en los ficheros generados para que no de error'
echo 'Después ejecuta el siguiente fichero: Kuber_ex.sh'
echo 'Si ya tenemos los ficheros no hace falta el convert'
echo 'Mirar la carpeta k8... el fichero problemas_soluciones.txt para ver los cambios'