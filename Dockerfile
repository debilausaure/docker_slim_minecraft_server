FROM amazoncorretto:21.0.4-al2023-headless AS build

# Download minecraft fabric server installer
ADD https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar ./fabric-installer.jar
RUN java -Xmx2G -jar fabric-installer.jar server -mcversion 1.21.1 -downloadMinecraft

# Run from the official slim java 11 image (alpine based images are way too big)
FROM amazoncorretto:21.0.4-al2023-headless

# Install useradd
RUN yum -y install shadow-utils

# Create a group and user minecraft
RUN groupadd -g 1002 minecraft && useradd minecraft -g minecraft -u 1002 -s /sbin/nologin
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
