#! /bin/bash
echo 'Creamos el topic: flight_delay_classification_request. Debe aparecer created al final'
cd ~/kafka/kafka_2.12-2.3.0/
. ~/fbid_venv/bin/activate
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request

echo 'Creamos un visor de mensajes de kafka'
cd ~/kafka/kafka_2.12-2.3.0/
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic flight_delay_classification_request --from-beginning