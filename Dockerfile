#Get the same base image as the final image
FROM alpine:3.11 AS builder

RUN apk add --no-cache gcc libc-dev

#Get the statically built megatools binary and extract it
RUN wget https://megatools.megous.com/builds/experimental/megatools-1.11.0-git-20191107-linux-x86_64.tar.gz -q -O megatools.tar.xz \
 && tar -xzf megatools.tar.xz

#Statically compile mcrcon
RUN wget -q https://raw.githubusercontent.com/Tiiffi/mcrcon/master/mcrcon.c \
 && gcc -std=gnu99 -Wpedantic -Wall -Wextra -Os -s -static -o mcrcon mcrcon.c

################

# Run from the smallest java 11 image
FROM adoptopenjdk/openjdk11:x86_64-alpine-jre-11.0.6_10

# Create a group and user minecraft
RUN addgroup -g 1002 -S minecraft && adduser minecraft -S -G minecraft -u 1002 -s /sbin/nologin
# Tell docker that all future commands should run as minecraft user
USER minecraft

# set home dir as our workdir
WORKDIR /home/minecraft

# Download minecraft server version 1.15.2 and store it in minecraft homedir
ADD --chown=minecraft:minecraft https://launcher.mojang.com/v1/objects/bb2b6b1aefcd70dfd1892149ac3a215f6c636b07/server.jar .
# Copy the megatools binary from the builder stage
COPY --from=builder --chown=minecraft:minecraft /megatools-1.11.0-git-20191107-linux-x86_64/megatools .
# Copy the mcrcon binary from the builder stage
COPY --from=builder --chown=minecraft:minecraft /mcrcon .

# declare the volume that will hold the configuration files
VOLUME /home/minecraft/conf
# copy the configuration files to the volume
COPY --chown=minecraft:minecraft conf/ conf/

# start the server
WORKDIR /home/minecraft/conf
ENTRYPOINT ["java", "-jar", "../server.jar", "nogui"]
