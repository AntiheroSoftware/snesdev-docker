FROM alpine:3.14 AS build

RUN apk add --update --no-cache gcc g++ make musl-dev unzip wget

WORKDIR /usr/src

ARG CC65_VERSION=2.19
ARG SUPERFAMICONV_VERSION=0.9.2

RUN wget https://github.com/cc65/cc65/archive/V${CC65_VERSION}.zip -O cc65-${CC65_VERSION}.zip \
  && unzip cc65-${CC65_VERSION}.zip \
  && cd cc65-${CC65_VERSION} \
  && PREFIX=/opt/cc65 make \
  && PREFIX=/opt/cc65 make install \
  && find /opt/cc65/bin -type f -exec strip {} \;

WORKDIR /usr/src

RUN wget https://github.com/AntiheroSoftware/SuperFamiconv/archive/refs/heads/master.zip \
  && unzip master.zip \
  && cd SuperFamiconv-master \
  && make \
  && cp /usr/src/SuperFamiconv-master/bin/superfamiconv /usr/bin/superfamiconv

RUN wget https://github.com/Optiroc/SuperFamicheck/archive/refs/heads/master.zip \
  && unzip master.zip \
  && cd SuperFamicheck-master \
  && make \
  && cp /usr/src/SuperFamicheck-master/bin/superfamicheck /usr/bin/superfamicheck

ADD tools/pcx2snes.c /usr/src/pcx2snes.c
RUN gcc /usr/src/pcx2snes.c -o /usr/bin/pcx2snes

FROM alpine:3.14

RUN apk add --update --no-cache make

RUN apk add --update --no-cache wine
RUN ln -s /usr/bin/wine64 /usr/bin/wine

COPY --from=build /opt/cc65 /opt/cc65
COPY --from=build /usr/bin/superfamiconv /usr/bin/superfamiconv
COPY --from=build /usr/bin/pcx2snes /usr/bin/pcx2snes

ENV PATH /opt/cc65/bin:$PATH

WORKDIR /project
