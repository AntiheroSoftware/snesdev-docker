FROM alpine:edge AS build

RUN apk add --update --no-cache gcc g++ clang make cmake musl-dev unzip wget libpng-static libpng-dev pkgconf zlib-static zlib-dev

WORKDIR /usr/src

ARG CC65_VERSION=2.19
ARG SUPERFAMICONV_VERSION=0.9.2

#RUN wget https://github.com/cc65/cc65/archive/V${CC65_VERSION}.zip -O cc65-${CC65_VERSION}.zip \
#  && unzip cc65-${CC65_VERSION}.zip \
#  && cd cc65-${CC65_VERSION} \

RUN wget https://github.com/cc65/cc65/archive/refs/heads/master.zip -O cc65-master.zip \
  && unzip cc65-master.zip \
  && cd cc65-master \
  && PREFIX=/opt/cc65 make \
  && PREFIX=/opt/cc65 make install \
  && find /opt/cc65/bin -type f -exec strip {} \;

WORKDIR /usr/src

RUN wget https://github.com/Optiroc/SuperFamiconv/archive/refs/heads/main.zip \  
  && unzip main.zip \
  && cd SuperFamiconv-main \
  && make \
  && cp /usr/src/SuperFamiconv-main/build/release/superfamiconv /usr/bin/superfamiconv \
  && cd .. && rm -rf main.zip 

#RUN wget https://github.com/AntiheroSoftware/SuperFamiconv/archive/refs/heads/master.zip \
#  && unzip master.zip \
#  && cd SuperFamiconv-master \
#  && make \
#  && cp /usr/src/SuperFamiconv-master/build/release/superfamiconv /usr/bin/superfamiconv \
#  && cd .. && rm -rf master.zip 

RUN wget https://github.com/Optiroc/SuperFamicheck/archive/refs/heads/main.zip \
  && unzip main.zip \
  && cd SuperFamicheck-main \
  && make \
  && cp /usr/src/SuperFamicheck-main//build/release/superfamicheck /usr/bin/superfamicheck \
  && cd .. && rm -rf main.zip 

ADD tools/pcx2snes.c /usr/src/pcx2snes.c
RUN gcc /usr/src/pcx2snes.c -o /usr/bin/pcx2snes

RUN wget https://github.com/alekmaul/pvsneslib/archive/refs/heads/master.zip \
  && unzip master.zip \
  && cd pvsneslib-master/tools/gfx2snes \
  && make \
  && cp /usr/src/pvsneslib-master/tools/gfx2snes/gfx2snes /usr/bin/gfx2snes \
  && rm -rf /usr/src/master.zip

RUN wget https://github.com/alekmaul/pvsneslib/releases/download/4.1.0/pvsneslib_410_64b_linux_release.zip \
  && unzip pvsneslib_410_64b_linux_release.zip \
  && mv pvsneslib /opt/pvsneslib \
  && rm pvsneslib_410_64b_linux_release.zip

RUN wget https://github.com/emmanuel-marty/lzsa/archive/refs/heads/master.zip \
  && unzip master.zip \
  && cd lzsa-master \
  && make \
  && cp lzsa /usr/bin/lzsa \
  && cd .. && rm -rf master.zip lzsa-master

RUN wget https://github.com/Kannagi/Higueul/archive/refs/tags/betav0.22.zip \
  && unzip betav0.22.zip \
  && cd Higueul-betav0.22 \
  && make bin \
  && cp ./bin/higueulc /usr/bin/higueulc

RUN wget https://github.com/dbohdan/hicolor/archive/refs/heads/master.zip \
  && unzip master.zip \
  && cd hicolor-master \
  && make \
  && ls -alR

FROM alpine:edge

RUN apk add --update --no-cache make gcc musl-dev gdb nodejs npm git imagemagick argp-standalone

#RUN apk add --update --no-cache wine
#RUN ln -s /usr/bin/wine64 /usr/bin/wine

COPY --from=build /opt/cc65 /opt/cc65
COPY --from=build /usr/bin/superfamiconv /usr/bin/superfamiconv
COPY --from=build /usr/bin/superfamicheck /usr/bin/superfamicheck
COPY --from=build /usr/bin/pcx2snes /usr/bin/pcx2snes
COPY --from=build /usr/bin/gfx2snes /usr/bin/gfx2snes
COPY --from=build /opt/pvsneslib /opt/pvsneslib
COPY --from=build /usr/bin/lzsa /usr/bin/lzsa
COPY --from=build /usr/bin/higueulc /usr/bin/higueulc

RUN npm -g  install @antiherosoftware/tile-quantitizer@1.0.4 

ENV PATH /opt/cc65/bin:$PATH
ENV PVSNESLIB_HOME /opt/pvsneslib

ENV LANG=C.UTF-8

# NOTE: Glibc 2.35 package is broken: https://github.com/sgerrand/alpine-pkg-glibc/issues/176, so we stick to 2.34 for now
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.34-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    mv /etc/nsswitch.conf /etc/nsswitch.conf.bak && \
    apk add --no-cache --force-overwrite \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    mv /etc/nsswitch.conf.bak /etc/nsswitch.conf && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    (/usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true) && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

WORKDIR /project
