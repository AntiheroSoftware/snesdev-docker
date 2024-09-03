# snesdev-docker
Docker for Snes Dev. (compilation of command line tool to compile your snes projects)

## Get the container from docker hub 

```
docker pull antiherosoftware/snesdev
```

## Build the docker image

```
docker build -t antiherosoftware/snesdev -f DockerFile --progress plain .
```

## Installed software

* CC65 Toolchain
* PVSNESLIB Toolchain
* SuperFamiconv
* SuperFamicheck
* pcx2snes
* gfx2snes
* image magick
* tiled-quantitizer v1.0.4
* Higeul v0.22

## Run a command

```
docker run --rm -v $PWD:/project antiherosoftware/snesdev make
```

## Run a shell 

```
docker run -it --rm -v $PWD:/project antiherosoftware/snesdev /bin/sh
```

Either the command and the shell will mount current directory to /project folder in the container.
