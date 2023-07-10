# RoustKit

Docker containers for experimenting with out-of-tree Linux kernel modules
written in Rust.

# Dependencies

TODO
- docker (no root)
- openssh

# Quick Start

For trying an automated setup, run:

```
./scripts/quick.sh
```

otherwise, follow the steps reported below:

Build kernel and Rust module

```
# Download and extract the kernel source
./scripts/kernel_source_download_and_extract.sh
# Build the docker image (lkbuilder) for building the kernel and rust modules
./docker/lkbuilder/build.sh
# Execute docker container lkbuilder in interactive mode
./docker/lkbuilder/run.sh
# Command below from inside lkbuilder container
# Build kernel and rust module
./scripts/build_kernel_and_rust_lkm.sh
# Built Rust LKM will be located in src directory
```

Prepare root file system:

```
# Build Docker image (rootfs) for building the root filesystem
./docker/rootfs/build.sh
# Create the root filesystem
./docker/rootfs/create_rootfs.sh
```

Emulate and test the Rust module:

```
TODO
```

# Usage

## Build Kernel and Rust Module

### Docker Image for Building the Kernel and the Modules

Build the docker image (`lkbuilder`) used for building the Linux kernel source
code and the Rust out-of-tree Linux kernel modules:

```
./docker/lkbuilder/build.sh
```

Run the corresponding container in interactive mode with:

```
./docker/lkbuilder/run.sh
```

> NOTE: the `run.sh` script mounts the root directory of this repository inside
> the container in `$HOME/workspace` by default. The same directory is also set
> as the default working directory and the environment variable $WDIR is set to
> this directory.

If you ever need to stop or remove the container or remove the `lkbulder` docker
image for starting from scratch, you can use the following commands
rispectively:

```
./docker/lkbuilder/stop.sh
./docker/lkbuilder/rm_container.sh
./docker/lkbuilder/rm_image.sh
```

### Kernel

Now it's possible to build the kernel and the Rust modules.

Execute all the commands inside the `lkbuilder` container.

A few notes: the instructions below assume that the linux kernel source code is
placed in `kernel/linux` directory on the host (this directory is mounted in
`$WDIR/kernel/linux` inside the container). Also, the insstructions
uses the directory `kernel/build` (mounted in `$WDIR/kernel/build`
inside the container) as the output directory for the kernel build process.
So, for example, for downloading and extracting the Linux kernel source code you
can execute the following commands (from `$WDIR` inside the
container):

```
wget -O kernel/archive https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.4.1.tar.xz
mkdir kernel/linux
tar -C kernel/linux -xf kernel/archive/linux-6.4.1.tar.xz --strip-components=1
```

The commands above can be automatize with:

```
./scripts/kernel_source_download_and_extract.sh
```

Once the Linux kernel source code has been extracted in `$WDIR/`

```
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

### Rust Out-of-Tree Module

If the kernel build completed successfully, it is possible to build the Rust
out-of-tree kernel module with:

```
cd ${WDIR}/src
make
```


## Creating A Root File System

Start by creating the Docker image that will be used to generate the root
filesyste:

```
./docker/rootfs/build.sh
```

This will create a Docker image called `rootfs` and tagged as
`<rust-<version>-bindgen-<version>`. You can see this by running:

```
$ docker image ls | grep rootfs
rootfs       rust-1.62.0-bindgen-0.56.0   f98d5876eea9   13 minutes ago   644MB
```

At this point, it is possible to generate teh root filesystem by running:

```
./docker/rootfs/create_rootfs.sh
```

Internally the Docker image uses `debootstrap` for generating the root
filesystem (this is handled by the script `./docker/rootfs/rootfs.sh`) which by
default is placed in directory `rootfs` with name
`<debian_distribution>-<arch>-<fs_type>`:

```
ls ./rootfs
bullseye-x86_64-ext4
```

Also, by default there are two users in the automatically created filesystems:
`root` with no password and `user` with password `user`.

## Emulation with QEMU

## Configuration

```
.env
```


## Related Projects

These are project that allow to build/configure/test various Linux kernel
versions for different target architectures (and compilers).

- [kernel-build-containers](https://github.com/a13xp0p0v/kernel-build-containers)
- [like-dbg](https://github.com/0xricksanchez/like-dbg)
- [rust-out-of-tree-module](https://github.com/Rust-for-Linux/rust-out-of-tree-module)

## License

Licensed under:

- GNU GENERAL PUBLIC LICENSE Version 2 ([LICENSE-GPLv2](LICENSE-GPLv2))

