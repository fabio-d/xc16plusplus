FROM ubuntu:18.04

# Install prerequisites
RUN dpkg --add-architecture i386 && apt update && apt install -y libexpat1 libexpat1:i386 python3 xz-utils libstdc++6:i386

# Make it possible to install the compiler here as a non-root user
RUN chmod 777 /opt
