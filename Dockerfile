FROM openjdk:11-jre-slim AS build

# Download minecraft fabric server installer
ADD https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.6.1.45/fabric-installer-0.6.1.45.jar ./fabric.jar
RUN java -jar fabric.jar server -mcversion 1.16.2 -downloadMinecraft

# Run from the official slim java 11 image (alpine based images are way too big)
FROM openjdk:11-jre-slim

# Create a group and user minecraft
RUN addgroup --gid 1002 --system minecraft && adduser minecraft --system --ingroup minecraft --uid 1002 --disabled-login
# Tell docker that all future commands should run as minecraft user
USER minecraft

# set home dir as our workdir
WORKDIR /home/minecraft

COPY --chown=minecraft:minecraft --from=build server.jar .
COPY --chown=minecraft:minecraft --from=build fabric-server-launch.jar .

# declare the volume that will hold the configuration files
VOLUME /home/minecraft/conf
# copy the configuration files to the volume
COPY --chown=minecraft:minecraft conf/ conf/

WORKDIR /home/minecraft/conf
# start the server
ENTRYPOINT ["java", "-jar", "../fabric-server-launch.jar", "nogui"]
