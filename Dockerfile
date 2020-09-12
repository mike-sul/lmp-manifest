FROM ubuntu:20.04

# bitbake requires a utf8 filesystem encoding
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV MACHINE=intel-corei7-64

ARG DEBIAN_FRONTEND=noninteractive
ARG DEV_USER_NAME=Builder
ARG DEV_USER_EMAIL="builder@foundries.io"
ARG DEV_USER=builder
ARG DEV_USER_PASSWD=builder
ARG DEV_OSF_TOKEN=foo

# FIO PPA for additional dependencies and newer packages
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   software-properties-common \
	&& add-apt-repository ppa:fio-maintainers/ppa \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		android-sdk-libsparse-utils android-sdk-ext4-utils ca-certificates \
		chrpath cpio diffstat file gawk g++ iproute2 iputils-ping less libmagickwand-dev \
		libmath-prime-util-perl libsdl1.2-dev libssl-dev locales \
		openjdk-11-jre openssh-client perl-modules python3 python3-requests \
		make patch repo sudo texinfo vim-tiny wget whiptail libelf-dev git-lfs \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& locale-gen en_US.UTF-8

# Create the user which will run the SDK binaries.
RUN useradd -c $DEV_USER_NAME \
		-d /home/$DEV_USER \
		-G sudo,dialout,floppy,plugdev,users \
		-m \
		-s /bin/bash \
		$DEV_USER

# Add default password for the SDK user (useful with sudo)
RUN echo $DEV_USER:$DEV_USER_PASSWD | chpasswd

# Initialize development environment for $DEV_USER.
RUN sudo -u $DEV_USER -H git config --global credential.helper 'cache --timeout=3600'
RUN sudo -u $DEV_USER -H git config --global user.name $DEV_USER_NAME
RUN sudo -u $DEV_USER -H git config --global user.email $DEV_USER_EMAIL

RUN echo "machine source.foundries.io" >> /home/$DEV_USER/.netrc
RUN echo "login $DEV_OSF_TOKEN" >> /home/$DEV_USER/.netrc

CMD /bin/bash -c "source setup-environment build && /bin/bash"
