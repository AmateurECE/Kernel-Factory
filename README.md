### The Kernel Factory, Using Docker ###

Firstly, I can't take credit for this idea. Another solution to the problem I
describe below, and the one which inspired this repository, can be found here:

https://github.com/moul/docker-kernel-builder

This repository contains a Dockerfile for a container that sets up a complete
Linux kernel build environment. I encountered this problem while attempting to
compile an embedded Linux image on my home machine, a MacBook Air running OS X.

The image will contain only the checked out version of the kernel which resides
in the `linux-stable` repository at the time of image construction. The user
can update this at any time simply by checking out the newest version and then
committing their changes to the image in Docker.

For any more information about what the image contains, read the `Dockerfile`.

### Container Information ###

On my OS X machine, I have a startup script which launches this image on my
initial login:

```
docker run -d -p 32761:22 kernel-factory \
	-v /Volumes/shared-workspace:/shared-workspace
```

It's important to note that the `popcorn` script only allows the container to
run while it is being utilized by another process. Because of this, the user
should never start the container with the `--rm` flag and use the `popcorn`
script in conjunction.

The volume `shared-workspace` is a location on a ***case-sensitive***
filesystem. It is not used by the container by default, but the user may find
it helpful for transferring built kernels to and from the container.

### The Intended Workflow ###

A Bash script is included for convenience, which wraps the major Docker
commands in nifty little script calls. Below is a summary of the functionality
provided.

```
popcorn start	# Start the container
popcorn go		# Connect to the container via ssh.
```

From the root of the `kernel-factory` directory, run `./configure` with the
target
architecture, then `cd linux-stable` into the repository and build as normal.
Architectures supported by the makefile are listed below. The `kernel-factory`
directory contains two entries:

- `configure`: This makefile sets the environment to use the build tools for
the desired architecture. The process for using this Makefile is given below.
- `linux-stable/`: This is a checked out copy of the `linux-stable` repository.

```
cd /kernel-factory
./configure <arch> # Where <arch> is in {x86_64, arm[hf], aarch64, powerpc[64]}
```

To exit the container, the user simply runs `exit` (as if exiting an ssh
session).
