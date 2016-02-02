#!/bin/bash
SEGMENT_ID=$(docker info | grep n1 | awk '{print $1}' | tr -d :)
SEGMENT_PUBLIC_IP=$(docker run --rm --net=host --env constraint:node==${SEGMENT_ID} racknet/ip public)
SEGMENT_SERVICE_IP=$(docker run --rm --net=host --env constraint:node==${SEGMENT_ID} racknet/ip service)
echo "First Segment ID: $SEGMENT_ID"
echo "Public_IP of First Segment: $SEGMENT_PUBLIC_IP"
echo "Service_IP of First Segment: $SEGMENT_SERVICE_IP"
sed 's/SEGMENT_ID/'${SEGMENT_ID}'/g; s/SEGMENT_PUBLIC_IP/'${SEGMENT_PUBLIC_IP}'/g; s/SEGMENT_SERVICE_IP/'${SEGMENT_SERVICE_IP}'/g' docker-compose.yml > monitoring.yml

echo "Launching statsd/graphite & monitoring agent"
docker-compose -p monitoring -f monitoring.yml up -d
echo "Scaling monitoring agent, one per segment"
docker-compose -p monitoring -f monitoring.yml scale monitoring-agent=$(docker info | grep Nodes | awk '{print $2}')
echo "Open your browser to http://${SEGMENT_PUBLIC_IP}"