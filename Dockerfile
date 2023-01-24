FROM eclipse-temurin:19-jre-alpine AS build

# Download minecraft fabric server installer
ADD https://maven.fabricmc.net/net/fabricmc/fabric-installer/0.11.1/fabric-installer-0.11.1.jar ./fabric-installer.jar
RUN java -jar fabric-installer.jar server -mcversion 1.19.3 -downloadMinecraft
#RUN java -jar fabric.jar server -mcversion 1.19.3 -downloadMinecraft

# Run from the official slim java 11 image (alpine based images are way too big)
FROM eclipse-temurin:19-jre-alpine

# Create a group and user minecraft
RUN addgroup --gid 1002 --system minecraft && adduser minecraft --system --ingroup minecraft --uid 1002
# Tell docker that all future commands should run as minecraft user
USER minecraft

# set home dir as our workdir
WORKDIR /home/minecraft

COPY --chown=minecraft:minecraft --from=build server.jar .
COPY --chown=minecraft:minecraft --from=build fabric-server-launch.jar .
COPY --chown=minecraft:minecraft --from=build libraries ./libraries

# declare the volume that will hold the configuration files
VOLUME /home/minecraft/conf
# copy the configuration files to the volume
COPY --chown=minecraft:minecraft conf/ conf/

WORKDIR /home/minecraft/conf
# start the server
ENTRYPOINT ["java", "-jar", "../fabric-server-launch.jar", "nogui"]
