ARG UBUNTU_VERSION
ARG DOCKER_PLATFORM
FROM ubuntu:${UBUNTU_VERSION} AS rkbuilder-base

# Install required basic tools (+ compilers)
RUN set -x && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update && apt-get upgrade && \
    apt-get install -y -q apt-utils dialog && \
    apt-get install -y -q sudo curl aptitude flex bison \
        libncurses5-dev make git exuberant-ctags sparse bc libssl-dev libelf-dev \
        wget curl vim && \
    apt-get install -y -q gcc g++ \
        gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
        gcc-arm-linux-gnueabi g++-arm-linux-gnueabi && \
    apt-get install -y -q clang clang-tools lld llvm;

# Setup users
ARG UNAME
ARG UID
ARG GID
ARG WDIR
RUN set -x && \
    userdel -r `getent passwd ${UID} | cut -d : -f 1` > /dev/null 2>&1; \
    groupdel -f `getent group ${GID} | cut -d : -f 1` > /dev/null 2>&1; \
    groupadd -g ${GID} -o ${UNAME} && \
    useradd -u $UID -g $GID -G sudo -ms /bin/bash ${UNAME} && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "Set disable_coredump false" >> /etc/sudo.conf

USER ${UNAME}
WORKDIR ${WDIR}

# Install basic rust tools
# Find toolchain version required in scripts/min-tool-version.sh in linux source
# For overwriting after image creation see https://www.kernel.org/doc/html/next/rust/quick-start.html
ARG RUST_VERSION
ARG BINDGEN_VERSION
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain ${RUST_VERSION} -y
ENV PATH="/home/${UNAME}/.cargo/bin:${PATH}"
RUN rustup component add rust-src && \
    cargo install --locked --version ${BINDGEN_VERSION} bindgen && \
    rustup component add rustfmt && \
    rustup component add clippy

CMD ["bash"]
