FROM fedora:22

# Install prerequisites
RUN dnf install -y bison expat-devel expat-devel.i686 flex gcc glibc-devel glibc-devel.i686 libgcc.i686 m4 make

CMD ["bash"]
