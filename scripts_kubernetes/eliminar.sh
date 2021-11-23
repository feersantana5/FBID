#!/bin/bash

echo 'Borramos el despliegue y hacemos stop a minikube, si quieres hacer remove: minikube delete'
kubectl delete deployment,pods,svc --all
minikube stop