FROM alpine:edge AS build

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
  && cp /usr/src/SuperFamiconv-master/bin/superfamiconv /usr/bin/superfamiconv \
  && cd .. && rm -rf master.zip 

RUN wget https://github.com/Optiroc/SuperFamicheck/archive/refs/heads/master.zip \
  && unzip master.zip \
  && cd SuperFamicheck-master \
  && make \
  && cp /usr/src/SuperFamicheck-master/bin/superfamicheck /usr/bin/superfamicheck \
  && cd .. && rm -rf master.zip 

ADD tools/pcx2snes.c /usr/src/pcx2snes.c
RUN gcc /usr/src/pcx2snes.c -o /usr/bin/pcx2snes

RUN wget https://github.com/alekmaul/pvsneslib/archive/refs/heads/master.zip \
  && unzip master.zip \
  && cd pvsneslib/tools/gfx2snes \
  && make \
  && cp /usr/src/pvsneslib/tools/gfx2snes/gfx2snes /usr/bin/gfx2snes \
  && rm -rf /usr/src/master.zip

FROM alpine:edge

RUN apk add --update --no-cache make gcc musl-dev gdb

RUN apk add --update --no-cache wine
RUN ln -s /usr/bin/wine64 /usr/bin/wine

COPY --from=build /opt/cc65 /opt/cc65
COPY --from=build /usr/bin/superfamiconv /usr/bin/superfamiconv
COPY --from=build /usr/bin/superfamicheck /usr/bin/superfamicheck
COPY --from=build /usr/bin/pcx2snes /usr/bin/pcx2snes
COPY --from=build /usr/bin/gfx2snes /usr/bin/gfx2snes

ENV PATH /opt/cc65/bin:$PATH

WORKDIR /project
