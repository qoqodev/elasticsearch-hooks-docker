# elasticsearch-hooks-docker
This image is a small wrapper around the [official Elasticsearch Docker image](https://github.com/elastic/elasticsearch-docker) to allow for arbitrary hooks to be ran before or after Elasticsearch starts or stops.

Since this image is a wrapper, the [documentation for running Elasticsearch in Docker](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html) also applies for this image. Running this image without any hooks is identical to just running the base image.

[![Docker Repository on Quay](https://quay.io/repository/qoqodev/elasticsearch-hooks/status "Docker Repository on Quay")](https://quay.io/repository/qoqodev/elasticsearch-hooks)

## examples

##### Install a plugin before starting Elasticsearch:
```
$ docker run -e prestart_hook='
  bin/elasticsearch-plugin install analysis-icu
' quay.io/qoqodev/elasticsearch-hooks
```

##### Do something after Elasticsearch starts up:
```
$ docker run -e poststart_hook='
  until nc -z localhost 9300; do
    echo "Not up yet"
    sleep 1
  done
  echo "Ready to go!"
' quay.io/qoqodev/elasticsearch-hooks
```

##### Wait for relocations to complete before stopping a node:
```
$ docker run -e prestop_hook='
  while curl http://localhost:9200/_cat/shards | grep -E "RELOCATING.+$(hostname) ->"; do
    echo "Still relocating shards off of this node"
    sleep 30
  done
' quay.io/qoqodev/elasticsearch-hooks
```

##### Make sure master re-election has finished before deleting the container:
```
$ docker run \
  -e discovery.zen.ping.unicast.hosts=elasticsearch \
  -e poststop_hook='
    while curl http://elasticsearch:9200/_cat/master | grep "$(hostname)"; do
      echo "This node is still considered the elected master"
      echo "Waiting a bit for the next cluster state update"
      sleep 5
    done
' quay.io/qoqodev/elasticsearch-hooks
```

##### Don't like environment variables? Mount the hooks onto the `/hooks` directory in the container and they'll be run appropriately:
```
$ ls
poststart       poststop        prestart        prestop
$ docker run -v $(pwd):/hooks quay.io/qoqodev/elasticsearch-hooks
```
