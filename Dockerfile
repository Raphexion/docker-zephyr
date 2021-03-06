FROM ubuntu:16.04
MAINTAINER Lasse K. Mikkelsen <lkmikkel@gmail.com>

# Bring image up-to-date
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update; \
    apt-get upgrade -y;

# Zephyr requires gcc for arm 7+
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:team-gcc-arm-embedded/ppa; \
    apt-get update; \
    apt-get install -y gcc-arm-embedded;

# Use bash in favor of dash shit
RUN echo "dash dash/sh boolean false" | debconf-set-selections; \
    dpkg-reconfigure dash

RUN apt-get install -y --no-install-recommends \
    $(: Shell and core utilities) \
        apt-utils \
        bash \
        bash-completion \
        zsh \
        bc \
        coreutils \
        diffstat \
        diffutils \
        findutils \
        direnv \
        gawk \
        grep \
        less \
        locales \
        sed \
        util-linux \
	file \
    $(: Archiving and compression) \
        bzip2 \
        cpio \
        gzip \
        lzma \
        lzop \
        tar \
        unzip \
        xz-utils \
        zip \
    $(: Python) \
        python \
        python-dev \
        python-magic \
        python-pkg-resources \
        python-pycurl \
        python-svn \
        python3 \
	python3-pip \
	python3-setuptools \
	python3-wheel \
	python3-yaml \
    $(: Build infrastructure) \
        autoconf \
        automake \
        autopoint \
        make \
	ninja-build \
    $(: Compilers and friends) \
        binutils \
        bison \
        build-essential \
        cpp \
        chrpath \
        flex \
        g++ \
        gcc \
        gperf \
        libtool \
	device-tree-compiler \
    $(: Doc tools) \
        asciidoc \
        docbook-utils \
        groff \
        gtk-doc-tools \
        help2man \
        libxml2-utils \
        openjade \
        texi2html \
        texinfo \
        xmlto \
    $(: Version control) \
        cvs \
        git-core \
        mercurial \
        quilt \
        subversion \
    $(: Network) \
        curl \
        hostname \
        iproute2 \
        iputils-ping \
        wget \
        ssh \
    $(: Uncategorized) \
        fakeroot \
        libacl1-dev \
        libglib2.0-dev \
        mtd-utils \
        ncurses-dev \
        procps \
        sudo \
        vim \
	tmux \
  	ccache \
	dfu-util \
	usbutils \
    ; \
        apt-get clean

# pyelftools in ubuntu repo too old
RUN pip3 install pyelftools

# Zephyr requires cmake version 3.8.2+
RUN wget https://cmake.org/files/v3.12/cmake-3.12.3-Linux-x86_64.sh -O /tmp/cmake.sh
RUN sh /tmp/cmake.sh --skip-license
RUN rm /tmp/cmake.sh

# Start: nRF5x specific stuff

# Install nrfutil for nRF52840-dongle
RUN pip3 install nrfutil

# Install Segger JLink from website
RUN wget https://www.segger.com/downloads/jlink/JLink_Linux_x86_64.deb --post-data="accept_license_agreement=accepted&submit=Download software" -O /tmp/jlink.deb
RUN dpkg -i /tmp/jlink.deb
RUN rm /tmp/jlink.deb

# nRF5x Command Line Tools 9.8.0 from website
RUN wget http://www.nordicsemi.com/-/media/Software-and-other-downloads/Desktop-software/nRF5-command-line-tools/sw/nRF-Command-Line-Tools_9_8_1_Linux-x86_64.tar -O /tmp/nRF5x-Command-Line-Tools.tar
RUN tar xf /tmp/nRF5x-Command-Line-Tools.tar -C /usr/local/
RUN rm /tmp/nRF5x-Command-Line-Tools.tar
ENV PATH="$PATH:/usr/local/nrfjprog:/usr/local/mergehex"

# End: nRF5x specific stuff

# Generate and set a UTF-8 locale as default (required by yocto/bitbake)
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# Add build user
RUN groupadd admin; useradd -m -p $(openssl passwd -crypt user) -s /bin/zsh -G admin user;

# Setup direnv hooks
RUN echo 'eval "$(direnv hook bash)"' >> /home/user/.bashrc
RUN echo 'eval "$(direnv hook zsh)"' >> /home/user/.zshrc

# Set images to run as user
USER user
WORKDIR /home/user

# Set the image to start zsh by default
CMD ["/bin/zsh"]
