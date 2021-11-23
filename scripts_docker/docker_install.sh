#!/bin/bash

echo 'Actualizamos'
sudo apt update

echo 'Descargamos docker.io'
sudo apt install docker.io

echo 'Activamos el demonio de docker'
sudo systemctl enable docker
sudo service docker start
docker --version

echo 'Añadimos el usuario dit de la virtualbox al grupo docker, cuidado si tu usuario se llama diferente'
cd dockerizacion
sudo groupadd docker
sudo usermod -aG docker ${USER}
su -s ${USER}

echo 'Instalamos docker-compose'
sudo apt-get install curl
#Lo he hecho con este varias veces, ahora no funciona :( cambiamos a wget y la versión 1.28.6 de uthub
#sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo wget -O /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.28.6/docker-compose-Linux-x86_64
sudo chmod +x /usr/local/bin/docker-compose