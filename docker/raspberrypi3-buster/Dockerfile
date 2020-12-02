FROM balenalib/raspberrypi3-node:11.9.0-buster-build-20190215
LABEL maintainer="roboto@gmx.net"

ARG ARCH="armhf"
ARG DEBIAN_FRONTEND=noninteractive

# Install locale
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#         locales && \
#         # Cleanup
#         apt-get clean && \
#         rm -rf /var/lib/apt/lists/*
RUN install_packages \
        locales

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale && \
        echo "LANG=en_US:en" >> /etc/default/locale && \
        locale-gen en_US en_US.UTF-8 && \
        dpkg-reconfigure locales 

# Install applications
RUN install_packages \
        apt-transport-https \
        apt-utils \
        autoconf \
        automake \
        autotools-dev \
        build-essential \
        curl \
        flex \
        g++ \
        gawk \
        gcc \
        gettext \
        git \
        git-core \
        groovy \
        libtool \
        llvm \
        make \
        moreutils \
        nano \
        net-tools \
        pkg-config \
        subversion \
        tar \
        tk-dev \
        unzip \
        vim \
        wget \
        xz-utils \
        zip \
        # Install libraries
        libbz2-dev \
        libffi-dev \
        liblzma-dev \
        libncurses5-dev \
        libncursesw5-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libudev-dev \
        libusb-1.0-0-dev \
        zlib1g-dev   
        # && \
        # # Cleanup
        # apt-get clean && \
        # rm -rf /var/lib/apt/lists/*

# Install Language Support (Node, Python, and Ruby)
RUN install_packages \
        python3 \
        python3-dev \
        python3-pip \
        ruby \
        ruby-dev && \
        # Cleanup
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

RUN mkdir /root/workspace
WORKDIR /root/workspace

# Upgrade pip and setuptools
# NOTE: Must be done BEFORE updating the pip conf, which includes an extra index URL, due to a bug in
# the debian packaged version of python-pip3: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=837764
RUN python3 -m pip install --upgrade pip setuptools

ARG DIST_NAME
COPY common/scripts/*.sh /opt/pidev/build/scripts/

# Set up public debian, conan, and pypi repositories

RUN /opt/pidev/build/scripts/setup_public_deb_repo.sh
RUN /opt/pidev/build/scripts/setup_pip_config.sh

# Install Software
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cmake && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install python packages
RUN pip3 install \
    awscli==1.16.193 \
    colorama==0.3.7 \
    conan==1.16.1 \
    conan_package_tools==0.28.1 \
    semantic_version==2.6.0 \
    twine==1.12.1 \
    nose==1.3.7

# Install debian packaging utility
RUN gem install fpm

# Setup user
ENV USERNAME user
RUN groupadd admin
RUN useradd -m ${USERNAME} && \
    echo "${USERNAME}:${USERNAME}" | chpasswd && \
    usermod --shell "/bin/bash" "${USERNAME}" && \
    usermod -aG sudo "${USERNAME}" && \
    usermod -aG dialout "${USERNAME}" && \
    usermod -aG admin "${USERNAME}" && \
    usermod -d "/home/${USERNAME}" "${USERNAME}" && \
    usermod --uid 1000 "${USERNAME}" && \
    groupmod --gid 1000 "${USERNAME}" -o && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} && \
    chmod 0440 "/etc/sudoers.d/${USERNAME}" && \
    chown -R "${USERNAME}":"${USERNAME}" /home/${USERNAME}

RUN echo "Defaults exempt_group+=admin" >> /etc/sudoers

############################################################
# Non-Root Section

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENV PATH /home/${USERNAME}/bin:$PATH
ENV HOME /home/${USERNAME}

RUN mkdir -p \
    /home/${USERNAME}/bin \
    /home/${USERNAME}/lib \
    /home/${USERNAME}/include \
    /home/${USERNAME}/workspace
RUN touch /home/${USERNAME}/.sudo_as_admin_successful

# Set up Conan Profile
RUN conan remote remove conan-center && \
    conan remote add bincrafters "https://api.bintray.com/conan/bincrafters/public-conan" True && \
    conan remote add conan-center "https://conan.bintray.com" True && \
    mkdir -p "/home/${USERNAME}/.conan/profiles" && \
    echo "[settings]\n\
os=Linux\n\
arch=armv7\n\
os_build=Linux\n\
arch_build=armv7\n\
compiler=gcc\n\
compiler.version=8.3\n\
compiler.libcxx=libstdc++\n\
build_type=Release\n\
[options]\n\
[build_requires]\n\
[env]" > "/home/${USERNAME}/.conan/profiles/default"

COPY common/scripts/package-deb.sh /usr/bin/package-deb

# SETUP gradle
RUN mkdir -p ~/.gradle && \
        echo "artifactory_user=${ARTIFACTORY_USERNAME}" > ~/.gradle/gradle.properties && \
        echo "artifactory_password=${ARTIFACTORY_PASSWORD}" >> ~/.gradle/gradle.properties