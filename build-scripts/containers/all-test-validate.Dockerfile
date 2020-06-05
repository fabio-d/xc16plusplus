FROM ubuntu:18.04

# Install prerequisites
RUN dpkg --add-architecture i386 && apt update && apt install -y libexpat1:i386 libxext6:i386 python3 wget libstdc++6:i386

# Install MPLAB X IDE
RUN cd /tmp && \
	wget http://ww1.microchip.com/downloads/en/DeviceDoc/MPLABX-v5.40-linux-installer.tar && \
	tar xvf MPLABX-v5.40-linux-installer.tar && \
	rm MPLABX-v5.40-linux-installer.tar && \
	USER=root /tmp/MPLABX-v5.40-linux-installer.sh -- --mode unattended --unattendedmodeui none --ide 1 --ipe 0 --8bitmcu 0 --16bitmcu 1 --32bitmcu 0 --othermcu 0 --collectInfo 0 && \
	rm MPLABX-v5.40-linux-installer.sh
