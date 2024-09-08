FROM ubuntu:16.04

ARG user=ubuntu
ARG group=ubuntu
ARG passwd=1
ARG uid=1000
ARG gid=1000
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Etc/UTC

# Install essential tools and deps
RUN dpkg --add-architecture i386
WORKDIR /tmp/apt
COPY ./requirements/apt/* /tmp/apt/
RUN apt -y update && apt -y upgrade && apt -y install \
    $(cat /tmp/apt/*) \
    && rm -rf /var/lib/apt/lists/*

# Set apt-file cache
RUN apt-file update

# Build openssl1.1.1
WORKDIR /tmp/openssl/
RUN wget https://www.openssl.org/source/openssl-1.1.1l.tar.gz
RUN tar -zxf openssl-1.1.1l.tar.gz
WORKDIR /tmp/openssl/openssl-1.1.1l
RUN ./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared zlib
RUN make -j $((`nproc`+1))
RUN make install

# Create symlinks for openssl
RUN ln -s /usr/local/ssl/lib/libcrypto.so.1.1 /lib/x86_64-linux-gnu/
RUN ln -s /usr/local/ssl/lib/libssl.so.1.1 /lib/x86_64-linux-gnu/

# Build python3
WORKDIR /tmp/python3/
RUN wget https://www.python.org/ftp/python/3.12.5/Python-3.12.5.tar.xz
RUN tar -xf Python-3.12.5.tar.xz
WORKDIR /tmp/python3/Python-3.12.5
RUN TCLTK_LIBS="-ltk8.6 -ltkstub8.6 -ltcl8.6" TCLTK_CFLAGS="-I/usr/include/tcl8.6" \
    ./configure --enable-optimizations --with-openssl=/usr/local/ssl
RUN make -j $((`nproc`+1))
RUN make -j $((`nproc`+1)) install

# Update pip for python3
RUN python3 -m pip install --upgrade pip

# Configure /usr/bin/python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 2

# Install all of the python2 packages
COPY ./requirements/python/python2.requirements.txt /tmp/python2.requirements.txt
RUN python2 -m pip install --upgrade -r /tmp/python2.requirements.txt

# Install all of the python packages
COPY ./requirements/python/python3.requirements.txt /tmp/python3.requirements.txt
RUN python3 -m pip install --upgrade -r /tmp/python3.requirements.txt

# Build gdbserver
WORKDIR /tmp/gdbserver/
RUN wget https://ftp.gnu.org/gnu/gdb/gdb-11.1.tar.xz
RUN tar -xf gdb-11.1.tar.xz
WORKDIR /tmp/gdbserver/gdb-11.1
RUN ./configure  --disable-gdb --disable-ld --disable-gas --disable-sim --disable-gprofng
RUN make -j $((`nproc`+1))
RUN make -j $((`nproc`+1)) install

# Install Pwndbg
WORKDIR /tmp/pwndbg/
RUN wget https://github.com/pwndbg/pwndbg/releases/download/2023.07.17-pkgs/pwndbg_2023.07.17_amd64.deb
RUN dpkg -i pwndbg_2023.07.17_amd64.deb
RUN mv /usr/bin/gdb /usr/bin/gdb.orig
RUN ln -s /usr/bin/pwndbg /usr/bin/gdb

# Fix locale
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

# Disable AT_BRIDGE
RUN echo "NO_AT_BRIDGE=1" >> /etc/environment

# Create a non root user for convenience
RUN groupadd -g ${gid} ${group} && useradd -rm -s /bin/zsh -g ${gid} -G sudo -u ${uid} ${user} && echo "${user}:${passwd}" | chpasswd
USER ${user}
WORKDIR /home/${user}

# Install oh-my-zsh
WORKDIR /home/${user}
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -x \
    -t robbyrussell \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

# Set GNU Screen to use zsh
RUN echo 'shell "/usr/bin/zsh"' > ~/.screenrc

# Create user "Source" dir
RUN mkdir /home/${user}/Source

# Change PS1 in zsh
RUN echo 'export PS1="(docker) $PS1"' >> ~/.zshrc

# Set the default shell to zsh
ENTRYPOINT [ "/usr/bin/zsh" ]
