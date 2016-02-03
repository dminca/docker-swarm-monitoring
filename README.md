# Rackspace Carina Container Monitoring

Monitor Docker containers running in Rackspace Carina using graphite & statsd

### Background

[Rackspace Carina](https://getcarina.com/) is a Docker Swarm-as-a-Service platform that runs on
bare-metal servers.

### Prerequisites
 * [Rackspace Carina cluster](https://getcarina.com/docs/tutorials/create-connect-cluster/)
 * [docker](https://docs.docker.com/engine/installation/binaries/#get-the-docker-binary) and [docker-compose](https://docs.docker.com/compose/install/) cli installed on your local machine
 * [Rackspace Carina cli](https://github.com/getcarina/carina/blob/master/README.md#installation) installed on your local machine

### TLDR; one liner to get up and running

```
./launch.sh
```

### Step by step walk through

Before we can launch the monitoring containers, we need to get three pieces of
information:

1. The segment ID of the first segment in your cluster
2. The service net IP of the first segment in your cluster
3. The public IP of the first segment in your cluster

We can get this information by running these commands:
```
SEGMENT_PUBLIC_IP=$(docker run --rm --net=host --env constraint:node==*n1 racknet/ip public)
SEGMENT_SERVICE_IP=$(docker run --rm --net=host --env constraint:node==*n1 racknet/ip service)
```

Next, we need to update the docker-compose.yml file with this information.

This next command inserts information about your cluster and creates a new
docker compose file called monitoring.yml.

```
sed 's/SEGMENT_SERVICE_IP/'${SEGMENT_SERVICE_IP}'/g' docker-compose.yml > monitoring.yml
```

Ok, now we are ready to deploy the monitoring containers.

### Launch the monitoring containers
```
docker-compose -p monitor -f monitoring.yml up -d
docker-compose -p monitor -f monitoring.yml scale monitoring-agent=$(docker info | grep Nodes | awk '{print $2}')
```

This first command launches the statsd/graphite container and a single monitoring agent.
The second command finds out how many segments you have in your cluster and then scales
the monitoring agent so that there is the same number as segments.  We ensure
that a monitoring agent is put onto each segment via the affinity environmental
variable in the docker-compose.yml:

```
environment:
  - affinity:container!=*monitoring-agent*
```

Now that the monitoring system is up, we can open the Graphite UI.

### Open Graphite UI

Using the public IP of the first segment in your cluster, we can access the
graphite dashboard.  Using your web browser, navigate to the public IP http://$SEGMENT_PUBLIC_IP
You can get that IP by running:

```
echo http://$SEGMENT_PUBLIC_IP
```

1. In the Graphite Composer window, click 'Graph Data', then 'Add'
2. Enter 'aliasByNode(stats.gauges.docker.*.memory.usage,3)' and press OK

You should now see the memory usage of the containers in your cluster!  You might
need to adjust the time window of the graph to see the data better. You can
do this by clicking on the clock icon, and entering 10 minutes.


## Credits

This app is based on [edyn/docker-docker-stats-statsd](https://github.com/edyn/docker-docker-stats-statsd).

## License

MIT
