# RoustKit

Framework for experimenting with **out-of-tree Linux kernel modules written in Rust**.

> NOTE: this is still a work in progress and limited tests have been performed.
> Please open an issue if you observe any error during commands execution.

## Features

- Docker container with all the requirements for building Linux kernel and
  Rust out-of-tree LKMs
- Docker container for building a simple root filesystem (based on `debootstrap`)
- Docker container for emulating the compiled Linux kernel and Rust LKM

## Usage Overview

High level workflow:

- Be sure to satisfy the [requirements](#prerequisites)

- Setup the environment (docker images, Linux kernel source, etc):
  - see [Quick Start](#quick-start) section, or
  - [Usage](#usage) section for more details

- Once the setup is ready and the QEMU VM boots successfully, you can start
  [using the Rust LKM](#interacting-with-rust-lkm-inside-the-qemu-vm)

## Prerequisites

TODO
- docker (no root)
- openssl

## Quick Start

Be sure to start from a clean environment:

```bash
./scripts/clean_all.sh
```

For trying an automated setup, run:

```bash
./scripts/quick.sh
```

If the script completed successfully, you can start [using the Rust
LKM](#interacting-with-rust-lkm-inside-the-qemu-vm). Otherwise, follow the steps
reported in the section below (which is the list of commands executed
autmatically by `./scripts/quick.sh`).

### Quick Start (Step by Step)

Be sure to start from a clean environment:

```bash
./scripts/clean_all.sh
```

Build kernel and Rust module

```bash
# Download and extract the kernel source
./scripts/kernel_source_download_and_extract.sh
# Build the docker image (rkbuilder) for building the kernel and rust modules
./docker/rkbuilder/build.sh
# Execute docker container rkbuilder in interactive mode
./docker/rkbuilder/run.sh
# Command below from inside rkbuilder container
# Build kernel and rust module
./scripts/build_kernel_and_rust_lkm.sh
# Built Rust LKM will be located in src directory
```

Prepare root file system:

```bash
# Build Docker image (rkrootfs) for building the root filesystem
./docker/rootfs/build.sh
# Create the root filesystem
./docker/rootfs/create_rootfs.sh
```

Emulate and test the Rust module:

```bash
# Build Docker image (rkqemu) for emulation
./docker/qemu/build.sh
# Run qemu emulation rkqemu container
./docker/qemu/run_emulation.sh
# Note: it's pssible to run the emulation in detatched mode with
# ./docker/qemu/run_emulation.sh -b
```

## Interacting with Rust LKM inside the QEMU VM

Once the setup is complete and the QEMU VM boot is completed, you should see an
output similar to the following:

```
...
[  OK  ] Finished Raise network interfaces.
[  OK  ] Reached target Network.
         Starting OpenBSD Secure Shell server...
         Starting Permit User Sessions...
[  OK  ] Finished Permit User Sessions.
         Starting Hold until boot process finishes up...
         Starting Terminate Plymouth Boot Screen...

Debian GNU/Linux 11 ROUSTKIT ttyS0

ROUSTKIT login:
```

from another terminal window/tab:

- Copy the compiled Rust Linux kernel module into the QEMU VM:

```bash
scp -F .ssh_config -r src rkqemu:
```

- SSH into the QEMU VM:

```bash
ssh -F .ssh_config rkqemu
```

- `insmod` the Rust LKM:

```bash
insmod src/rust_oot.ko
```

- you can verify that the module has been correctly loaded from the kernel log:

```
dmes | grep rust_oot
```

## Usage

Be sure to start from a clean state:

```bash
./scripts/clean_all.sh
```

### Build Kernel and Rust Module

#### Docker Image for Building the Kernel and the Modules

Build the docker image (`rkbuilder`) used for building the Linux kernel source
code and the Rust out-of-tree Linux kernel modules:

```bash
./docker/rkbuilder/build.sh
```

Run the corresponding container in interactive mode with:

```bash
./docker/rkbuilder/run.sh
```

> NOTE: the `run.sh` script mounts the root directory of this repository inside
> the container in `$HOME/workspace` by default. The same directory is also set
> as the default working directory and the environment variable $WDIR is set to
> this directory.

If you ever need to stop or remove the container or remove the `rkbulder` docker
image for starting from scratch, you can use the following commands
rispectively:

```bash
./docker/rkbuilder/stop.sh
./docker/rkbuilder/rm_container.sh
./docker/rkbuilder/rm_image.sh
```

#### Kernel

Now it's possible to build the kernel and the Rust modules.

Execute all the commands inside the `rkbuilder` container.

A few notes: the instructions below assume that the linux kernel source code is
placed in `kernel/linux` directory on the host (this directory is mounted in
`$WDIR/kernel/linux` inside the container). Also, the insstructions
uses the directory `kernel/build` (mounted in `$WDIR/kernel/build`
inside the container) as the output directory for the kernel build process.
So, for example, for downloading and extracting the Linux kernel source code you
can execute the following commands (from `$WDIR` inside the
container):

```bash
wget -O kernel/archive https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.1.tar.xz
mkdir kernel/linux
tar -C kernel/linux -xf kernel/archive/linux-6.4.1.tar.xz --strip-components=1
```

The commands above can be automatize with:

```bash
./scripts/kernel_source_download_and_extract.sh
```

Once the Linux kernel source code has been extracted in `$WDIR/`

```bash
cd $WDIR/kernel/linux
# (Optional) Remove or move the old build directory if one already exist. E.g., rm -rf ../build
mkdir -p ../build
# make O=${PWD}/../build LLVM=1 ARCH=x86_64 rustavailable
make O=${PWD}/../build LLVM=1 ARCH=x86_64 defconfig
make O=${PWD}/../build LLVM=1 ARCH=x86_64 menuconfig
# Enable Rust Support:
# "General setup" -> "Rust support" [y]
#
# (Optional) enable Rust Examples:
# "Kernel hacking" -> "Sample kernel code" [y] -> "Rust samples" [y] -> enable [y] what you are interested in
#
# Exit the configuration menu and save the new configuration
make O=${PWD}/../build LLVM=1 ARCH=x86_64 -j2 all
# Wait for the kernel to complete the build
```

#### Rust Out-of-Tree Module

If the kernel build completed successfully, it is possible to build the Rust
out-of-tree kernel module with:

```bash
cd ${WDIR}/src
make
```


### Creating A Root File System

Start by creating the Docker image that will be used to generate the root
filesystem:

```bash
./docker/rootfs/build.sh
```

This will create a Docker image called `rkrootfs` and tagged as
`<rust-<version>-bindgen-<version>`. You can see this by running:

```bash
$ docker image ls | grep rkrootfs
rkrootfs       rust-1.62.0-bindgen-0.56.0   f98d5876eea9   13 minutes ago   644MB
```

At this point, it is possible to generate teh root filesystem by running:

```bash
./docker/rootfs/create_rootfs.sh
```

Internally the Docker image uses `debootstrap` for generating the root
filesystem (this is handled by the script `./docker/rootfs/rootfs.sh`) which by
default is placed in directory `rootfs` with name
`<debian_distribution>-<arch>-<fs_type>`:

```bash
ls ./rootfs
bullseye-x86_64-ext4
```

Also, by default there are two users in the automatically created filesystems:
`root` with no password and `user` with password `user`.

### Emulation with QEMU

Start by creating the Docker image that will be used to run the QEMU VM:

```bash
./docker/qemu/build.sh
```

TODO
- how to execute emulation
  - foreground
  - background

```bash
./docker/qemu/run_emulation.sh
```

```bash
./docker/qemu/run_emulation.sh -b
```

TODO
- How to reach QEMU VM
  - from host
  - from inside the container
  - which are the default ports
  - ssh configuration
  - etc

### Configuration

```
.env
```
TODO
- describe most important configuration entries
- we will improve this in next releases

### Turning off QEMU VM

TODO
- ctrl-a c quit
- poweroff
- rm_container

## Related Projects

These are project that allow to build/configure/test various Linux kernel
versions for different target architectures (and compilers).

- [kernel-build-containers](https://github.com/a13xp0p0v/kernel-build-containers)
- [like-dbg](https://github.com/0xricksanchez/like-dbg)
- [rust-out-of-tree-module](https://github.com/Rust-for-Linux/rust-out-of-tree-module)

## License

Licensed under:

- GNU GENERAL PUBLIC LICENSE Version 2 ([LICENSE-GPLv2](LICENSE-GPLv2))

