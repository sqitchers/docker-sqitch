FROM debian:stable-slim AS exa-build

WORKDIR /work

# Download and unpack EXAplus and the ODBC driver.
# COPY *.tar.gz ./
ARG version=6.0.13
ADD https://www.exasol.com/support/secure/attachment/70546/EXAplus-$version.tar.gz \
    https://www.exasol.com/support/secure/attachment/70564/EXASOL_ODBC-$version.tar.gz \
    ./

ARG version=6.0.13
RUN tar zxf EXASOL_ODBC-$version.tar.gz \
    && mv EXASOL_ODBC-$version/lib/linux/x86_64/ odbc \
    && tar zxf EXAplus-$version.tar.gz \
    && mv EXAplus-$version/ exaplus \
    && rm -rf exaplus/doc

FROM sqitch/sqitch:latest

# Install runtime dependencies, remove unnecesary files, and create symlink.
USER root
RUN apt-get -qq update \
    && mkdir -p /usr/share/man/man1 \
    && apt-get -qq --no-install-recommends install unixodbc openjdk-8-jre-headless \
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
