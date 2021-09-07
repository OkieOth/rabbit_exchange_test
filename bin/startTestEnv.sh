#!/bin/bash

scriptPos=${0%/*}

FREE_PORTS=($(comm -23 <(seq 49152 65535 | sort) <(ss -tan | awk '{print $4}' | cut -d':' -f2 | grep "[0-9]\{1,5\}" | sort -u) | shuf | head -n 3))
export MSGBROKER_PORT=${FREE_PORTS[1]}
export MSGBROKER_PORT2=${FREE_PORTS[2]}

containerName="exchange-test-broker"

if docker ps -a | grep "$containerName" > /dev/null; then
    echo "It seems the container ('$containerName') for this tests already exists, cancel"
    exit 1
fi

portFilePath=`cd $scriptPos/.. && pwd`
portFile=${portFilePath}/rabbitmq_ports.tmp
echo "dyn portFile: $portFile"
echo "MSGBROKER_PORT=${FREE_PORTS[1]}" > $portFile
echo "MSGBROKER_PORT2=${FREE_PORTS[2]}" >> $portFile
echo "used ports: MSGBROKER_PORT=$MSGBROKER_PORT, MSGBROKER_PORT2=$MSGBROKER_PORT2"

docker run --name $containerName --rm -d -p ${MSGBROKER_PORT}:5672 -p ${MSGBROKER_PORT2}:15672 rabbitmq:3.9-management-alpine
