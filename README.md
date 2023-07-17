# RoustKit

Rust (out-of-tree) Linux kernel modules (LKMs) experimentation framework.

> NOTE: this is still a work in progress and limited tests have been performed.
> Please report any error/problem observed by opening an Issue. Thank you.

## Features

- Build Linux kernel and Rust out-of-tree LKMs
- Create a test root filesystem (based on `debootstrap`)
- Emulate the compiled Linux kernel and Rust LKMs

- Currently, by default, Linux kernel version 6.4.3 is used

## Usage Workflow

- Be sure to satisfy the [requirements](#prerequisites)

- Setup the environment (docker images, Linux kernel source, etc):
  - see [Quick Start](#quick-start) for automated setup, or
  - [Usage](#usage) section for more details and manual setup

- Once the setup is complete (and the QEMU VM boots successfully), you can start
  [experimenting with Rust
  LKMs](#interacting-with-rust-lkm-inside-the-qemu-vm)

## Prerequisites

NOTE: the framework has not been tested on Windows.

- A case sensitive filesystem is required. This is (usually) not a problem on
  Linux. However, MacOS by default uses a case insensitive filesystem. If you
  are trying this in MacOS, create an APFS case sensitive volume and execute all
  the commands from there. See
  [here](https://karnsonline.com/case-sensitive-apfs/) for instructions on how
  to create APFS case sensitive volumes.
- `openssl` must be installed. This is used for creating the SSH keys for
  logging into the QEMU VM.
- Docker must be installed and configured for being executed without root
  permissions. This is the default on MacOS. If you are using Linux see [Linux
  post-installation steps](https://docs.docker.com/engine/install/linux-postinstall/).

When all the requirements are satisfied:

```bash
git clone git@github.com:0xor0ne/roustkit.git
cd roustkit
```

## Quick Start

Be sure to start from a clean environment:

```bash
./scripts/clean_all.sh
```

For trying an automated setup, run the following script (this is going to take a
while to complete all the required steps):

```bash
./scripts/quick.sh
```

If the script completed successfully, you can start [experimenting whit the Rust
LKM](#interacting-with-rust-lkm-inside-the-qemu-vm). Otherwise, follow the steps
reported in the section below.
The section reports the list of commands executed automatically by
`./scripts/quick.sh`. Executing them one by one by hands could help in
identifying possible errors.

### Quick Start (Step by Step)

Be sure to start from a clean environment:

```bash
./scripts/clean_all.sh
```

Build kernel and Rust module:

```bash
# On the host:
# Download and extract the kernel source
./scripts/kernel_source_download_and_extract.sh
# Build the docker image (rkbuilder) for building the kernel and rust modules
./docker/rkbuilder/build.sh
# Execute docker container rkbuilder in interactive mode
./docker/rkbuilder/run.sh
# Inside rkbuilder container
# Build kernel and rust module
./scripts/build_kernel_and_rust_lkm.sh
# Built Rust LKM will be located in src directory
```

Prepare root file system:

```bash
# On the host:
# Build Docker image (rkrootfs) for building the root filesystem
./docker/rootfs/build.sh
# Create the root filesystem
./docker/rootfs/create_rootfs.sh
```

Emulate and test the Rust module:

```bash
# On the host:
# Build Docker image (rkqemu) for emulation
./docker/qemu/build.sh
# Run qemu emulation rkqemu container
./docker/qemu/run_emulation.sh
# Note: it's pssible to run the emulation in detatched mode with
# ./docker/qemu/run_emulation.sh -b
```

## Interacting with Rust LKM inside the QEMU VM

If the setup completed successfully you should have a running QEMU VM and see an
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

Now, from another terminal window/tab:

- Copy the compiled Rust Linux kernel module into the QEMU VM:

```bash
./scripts/scp_qemu.sh
```

- SSH into the QEMU VM:

```bash
./scripts/ssh_qemu.sh
```

- `insmod` the Rust LKM:

```bash
insmod /tmp/src/rust_oot.ko
```

- verify that the module has been correctly loaded:

```
dmes | grep rust_oot
...
[   72.263075] rust_oot: loading out-of-tree module taints kernel.
[   72.267374] rust_oot: Rust OOT sample (init)
```

The general workflow for developing the Rust LKM, building it, transferring it
on the QEMU VM and loading it is the following:

```bash
# On the host
# - Develop the Rust LKM in src directory
# - build it with
./docker/rkbuilder/run.sh scripts/rust_lkm_build.sh
# - Transfer it on QEMU VM (assuming it is already up and running, see above)
./scripts/scp_qemu.sh
# Inside the QEMU VM (use ./scripts/ssh_qemu.sh if not already connected)
rmmod rust_oot # Change this with the name of your module
insmod /tmp/src/rust_oot.ko
```

For turning off QEMU VM see the [dedicated section](#turning-off-qemu-vm).

## Usage

This section provides a little bit more details on the internal working of the
framework.

If you want to start from a clean state, run:

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
> as the default working directory and inside the container the environment
> variable $WDIR is set to this directory.

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

```
./docker/rkbuilder/run.sh
```

NOTES: the instructions below assume that the linux kernel source code is
placed in `kernel/linux` directory on the host (this directory is mounted in
`$WDIR/kernel/linux` inside the container). Also, the instructions
use the directory `kernel/build` (mounted in `$WDIR/kernel/build`
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

> NOTE: if you decide to use a different kernel version than the default one
> used by this framework, be sure to set correctly the configuration entries
> `RUST_VERSION` and `BINDGEN_VERSION`. See section
> [Configuration](#configuration) for the details.

Once the Linux kernel source code has been extracted, you can proceed to build
it:

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
make O=${PWD}/../build LLVM=1 ARCH=x86_64 -j4 all
# Wait for the kernel to complete the build
```

Instructions above can be automatize with:

```bash
${WDIR}/scripts/kernel_build.sh
```

In this case the configuration located in `kernel/configs/default` will be
copied in `kernel/build/.config` and used for building the kernel.

#### Rust Out-of-Tree Module

If the kernel build completed successfully, it is possible to build the Rust
out-of-tree kernel module with:

```bash
cd ${WDIR}/src
make
```

or, alternatively:

```bash
${WDIR}/scripts/rust_lkm_build.sh
```

### Creating A Root File System

The QEMU VM requires a basic root filesystem for emulating the linux kernel and
the Rust LKM. This section describes how to create such root filesystem.

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

At this point, it is possible to generate the root filesystem by running:

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

Also, by default there are two users configured in the created filesystems:
`root` with no password and `user` with password `user`.

If you ever need to stop or remove the container or remove the `rkrootfs` docker
image for starting from scratch, you can use the following commands
rispectively:

```bash
./docker/rootfs/stop.sh
./docker/rootfs/rm_container.sh
./docker/rootfs/rm_image.sh
```

### Emulation with QEMU

Start by creating the Docker image that will be used to run the QEMU VM:

```bash
./docker/qemu/build.sh
```

then you can start the emulation with

```bash
./docker/qemu/run_emulation.sh
```

or, in case you prefer to run this in background:

```bash
./docker/qemu/run_emulation.sh -b
```

You can log into the emulated system with user `root` without password (or as
`user` with password `user`).

If you executed the emulation in background or if you prefer to use another
terminal window, you can log into the emulated instance using SSH:

```
./scripts/ssh_qemu.sh
```

See [Networking](#networking) section for more details.

If you ever need to stop or remove the container or remove the `rkqemu` docker
image for starting from scratch, you can use the following commands
rispectively:

```bash
./docker/qemu/stop.sh
./docker/qemu/rm_container.sh
./docker/qemu/rm_image.sh
```

#### Turning off QEMU VM

From inside QEMU you can type `Ctrl-a` followed by `c` for entering the QEMU
console and then type `quit`.

Otherwise, always from inside QEMU, you can poweroff the system with `poweroff`.

Alternatively, from the host, you can remove the Docker container with:

```bash
./docker/qemu/rm_container.sh
```

### Configuration

Most of the framework configuration is kept inside the `.env` file.

Right now most of the entries in this file are for development purposes and I
suggest to keep them at their default values. In general the configuration
entries names should be self explanatory and when necessary a short comment is
contained directly inside the configuration file `.env`

Right now the most interesting entries from a user prospective are the ones at
the top. `RUST_VERSION` and `BINDGEN_VERSION` contains respectively the version
of the Rust toolchain and of the `bindgen` tool. These versions must match the
ones required by the Kernel version that will be built.

If you are in doubt you can retrieve the correct values for these entries from
the script `scripts/min-tool-version.sh` provided by the kernel source code. For
example, see
[here](https://elixir.bootlin.com/linux/latest/source/scripts/min-tool-version.sh)
the script for Linux kernel version 6.4.3.

The entry `KERNEL_SOURCE_URL` can be optionally set to an URL pointing to the
Linux kernel source code archive. This url will be automatically used by the
script `./scripts/kernel_source_download_and_extract.sh` for downloading and
extracting the kernel source code (See section [Kernel](#kernel) for more
information).

### Networking

The QEMU VM running inside the `rkqemu` Docker container can be reached from the
host with:

```bash
./scripts/ssh_qemu.sh
```

Under the hood this script is just running the following command:

```bash
ssh -F .ssh_config rkqemu
```

In the same way, it is possible to copy stuff from the host into the QEMU VM
using:

```bash
./scripts/scp_qemu.sh -s path/to/src -d path/to/dst
```

under the hood, this become:

```bash
scp -F .ssh_config -r path/to/src rkqemu:path/to/dst
```

Note that once the QEMU VM is running you can attach to the `rkqemu` container and
run the above commands directly from there (although this is not usually
necessary):

```bash
./docker/qemu/run.sh
scp -F .ssh_config -r path/to/src rkqemu:path/to/dst
ssh -F .ssh_config rkqemu
```

By default the QEMU VM bind the TCP port 10021 of the container to the port 22
inside the VM (this is configured by the entry `RKE_QEMU_NET` in `.env`). At the
same time the `rkqemu` docker container binds the host port 10021 to the
container port 10021 (see `RKE_DOCKER_RUN_ADD_OPT`).

## Related Projects

These are projects that allow to build/configure/test/debug various Linux kernel
versions for different target architectures (and compilers).

- [kernel-build-containers](https://github.com/a13xp0p0v/kernel-build-containers)
- [like-dbg](https://github.com/0xricksanchez/like-dbg)

This project contains a Rust out-of-tree Linux kernel module template:

- [rust-out-of-tree-module](https://github.com/Rust-for-Linux/rust-out-of-tree-module)

## Contributions

At the current time there is not a formal procedure for contributions.
Limited tests have been performed so far and the framework is still in its early
development stage. Please open an Issue for any problem/error observed.

## License

Licensed under:

- GNU GENERAL PUBLIC LICENSE Version 2 ([LICENSE-GPLv2](LICENSE-GPLv2))

