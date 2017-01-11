FROM alpine:3.5

MAINTAINER Andre Cantero <thecantero@gmail.com>

# Run-time Dependencies

RUN apk upgrade --update
ENV RUNTIME_PKGS="rsync perl gd zlib libpng jpeg freetype mysql perl-plack findutils"

ENV RUNTIME_EDGE_TESTING_PKGS="perl-json-xs"

ENV DEV_PKGS="build-base git gd-dev zlib-dev libpng-dev jpeg-dev freetype-dev mysql-dev perl-dev perl-libwww perl-mail-tools perl-apache-logformat-compiler perl-devel-stacktrace perl-devel-stacktrace-ashtml perl-filesys-notify-simple perl-devel-globaldestruction expat-dev chrpath"

ENV DEV_EDGE_PKGS="perl-module-install perl-yaml perl-file-remove"

# Run-time dependencies
RUN apk add --virtual .runtime-dependencies $RUNTIME_PKGS
RUN apk add --virtual .runtime-dependencies $RUNTIME_EDGE_TESTING_PKGS --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

# Build Dependencies
RUN apk add --virtual .build-dependencies $DEV_PKGS
RUN apk add --virtual .build-dependencies $DEV_EDGE_PKGS --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted

# Users
RUN adduser -D thruk


# Build it
WORKDIR /home/thruk
USER thruk

# Thruk sources
RUN git clone git://github.com/sni/thruk_libs.git
RUN git clone git://github.com/sni/Thruk.git

RUN cd thruk_libs && make

ENV PERL5LIB=lib:/home/thruk/Thruk/perl5:/home/thruk/Thruk/perl5/x86_64-linux-thread-multi

RUN mv thruk_libs/local-lib/dest/lib/perl5/ ~/Thruk/

RUN cd Thruk && ./configure && perl Makefile.PL && make installdeps && make

USER root
RUN apk del .build-dependencies
USER thruk

ADD start_thruk.sh /bin

CMD /bin/start_thruk.sh
