FROM bde2020/spark-master:3.1.1-hadoop3.2
COPY files/models /models
COPY files/scala-2.12 /scala-2.12
ENV CLASSPATH=/scala-2.12
CMD /spark/bin/spark-submit --class es.upm.dit.ging.predictor.MakePrediction --master local --packages org.mongodb.spark:mongo-spark-connector_2.12:3.0.1,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 /scala-2.12/flight_prediction_2.12-0.1.jar
