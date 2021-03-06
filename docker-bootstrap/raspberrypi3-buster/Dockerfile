FROM balenalib/raspberrypi3:buster

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

RUN echo cacert=/etc/ssl/certs/ca-certificates.crt > ~/.curlrc
RUN curl https://raw.githubusercontent.com/rubygems/rubygems/master/lib/rubygems/ssl_certs/index.rubygems.org/GlobalSignRootCA.pem > /etc/ssl/certs/GlobalSignRootCA.pem
ENV SSL_CERT_FILE=/etc/ssl/certs/GlobalSignRootCA.pem

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
