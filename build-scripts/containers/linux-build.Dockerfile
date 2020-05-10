FROM fedora:22

# Install prerequisites
RUN dnf install -y bison flex gcc glibc-devel glibc-devel.i686 libgcc.i686 m4 make

CMD ["bash"]
