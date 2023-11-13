FROM fedora:22

# Install prerequisites
RUN dnf install -y bison bzip2 clang file findutils flex gcc-c++ gettext libmpc-devel libstdc++-static libuuid-devel libxml2-devel llvm-devel make m4 openssl-devel patch perl tar wget which xz

# Download osxcross source code into /opt/osxcross
RUN mkdir -p /opt/osxcross
RUN cd /opt/osxcross && \
	wget "https://github.com/tpoechtrager/osxcross/archive/65edc522d7e8392945fec247790c15378c651ec8.tar.gz" -O osxcross.tar.gz && \
	tar --strip-components=1 -x -f osxcross.tar.gz && rm osxcross.tar.gz

# Download further auxiliary packages
RUN wget https://github.com/phracker/MacOSX-SDKs/releases/download/10.13/MacOSX10.5.sdk.tar.xz -O /opt/osxcross/tarballs/MacOSX10.5.sdk.tar.xz
RUN wget http://ftp.gnu.org/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.bz2 -O /opt/osxcross/tarballs/gcc-5.3.0.tar.bz2

# Build clang and remove temporary build directories
RUN cd /opt/osxcross && UNATTENDED=y ./build.sh && rm -rf /opt/osxcross/build/*/

# Add it to the PATH
ENV PATH="/opt/osxcross/target/bin:${PATH}"

# MONKEY PATCH: replace wget invocation with true to avoid re-downloading GCC
RUN sed -i 's/wget -c/true/' /opt/osxcross/build_gcc.sh

# Build gcc and remove all temporary build files
RUN cd /opt/osxcross && ./build_gcc.sh && rm -rf /opt/osxcross/build

CMD ["bash"]
