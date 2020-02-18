# Run from distroless' java 11 image
FROM adoptopenjdk/openjdk11:x86_64-alpine-jre-11.0.6_10

# Create a group and user minecraft
RUN addgroup -g 1002 -S minecraft && adduser minecraft -S -G minecraft -u 1002 -s /sbin/nologin
# Tell docker that all future commands should run as minecraft user
USER minecraft

# set home dir as our workdir
WORKDIR /home/minecraft

# Download minecraft server version 1.15.2 and store it in minecraft homedir
ADD --chown=minecraft:minecraft https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar .

# declare the volume that will hold the configuration files
VOLUME /home/minecraft/conf
# add the configuration files to the volume
ADD --chown=minecraft:minecraft conf/ conf/

# start the server
WORKDIR /home/minecraft/conf
ENTRYPOINT ["java", "-jar", "../server.jar", "nogui"]
