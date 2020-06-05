# In order to run this container correctly, run the following command in the host as root:
#  sudo ../test-compile-in-container-osx-host-init.sh

FROM ubuntu:18.04

# Install prerequisites
RUN dpkg --add-architecture i386 && apt update && DEBIAN_FRONTEND=noninteractive apt install -y g++-multilib make python3 uuid-dev uuid-dev:i386 wget xz-utils zlib1g-dev zlib1g-dev:i386

# Downloader maloader source code
RUN mkdir /maloader-src && cd /maloader-src && \
	wget https://github.com/shinh/maloader/archive/464a90fdfd06a54c9da5d1a3725ed6229c0d3d60.tar.gz -O maloader.tar.gz && \
	tar --strip-components=1 -x -f maloader.tar.gz && rm -rf maloader.tar.gz

# Compile maloader, with on-the-fly patches to:
#  - disable -Werror because there is a warning
#  - workaround broken __darwin_stat definition on 32-bit
#  - workaround broken assumption that exec'ed programs are the same type (32 vs 64 bit) as the current one
RUN cd /maloader-src && \
    sed -i 's/-Werror//' Makefile && \
    sed -i 's/mac->st_blocks = linux_buf->st_blocks/mac->st_blocks = 0/' libmac/mac.c && \
    sed -i 's/add_loader_to_argv(argv)/argv/' libmac/mac.c && \
    sed -i 's/__loader_path,/argv[0],/' libmac/mac.c && \
    make both

# Make it possible to install the compiler here as a non-root user
RUN mkdir -m 777 /Applications
