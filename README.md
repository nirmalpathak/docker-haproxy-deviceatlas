# Docker HAProxy with DeviceAtlas

Docker HAProxy with DeviceAtlas is a dockerized version of HAProxy with DeviceAtlas for device detection on web. The detailed information on how to compile and use DeviceAtlas HAProxy module is available [here](https://fossies.org/linux/haproxy/doc/DeviceAtlas-device-detection.txt).

## Prerequiste

- Download HAProxy module of DeviceAtlas API & Data from their official [site](https://deviceatlas.com/deviceatlas-haproxy-module).

- Copy/Save the DeviceAtlas API & Data files into **docker-haproxy-deviceatlas** directory for bulding Docker image.


## Build the container

```console
$ docker build -t haproxy-deviceatlas .
```

## Run the container

```console
$ docker run -d --name haproxy-da -v /path/to/haproxy/config:/usr/local/etc/haproxy/config:ro haproxy-deviceatlas
```

You will also need to publish the ports your HAProxy is listening on to the host by specifying the `-p` option, for example `-p 8080:80` to publish port 8080 from the container host to port 80 in the container.

### Reloading config

To be able to reload HAProxy configuration, you can send `SIGHUP` to the container:

```console
$ docker kill -s HUP haproxy-da
```

# License

View [license information](https://raw.githubusercontent.com/haproxy/haproxy/master/LICENSE) for the software contained in this image.

View [DeviceAtlas license](https://deviceatlas.com/deviceatlas-haproxy-module) information.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).
