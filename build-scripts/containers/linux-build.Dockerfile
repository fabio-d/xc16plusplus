FROM i386/debian:8

# Install prerequisites
RUN apt update && apt install -y bison flex gcc gettext m4 make
