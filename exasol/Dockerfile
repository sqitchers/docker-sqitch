ARG VERSION
# The Exasol ODBC driver is not available for ARM64.
FROM --platform=${BUILDPLATFORM} debian:trixie-slim AS exa-build

WORKDIR /work

# Download and unpack EXAplus and the ODBC driver.
# COPY *.tar.gz ./
# https://downloads.exasol.com/clients-and-drivers
ARG exa_version=25.2.5
ADD https://x-up.s3.amazonaws.com/7.x/$exa_version/EXAplus-$exa_version.tar.gz \
    https://x-up.s3.amazonaws.com/7.x/$exa_version/Exasol_ODBC-$exa_version-Linux_x86_64.tar.gz \
    ./

RUN tar zxf Exasol_ODBC-$exa_version-Linux_x86_64.tar.gz \
    && mv Exasol_ODBC-$exa_version-Linux_x86_64/lib odbc \
    && tar zxf EXAplus-$exa_version.tar.gz \
    && mv EXAplus-$exa_version/ exaplus \
    && rm -rf exaplus/doc

FROM --platform=${BUILDPLATFORM} sqitch/sqitch:${VERSION:-latest}

# Install runtime dependencies, remove unnecessary files, and create symlink.
USER root
RUN apt-get -qq update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get -qq --no-install-recommends install unixodbc openjdk-17-jre-headless \
    && apt-get clean \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    && rm -rf /man /usr/share/man /usr/share/doc \
    && mkdir -p /opt/exasol/ \
    && ln -s /opt/exaplus/exaplus /bin

# Install EXAplus and the ODDC driver & config.
COPY --from=exa-build /work/exaplus /opt/exaplus/
COPY --from=exa-build /work/odbc /opt/exasol/odbc/lib
COPY odbcinst.ini /etc/

USER sqitch
