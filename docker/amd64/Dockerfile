FROM resin/amd64-ubuntu:bionic-20181122
LABEL maintainer="roboto@gmx.net"

ARG ARCH="amd64"

ARG DEBIAN_FRONTEND=noninteractive

# Install locale
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        locales && \
        # Cleanup
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

RUN locale-gen --purge en_US.UTF-8
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# Install applications
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        autoconf \
        automake \
        autotools-dev \
        build-essential \
        curl \
        flex \
        g++-8 \
        gawk \
        gcc-arm-none-eabi \
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
        libnewlib-arm-none-eabi \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libstdc++-arm-none-eabi-newlib \
        libudev-dev \
        libusb-1.0-0-dev \
        zlib1g-dev \
        ssh && \
        # Cleanup
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Set default g++ to version 8
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 50 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 100 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 50 && \
    update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-7 100 && \
    update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-8 50 && \
    update-alternatives --set g++ /usr/bin/g++-8 && \
    update-alternatives --set gcc /usr/bin/gcc-8 && \
    update-alternatives --set cpp-bin /usr/bin/cpp-8

# Install Language Support (Node, Python, and Ruby)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nodejs \
        npm \
        python3 \
        python3-dev \
        python3-pip \
        ruby \
        ruby-dev && \
        # Cleanup
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# Install ESC firmware toolchain
RUN wget https://launchpad.net/gcc-arm-embedded/4.8/4.8-2013-q4-major/+download/gcc-arm-none-eabi-4_8-2013q4-20131204-linux.tar.bz2 && \
    tar xjf gcc-arm-none-eabi-4_8-2013q4-20131204-linux.tar.bz2 && \
    mv gcc-arm-none-eabi-4_8-2013q4 /usr/local/bin/ && \
    rm -rf gcc-arm-none-eabi-4_8-2013q4-20131204-linux.tar.bz2

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
    cmake \
    # AMD64 ONLY
    libglvnd0 \
    mesa-utils \
    qt5-default && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install npm packages
RUN npm install -g --production --unsafe-perm \
    node-gyp

# Install python packages
RUN pip3 install \
    awscli==1.14.36 \
    conan==1.16.1 \
    conan_package_tools==0.28.1 \
    semantic_version==2.6.0 \
    twine==1.12.1 \
    nose==1.3.7 \
    # AMD64 ONLY
    PyQt5

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
arch=x86_64\n\
os_build=Linux\n\
arch_build=x86_64\n\
compiler=gcc\n\
compiler.version=8\n\
compiler.libcxx=libstdc++11\n\
build_type=Release\n\
[options]\n\
[build_requires]\n\
[env]" > "/home/${USERNAME}/.conan/profiles/default" && \
        \
        echo "[settings]\n\
os=Linux\n\
arch=armv7\n\
os_build=Linux\n\
arch_build=x86_64\n\
compiler=gcc\n\
compiler.version=4.9\n\
compiler.libcxx=libstdc++\n\
build_type=Release\n\
[options]\n\
[build_requires]\n\
[env]" > "/home/${USERNAME}/.conan/profiles/arm-jessie" && \
        \
            echo "[settings]\n\
os=Linux\n\
arch=armv7\n\
os_build=Linux\n\
arch_build=x86_64\n\
compiler=gcc\n\
compiler.version=8.3\n\
compiler.libcxx=libstdc++\n\
build_type=Release\n\
[options]\n\
[build_requires]\n\
[env]" > "/home/${USERNAME}/.conan/profiles/arm-buster"



RUN sudo ln -s /opt/pidev/build/scripts/package-deb.sh /usr/bin/package-deb

# SETUP gradle
RUN mkdir -p ~/.gradle && \
        echo "artifactory_user=${ARTIFACTORY_USERNAME}" > ~/.gradle/gradle.properties && \
        echo "artifactory_password=${ARTIFACTORY_PASSWORD}" >> ~/.gradle/gradle.properties