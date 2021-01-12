#!/bin/bash

#Author	    :	thebinary <binary4bytes@gmail.com>
#Date	      :	Tue Jan 12 16:35:37 +0545 2021-01-12
#Purpose    : Kafka Scripts Executor

argv0=$0
cmd=$(basename "$argv0")
kafka_install_dir=$(cat /etc/thebinary.kafka.install.dir)

$kafka_install_dir/bin/$cmd $*
