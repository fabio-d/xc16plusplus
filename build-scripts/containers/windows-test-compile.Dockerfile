FROM ubuntu:18.04

# Install prerequisites
RUN dpkg --add-architecture i386 && apt update && DEBIAN_FRONTEND=noninteractive apt install -y unzip wget xz-utils

# Install Wine
RUN cd /tmp && \
	wget https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-amd64/wine-stable_4.0~bionic_amd64.deb && \
	wget https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-amd64/wine-stable-amd64_4.0~bionic_amd64.deb && \
	wget https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-i386/wine-stable-i386_4.0~bionic_i386.deb && \
	DEBIAN_FRONTEND=noninteractive apt install --no-install-recommends -y ./*.deb && rm *.deb

# Unpack Python
RUN wget https://www.python.org/ftp/python/3.6.0/python-3.6.0-embed-amd64.zip -O /tmp/python.zip && \
	unzip /tmp/python.zip -d /python && rm /tmp/python.zip

# Make it possible to run wine as non-root user (the actual WINEPREFIX will be
# a subdirectory created by test-compile-in-container-windows-impl.sh)
RUN mkdir -m 777 /wine
ENV PATH="/opt/wine-stable/bin:$PATH"
