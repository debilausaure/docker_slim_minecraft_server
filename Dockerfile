FROM eclipse-temurin:23-jre-alpine AS build

# Download minecraft fabric server installer
ADD https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.3/fabric-installer-1.0.3.jar ./fabric-installer.jar
RUN java -Xmx2G -jar fabric-installer.jar server -mcversion 1.21.4 -downloadMinecraft

# Run from the Adoptium Eclipse Temurin Java JRE 21 alpine image
# See here https://whichjdk.com/#adoptium-eclipse-temurin
FROM eclipse-temurin:23-jre-alpine

# Create a group and user minecraft
RUN addgroup -g 1002 -S minecraft && adduser minecraft -S -G minecraft -u 1002 -s /sbin/nologin
# Tell docker that all future commands should run as minecraft user
USER minecraft

# set home dir as our workdir
WORKDIR /home/minecraft

COPY --chown=minecraft:minecraft --from=build server.jar ./server.jar
COPY --chown=minecraft:minecraft --from=build fabric-server-launch.jar .
COPY --chown=minecraft:minecraft --from=build libraries/ ./libraries

# declare the volume that will hold the configuration files
VOLUME /home/minecraft/conf
# copy the configuration files to the volume
COPY --chown=minecraft:minecraft conf/ conf/

WORKDIR /home/minecraft/conf
# start the server
ENTRYPOINT ["java", "-jar", "../fabric-server-launch.jar", "nogui"]
