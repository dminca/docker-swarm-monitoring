#!/bin/bash

set -euo pipefail

SEGMENT_PUBLIC_IP=$(docker run --rm --net=host --env constraint:node==*n1 racknet/ip public)
SEGMENT_SERVICE_IP=$(docker run --rm --net=host --env constraint:node==*n1 racknet/ip service)
echo "Public_IP of First Segment: $SEGMENT_PUBLIC_IP"
echo "Service_IP of First Segment: $SEGMENT_SERVICE_IP"
sed 's/SEGMENT_SERVICE_IP/'${SEGMENT_SERVICE_IP}'/g' docker-compose.yml > monitoring.yml

echo "Launching statsd/graphite & monitoring agent"
docker-compose -p monitoring -f monitoring.yml up -d
echo "Scaling monitoring agent, one per segment"
NODES=$(docker info | grep Nodes | awk '{print $2}')
docker-compose -p monitoring -f monitoring.yml scale monitoring-agent=$NODES
echo "Open your browser to http://${SEGMENT_PUBLIC_IP}"
