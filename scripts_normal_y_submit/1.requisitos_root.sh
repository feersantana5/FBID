#! /bin/bash
#instalación fbid requerimientos práctica predicción de vuelos.
#ejecutar con permisos de root

echo 'Hacemos update e instalamos el openjdk'
apt -yq update
apt -yq install git curl openjdk-8-jre-headless

echo 'instalamos python desde ppa para tener la posibilidad de tener varias versiones de python'
add-apt-repository -y ppa:deadsnakes/ppa
apt -yq update
apt -yq install python3.6 python3-pip

echo 'instalamos sbt'
sudo apt-get update
sudo apt-get install apt-transport-https curl gnupg -yqq
echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo -H gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/scalasbt-release.gpg --import
sudo chmod 644 /etc/apt/trusted.gpg.d/scalasbt-release.gpg
sudo apt-get update
sudo apt-get install sbt

echo 'instalamos mongo-db, en su version 4.4 ya que la 5.X nos estaba dando error de compatibilidad con la máquina virtual'
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
apt -yq update
apt -yq install mongodb-org
systemctl start mongod.service