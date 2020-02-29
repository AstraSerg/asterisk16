FROM ubuntu:18.04

ENV TZ=Europe/Moscow
ENV DEBIAN_FRONTEND=noninteractive
# DEBIAN_FRONTEND=noninteractive used also in ./contrib/scripts/install_prereq

RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
        aptitude \
        build-essential \
        curl \
        pkgconf \
        sox \
        subversion \
        tzdata

# aptitude used in ./contrib/scripts/install_prereq
# pkgconf used in ./contrib/scripts/install_prereq
# subversion used in ./contrib/scripts/get_mp3_source.sh
# tzdata used in ./contrib/scripts/install_prereq and must be run noninteractively

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# RUN apt-get purge -y --auto-remove \
#       && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/src \
        && cd /usr/local/src \
        && curl -Ok https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz 2>&1\
        && tar xvf asterisk* \
        && cd $(find /usr/local/src/ -type d -name asterisk\*) \
        && ./contrib/scripts/get_mp3_source.sh \
        && ./contrib/scripts/install_prereq install

RUN cd $(find /usr/local/src/ -type d -name asterisk\*) \
        && ./configure --with-resample --with-pjproject-bundled --with-jansson-bundled

RUN cd $(find /usr/local/src/ -type d -name asterisk\*) \
        && make menuselect/menuselect menuselect-tree menuselect.makeopts \
        && menuselect/menuselect --disable BUILD_NATIVE menuselect.makeopts \
        && menuselect/menuselect --enable BETTER_BACKTRACES menuselect.makeopts \
        && menuselect/menuselect --enable chan_ooh323 menuselect.makeopts \
        && menuselect/menuselect --enable CORE-SOUNDS-EN-ULAW menuselect.makeopts \
        && menuselect/menuselect --enable CORE-SOUNDS-EN-ALAW menuselect.makeopts \
        && menuselect/menuselect --enable CORE-SOUNDS-EN-G722 menuselect.makeopts \
        && menuselect/menuselect --enable CORE-SOUNDS-EN-GSM menuselect.makeopts \
        && menuselect/menuselect --enable CORE-SOUNDS-EN-SLN16 menuselect.makeopts \
        && menuselect/menuselect --enable MOH-OPSOUND-ULAW menuselect.makeopts \
        && menuselect/menuselect --enable MOH-OPSOUND-ALAW menuselect.makeopts \
        && menuselect/menuselect --enable MOH-OPSOUND-G722 menuselect.makeopts \
        && menuselect/menuselect --enable MOH-OPSOUND-GSM menuselect.makeopts \
        && menuselect/menuselect --enable MOH-OPSOUND-SLN16 menuselect.makeopts \
        && menuselect/menuselect --enable EXTRA-SOUNDS-EN-ULAW menuselect.makeopts \
        && menuselect/menuselect --enable EXTRA-SOUNDS-EN-ALAW menuselect.makeopts \
        && menuselect/menuselect --enable EXTRA-SOUNDS-EN-G722 menuselect.makeopts \
        && menuselect/menuselect --enable EXTRA-SOUNDS-EN-GSM menuselect.makeopts \
        && menuselect/menuselect --enable EXTRA-SOUNDS-EN-SLN16 menuselect.makeopts

RUN cd $(find /usr/local/src/ -type d -name asterisk\*) \
        && make all \
        && make install \
        && make samples

RUN apt-get --yes purge \
        autoconf \
        build-essential \
        bzip2 \
        cpp \
        m4 \
        make \
        patch \
        perl \
        perl-modules \
        pkg-config \
        xz-utils

RUN apt-get -y autoremove \
        && rm -rf /var/lib/apt/lists/*

VOLUME /var/lib/asterisk/keys /var/lib/asterisk/phoneprov /var/spool/asterisk /var/log/asterisk /usr/local/src /etc/asterisk /var/lib/asterisk/sounds /var/lib/asterisk/scripts/custom/ /var/spool/asterisk/monitor/ /var/spool/asterisk/voicemail/ /var/spool/asterisk/tmp/

# moved to docker-compose.yaml
# ENTRYPOINT ["/usr/sbin/asterisk", "-vvvdddf"]
# ENTRYPOINT ["tail",  "-f", "/dev/null"]

