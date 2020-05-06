FROM ubuntu:18.04

# Install prerequisites
RUN dpkg --add-architecture i386 && apt update && apt install -y make xz-utils libstdc++6:i386

# Make it possible to install the compiler here as a non-root user
RUN chmod 777 /opt
