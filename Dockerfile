FROM centos:7

MAINTAINER M Jordan Stanway "m.j.stanway@alum.mit.edu"

RUN yum update -y && yum install -y epel-release && yum repolist

RUN yum update -y && yum install -y \
    sudo vim wget curl \
    make gcc gcc-c++ kernel-devel bison libuuid-devel ncurses-devel zlib-devel lzo-devel intltool libtool tcl rpm-build \
    perl-ExtUtils-MakeMaker perl-Digest-MD5 perl-libwww-perl \
    glibc.i686 zlib.i686 tftp-server \
    gcc-arm-linux-gnu.x86_64 gcc-c++-arm-linux-gnu.x86_64 \
    glib2-devel cmake3

RUN groupadd -g 976 docker && \
    useradd --groups docker,wheel --shell /bin/bash --create-home ltib && \
    echo ltib:ltib | chpasswd && \
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers && \
    echo "ltib ALL = NOPASSWD: /usr/bin/yum, /usr/bin/rpm, /opt/ltib/usr/bin/rpm" >> /etc/sudoers && \
    cat /etc/sudoers

USER ltib
ENV HOME /home/ltib
RUN ["/bin/bash", "-c", "set -o pipefail && mkdir -p ${HOME}/ltib && wget -qO-  http://download.savannah.nongnu.org/releases/ltib/ltib-13-2-1-sv.tar.gz | tar zxv --directory ${HOME}/ltib --strip-components=1"]
WORKDIR ${HOME}/ltib/
RUN ./ltib --hostcf &> host_config.log & tail --pid $! -n +1 -F host_config.log

#WORKDIR /tmp

