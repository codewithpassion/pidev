FROM resin/amd64-ubuntu:bionic-20181122

LABEL maintainer="roboto@gmx.net"
ARG ARCH="armhf"
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
            ruby \
            ruby-dev \
            wget \
            apt-transport-https \
            apt-utils \
            autoconf \
            automake \
            make \
            autotools-dev \
            build-essential \
            curl \
            flex \
            g++ \
            g++-8 \
            gawk \
            gcc \
            cmake \
            gettext \
            libssl-dev \
            python3 \
            python3-dev \
            python3-pip && \
     pip3 install \
        setuptools && \
     pip3 install \
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

############################################################
# Non-Root Section

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENV PATH /home/${USERNAME}/bin:$PATH
ENV HOME /home/${USERNAME}

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
[env]" > "/home/${USERNAME}/.conan/profiles/default"