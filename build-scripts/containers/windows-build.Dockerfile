FROM fedora:22

# Install prerequisites
RUN dnf install -y bison flex gcc m4 make mingw32-gcc mingw64-gcc

CMD ["bash"]
