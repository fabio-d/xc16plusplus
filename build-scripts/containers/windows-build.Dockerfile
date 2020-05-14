FROM fedora:22

# Install prerequisites
RUN dnf install -y bison flex gcc m4 make mingw32-expat-static mingw32-gcc mingw64-expat-static mingw64-gcc

CMD ["bash"]
