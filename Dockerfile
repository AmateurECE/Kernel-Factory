FROM ubuntu:xenial
LABEL maintainer="Ethan Twardy"
LABEL bugs="edtwardy@mtu.edu"

# Install the relevant packages
RUN apt-get update			\
    && apt-get -y upgrade		\
    && apt-get -y install		\
       openssh-server			\
       build-essential			\
       device-tree-compiler		\
       ccache				\
       git				\
       libncurses-dev			\
       libssl-dev			\
       wget				\
       bison				\
       flex				\
       bc				\
       gcc-arm-linux-gnueabi		\
       binutils-arm-linux-gnueabi	\
    && apt-get clean

# RUN apt-get install -y			\
#        gcc-arm-linux-gnueabihf		\
#        binutils-arm-linux-gnueabihf	\
#        gcc-aarch64-linux-gnu		\
#        binutils-aarch64-linux-gnu	\
#        gcc-powerpc-linux-gnu		\
#        binutils-powerpc-linux-gnu	\
#        gcc-powerpc64-linux-gnu		\
#        binutils-powerpc64-linux-gnu	\
#     && apt-get clean

# Set up sshd
RUN mkdir /var/run/sshd
RUN echo 'root:popcornRed123' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' \
    /etc/ssh/sshd_config

# This little ditty is listed here:
# https://docs.docker.com/engine/examples/running_ssh_service/
# I'm not sure if it's required or not, but it's here just in case.
ENV lib=pam_loginuid.so
RUN sed 's@session\s*required\s*'$lib'@session optional '$lib'@g'
ENV lib=

# Expose ssh port
EXPOSE 22

ENV CCACHE_DIR=/ccache						\
    FACTORY_DIR=/kernel-factory					\
    LINUX_REPO=pub/scm/linux/kernel/git/stable/linux-stable.git

RUN mkdir $FACTORY_DIR $CCACHE_DIR
RUN git clone git://git.kernel.org/$LINUX_REPO $FACTORY_DIR/linux-stable
# RUN git fetch --tags

WORKDIR $FACTORY_DIR
RUN echo "cd $FACTORY_DIR" >> /root/.bashrc

ADD contents/configure $FACTORY_DIR

# Start the daemon
CMD ["/usr/sbin/sshd", "-D"]
