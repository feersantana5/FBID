#! /bin/bash
echo 'Ejecutamos el servidor web'
cd ~/practica_big_data_2019/resources/web
. ~/fbid_venv/bin/activate
python predict_flask.py