FROM debian:bullseye-slim AS exa-build

WORKDIR /work

# Download and unpack EXAplus and the ODBC driver.
# COPY *.tar.gz ./
# https://downloads.exasol.com/clients-and-drivers
ARG version=7.1.20
ADD https://x-up.s3.amazonaws.com/7.x/$version/EXAplus-$version.tar.gz \
    https://x-up.s3.amazonaws.com/7.x/$version/EXASOL_ODBC-$version.tar.gz \
    ./

RUN tar zxf EXASOL_ODBC-$version.tar.gz \
    && ls -l \
    && mv EXASolution_ODBC-$version/lib/linux/x86_64/ odbc \
    && tar zxf EXAplus-$version.tar.gz \
    && mv EXAplus-$version/ exaplus \
    && rm -rf exaplus/doc

FROM sqitch/sqitch:latest

# Install runtime dependencies, remove unnecesary files, and create symlink.
USER root
RUN apt-get -qq update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get -qq --no-install-recommends install unixodbc openjdk-17-jre-headless \
    && apt-get clean \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    && rm -rf /man /usr/share/man /usr/share/doc \
    && mkdir -p /opt/exasol/ \
    && ln -s /opt/exaplus/exaplus /bin

# Install EXAplus and the ODDB driver & config.
COPY --from=exa-build /work/exaplus /opt/exaplus/
COPY --from=exa-build /work/odbc /opt/exasol/odbc/lib
COPY odbcinst.ini /etc/

USER sqitch
