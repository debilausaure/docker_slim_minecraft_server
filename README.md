# Yet another minecraft server docker image

### But... why ?

The most famous minecraft docker image at this time is [itzg/docker-minecraft-server](https://github.com/itzg/docker-minecraft-server).  
While itzg's image is very convenient and packed with lots of features (kudos to [itzg](https://github.com/itzg)), I find it to be a bit overkill.

This repository is meant to allow you to build a minimal docker image, providing a functional vanilla minecraft server that does not compromise on security.

The result is that this docker image is **significantly** smaller than itgz's. Here's the output of `docker images` :

```
REPOSITORY              TAG             IMAGE ID       CREATED          SIZE
alpine_mc               latest          4072a52f574c   33 minutes ago   234MB
itzg/minecraft-server   latest          76b95cbb958c   10 hours ago     726MB
```

### Features

* Fabric 1.19.3 Server
* Latest Java 19 runtime environment
* Server executed as non-root user minecraft:minecraft (uid:1002, gid:1002)
* Volume mounted server configuration, worlds, and mods (located in `/home/minecraft/conf`).
* Automatic backup of your worlds to Mega.nz (check out the [sibling container](https://github.com/debilausaure/docker_minecraft_mega_backuper) of ~13MB)

#### Planned Features

* Health checks

## Get Started

### Build the image

Here are the preliminary steps to get your container running :

* Clone the repository
* Modify the configuration files to fit your needs under the `/conf` folder (notably, the `server.properties` file).
* Add any mod you want to use inside the `/conf/mods` folder
* Run `docker build -t tag_of_your_image /path/to/this/repository`

### Run the container

Create a volume that will contain your minecraft server configuration and map :

```sh
docker volume create my_minecraft_server_volume
```

You are now set to run the container :

```sh
docker run -p 25565:25565 -v my_minecraft_server_volume:/home/minecraft/conf tag_of_your_image:latest
```

Where :

* `25565` is the default minecraft server port
* `my_minecraft_server_volume` is your volume name
* `tag_of_your_image` is your image name

#### Docker Parameters

* `-p 25565:25565` exposes the port 25565 of your host and binds it to the port 25565 of the container, make it match with whatever configuration you have in `server.properties`
* `-v my_minecraft_server_volume:/home/minecraft/conf` mounts the docker volume you created to the expected location in the container

### Example 

```sh
docker run --name my_minecraft_server -p 25565:25565 -v my_minecraft_server_volume:/home/minecraft/conf --rm -d tag_of_your_image:latest
```
