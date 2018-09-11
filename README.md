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
committing their changes to the image in `docker`.

When the user builds the image as directed below, a `user` is created in the
container which has the same name, but a separate uid and gid, as the current
user. No password is created.

For any more information about what the image contains, read the `Dockerfile`.

### Container Information ###

On my OS X machine, I have a startup script which launches this image on my
initial login:

```
docker run -d --rm kernel-factory \
	-v /Volumes/shared-workspace:/home/<user>/shared-workspace
```

The volume `shared-workspace` is a location on a ***case-sensitive***
filesystem. By default, the completed image is placed here under the directory
`kernel.build`. The user should take note, as this directory is removed, along
with its contents, whenever a build is started. Additionally, the user may
place sources to build on this volume, as long as the corresponding `Makefile`s
are edited accordingly.

Because this is the default behavior, the user should ensure that the container
is started with a mounted volume at the path `/home/<user>/shared-workspace`.
If this directory does not exist, the custom Makefile provided in the image
will complain and exit.

### The Intended Workflow ###

A `bash` script is included for convenience, which wraps the major Docker
commands in nifty little script calls. Below is a summary of the functionality
provided.

```
popcorn go		# Connect to the container via ssh.
popcorn stop	# Stop the container and remove it.
```

Once inside the container, the structure of the linux repository has been
slightly altered to streamline the build process even further. From the root of
the `kernel-factory` directory, run `make` with the target architecture, then
`make`. Supported architectures are listed below. The `kernel-factory`
directory contains two entries:

- `Makefile`: This is my streamlined makefile. The process for using this
Makefile is given below.
- `linux-stable/`: This is a checked out copy of the `linux-stable` repository.

```
cd /home/<user>/kernel-factory
make <arch> # Where <arch> is in {i386, x86_64, armhf, arm, arm64, powerpc}
make
```

If building using the custom streamlined Makefile, the image is automatically
placed into the directory at `/home/<user>/shared-workspace` as noted above.

To exit the container, the user simply runs `exit` (as if exiting an ssh
session).
