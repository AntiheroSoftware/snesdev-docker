# snesdev-docker
Docker for Snes Dev. (compilation of command line tool to compile your snes projects)

## Build the docker image

```
docker build -t antiherosoftware/snesdev -f DockerFile --progress plain .
```

## Run a command

```
docker run --rm -v $PWD:/project antiherosoftware/snesdev make
```
