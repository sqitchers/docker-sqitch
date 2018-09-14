FROM alpine:latest AS sqitch-build
MAINTAINER David E. Wheeler <david@justatheory.com>
ENV BUILDROOT /work
ENV VERSION=0.9998

# MySQL not supported on Alpine yet, so relying on Maria:
# https://github.com/docker-library/mysql/issues/179
# Alas, that means that MySQL 8 may not be supported.

WORKDIR /$BUILDROOT
WORKDIR $BUILDROOT
RUN apk add --update build-base curl perl perl-dev tzdata \
        libressl libressl-dev zlib-dev tar \
        sqlite postgresql-dev mariadb-connector-c-dev unixodbc-dev \
    && cp /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone \
    && curl -LO https://cpan.metacpan.org/authors/id/D/DW/DWHEELER/App-Sqitch-$VERSION.tar.gz \
    && mkdir src \
    && tar -zxf App-Sqitch-$VERSION.tar.gz --strip-components 1 -C src

# Download and move Firebird files in place.
RUN curl -LO https://github.com/FirebirdSQL/firebird/releases/download/R3_0_3/Firebird-3.0.3.32900-0.amd64.tar.gz \
    && tar zxf Firebird-3.0.3.32900-0.amd64.tar.gz \
    && cd Firebird-3.0.3.32900-0.amd64 \
    && tar zxf buildroot.tar.gz \
    && mkdir -p /usr/include && mv usr/include/* /usr/include \
    && mkdir -p /opt && mv opt/firebird /opt/

# Install cpan and build dependencies.
ENV PERL5LIB $BUILDROOT/local/lib/perl5
RUN curl -sL --compressed https://git.io/cpm > cpm && chmod +x cpm \
    && ./cpm install -L local --verbose --no-test --with-recommends \
        --with-configure --cpanfile src/dist/cpanfile

# Build, test, bundle.
WORKDIR $BUILDROOT/src
RUN perl Build.PL --quiet --install_base /app --etcdir /etc \
    --with sqlite --with postgres --with firebird \
    && ./Build test && ./Build bundle

# Copy to the final image without all the build stuff.
FROM alpine:latest
RUN apk add --udpate perl tzdata less sqlite postgresql-client mysql-client unixodbc

# XXX Workaround to avoid https://github.com/perl5-dbi/DBD-mysql/issues/262.
RUN apk add perl-dbd-mysql

# Set the time zone, clear the cache, and install the bundle.
RUN cp /usr/share/zoneinfo/UTC /etc/localtime && echo UTC > /etc/timezone
RUN rm -rf /var/cache/*
COPY --from=sqitch-build /app .
COPY --from=sqitch-build /etc /etc/

# Set up environment, entrypoint, and default command.
ENV LESS -R
ENV HOME /home
WORKDIR /repo
ENTRYPOINT ["/bin/sqitch"]
CMD ["help"]
