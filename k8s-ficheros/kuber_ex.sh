#!/bin/bash

#Para evitar errores de permisos
sudo usermod -aG docker $USER && newgrp docker

echo 'Ejecutamos lo siguiente para conectarnos al demonio de docker y acceder a las imágenes'
echo 'Así no hay que acceder a docker/hub para las imágenes'
eval $(minikube docker-env)

echo 'IMPORTANTE: Las imágenes deben haber sido previamente construidas!'

echo 'Debemos estar en la carpeta donde están los ficheros yaml'
kubectl apply -f red1-networkpolicy.yaml,zookeeper-service.yaml,kafka-service.yaml,mongo-service.yaml,spark-service.yaml,flask-service.yaml,zookeeper-deployment.yaml,kafka-deployment.yaml,mongo-deployment.yaml,mongo-data-deployment.yaml,spark-deployment.yaml,flask-deployment.yaml


echo 'Desplegamos la información'
kubectl get deployment,svc,pods

echo 'Esperamos 1 minuto'
sleep 20s
echo '20 segundos'
sleep 20s
echo '40 segundos'
sleep 20s
echo '60 segundos'
echo 'YA!'

echo 'Una vez se haya ejecutado todo correctamente, ejecutamos: kubectl port-forward svc/flask 5000:5000'
echo 'De este modo exponemos el puerto en el que se encuentra el servidor flask, para acceder externamente (navegador)'
kubectl port-forward svc/flask 5000:5000


echo 'Acceder a:   http://localhost:5000/flights/delays/predict_kafka'
echo 'Para detener el escenario: kubectl delete deployment,pods,svc --all'