ARG UBUNTU_VERSION
ARG DOCKER_PLATFORM
FROM ubuntu:${UBUNTU_VERSION} AS rootfs-base

# Install required basic tools
RUN set -x && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && apt-get upgrade && \
    apt-get install -yq --no-install-recommends sudo \
        git \
        wget \
        build-essential \
        gcc \
        make \
        file \
        unzip \
        python3 \
        python3-pip \
        python3-dev \
        perl \
        g++ \
        curl \
        openssh-server \ 
        apt-utils \
        locales \
        vim \
        wget \
        zsh \
        debootstrap \
        qemu \
        qemu-user-static \
        binfmt-support && \
    python3 -m pip install --upgrade --no-cache-dir pip && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get -y autoremove --purge && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd

# Setup users
ARG UNAME
ARG UID
ARG GID
ARG WDIR
RUN groupadd -g ${GID} ${UNAME} && \
    useradd -l -u ${UID} -g ${GID} -s "/bin/bash" -m -p "$(openssl passwd -1 ${UNAME})" ${UNAME} && \
    usermod -aG sudo ${UNAME} && \
    sed -ir "/^${UNAME}/ { s/:x:/::/ }" /etc/passwd && \
    mkdir -p /home/${UNAME}/.ssh && \
    echo "Defaults lecture = never" | tee -a /etc/sudoers.d/privacy

USER ${UNAME}
WORKDIR ${WDIR}

# COPY rootfs.sh .
COPY .ssh/id_rsa.pub /home/${UNAME}/.ssh/authorized_keys

CMD ["bash"]
