# Apache Kafka in Docker #

__TAG names are based on Kafka binaries version as__

thebinary/kafka:{scala_version}-{kafka_version}

eg: __thebinary/kafka:2.13-2.7.0__


## Use as Kafka Server
1. Run a zookeeper service  
Kafka is dependent on zookeeper service.
```sh
docker run -d -it --network kafka --name zookeeper zookeeper
```

2. Create a server.properties config file
```
# server.properties
broker.id=0
listeners=PLAINTEXT://:9092
log.dirs=/tmp/kafka-logs
num.partitions=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
zookeeper.connect=zookeeper:2181
```

3. Run kafka
```sh
docker run --network kafka -it -d -v $(PWD)/server.properties:/etc/kafka/config/server.properties thebinary/kafka
```
### Enable Prometheus Exporter for Kafka Metrics
4. Enable Prometheus Exporter(Optional)
Export the following environment variable while starting the container.
This makes the container listen on port 8080 for jmx exporter.
Change the port number in the KAFKA_OPTS env variable to use a different port than 8080.
```
KAFKA_OPTS=-javaagent:/opt/kafka/monitoring/jmx_prometheus_javaagent.jar=8080:/opt/kafka/monitoring/config.yaml
```

## Use as Kafka Tools

All kafka shell tools (scripts) can be used directly from these docker images. This can be used to run these kafka tools to interact with external kafka-brokers/kafka-zookeepers. Some examples are given below:

1. Create Kafka Topic 
```
docker run --rm -it thebinary/kafka kafka-topics.sh --bootstrap-sever ext-kafka-01.thebinary.org --create --replication-factor 1 --partitions 1 --topic kafkatopic
```

2. List Kafka Topics
```
docker run --rm -it thebinary/kafka kafka-topics.sh --bootstrap-sever ext-kafka-01.thebinary.org --list
```

