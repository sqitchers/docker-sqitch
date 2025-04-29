FROM --platform=linux/amd64 debian:bookworm-slim AS exa-build

WORKDIR /work

# Download and unpack EXAplus and the ODBC driver.
# COPY *.tar.gz ./
# https://downloads.exasol.com/clients-and-drivers
ARG version=25.2.2
ADD https://x-up.s3.amazonaws.com/7.x/$version/EXAplus-$version.tar.gz \
    https://x-up.s3.amazonaws.com/7.x/$version/Exasol_ODBC-$version-Linux_x86_64.tar.gz \
    ./

RUN tar zxf Exasol_ODBC-$version-Linux_x86_64.tar.gz \
    && ls -l \
    && mv Exasol_ODBC-$version-Linux_x86_64/lib odbc \
    && tar zxf EXAplus-$version.tar.gz \
    && mv EXAplus-$version/ exaplus \
    && rm -rf exaplus/doc

FROM --platform=linux/amd64 sqitch/sqitch:latest

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
