#! /bin/bash
echo 'Lanzamos el spark-submit'
cd ~/practica_big_data_2019/flight_prediction/target/scala-2.12

$SPARK_HOME/bin/spark-submit --class es.upm.dit.ging.predictor.MakePrediction --master local --packages org.mongodb.spark:mongo-spark-connector_2.12:3.0.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 flight_prediction_2.12-0.1.jar