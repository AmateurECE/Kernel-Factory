###############################################################################
# NAME:		    Makefile
#
# AUTHOR:	    Ethan D. Twardy <edtwardy@mtu.edu>
#
# DESCRIPTION:	    This is the Makefile for the Docker container.
#
# CREATED:	    09/18/2018
#
# LAST EDITED:	    09/18/2018
###

linuxRepo=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
location=contents/linux-stable

all: docker

linux-repo:
	@if [ ! -d $(location) ]; then \
		git clone $(linuxRepo) $(location); \
	fi
	@cd $(location)
	@git fetch --tags

docker: linux-repo
	docker build --rm -t kernel-factory .

##############################################################################
