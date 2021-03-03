# Define Build Arguments
ARG INSTALL_DIR=/opt
ARG SCALA_VER=2.13
ARG KAFKA_VER=2.7.0

# Stage: Download and Verify
FROM alpine AS downloader

ARG SCALA_VER
ARG KAFKA_VER
ARG FULL_VER=${SCALA_VER}-${KAFKA_VER}

ARG FILENAME=kafka_${FULL_VER}.tgz
ARG URL=https://downloads.apache.org/kafka/${KAFKA_VER}/${FILENAME}
ARG KEYS_URL=https://downloads.apache.org/kafka/KEYS
ARG JMX_PROM_EXPORTER=https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.15.0/jmx_prometheus_javaagent-0.15.0.jar

WORKDIR /tmp

# install required packages
RUN apk add --no-cache \
    gnupg

# download and verify
RUN set -eux; \
  wget -q -O ${FILENAME} "${URL}"

RUN set -eux; \
  wget -q -O ${FILENAME}.asc ${URL}.asc; \
  wget -q -O KEYS "${KEYS_URL}"; \
  gpg --import KEYS; \
  gpg --batch --verify ${FILENAME}.asc ${FILENAME}
  
RUN set -eux; \
  echo ${FULL_VER} > thebinary.kafka.version; \
  tar -xzf ${FILENAME}; \
  mv kafka_${FULL_VER} kafka

# JMX prometheus exporter
RUN mkdir monitoring
RUN wget -q -O monitoring/jmx_prometheus_javaagent.jar "${JMX_PROM_EXPORTER}"
COPY ./jmx_prometheus_exporter/config.yaml monitoring/config.yaml


# Stage: Final Build 
FROM openjdk:11-jre-slim

ARG INSTALL_DIR

COPY --from=downloader /tmp/thebinary.kafka.version /etc/thebinary.kafka.version
COPY --from=downloader /tmp/kafka ${INSTALL_DIR}/kafka
COPY --from=downloader /tmp/monitoring ${INSTALL_DIR}/kafka/monitoring

ADD kafka-exec.sh /usr/bin/

RUN set -eux; \
  echo ${INSTALL_DIR}/kafka > /etc/thebinary.kafka.install.dir; \
  cd /usr/bin/ && for sh in $(ls ${INSTALL_DIR}/kafka/bin/); do ln -s kafka-exec.sh $sh; done; \
  mkdir -p /etc/kafka; \
  cp -a ${INSTALL_DIR}/kafka/config/server.properties /etc/kafka/server.properties

EXPOSE 9092/tcp

CMD kafka-server-start.sh /etc/kafka/server.properties
