# Alas, the ClickHouse ODBC drivers are not yet available for ARM.
# https://github.com/ClickHouse/clickhouse-odbc/issues/524
FROM --platform=${BUILDPLATFORM} debian:bookworm-slim AS ch-build

WORKDIR /work

# Download and install clickhouse and the ODBC driver.
# https://clickhouse.com/docs/install
# https://github.com/ClickHouse/clickhouse-odbc/releases
ARG ODBC_VERSION=1.4.3
ARG ODBC_DATE=20250807
ARG TSV_URL=https://raw.githubusercontent.com/ClickHouse/ClickHouse/master/utils/list-versions/version_date.tsv
ARG TARGETARCH

RUN apt-get -qq update \
    && env DEBIAN_FRONTEND=noninteractive apt-get install -qq curl unzip \
    && LATEST_VERSION=$(curl -s "${TSV_URL}" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort -V -r | head -n 1) \
    && curl -sSL "https://packages.clickhouse.com/tgz/stable/clickhouse-common-static-$LATEST_VERSION-${TARGETARCH}.tgz" | tar zxf - --strip-components 1 \
    && curl -sSLo odbc.zip "https://github.com/ClickHouse/clickhouse-odbc/releases/download/${ODBC_VERSION}.${ODBC_DATE}/clickhouse-odbc-linux-Clang-UnixODBC-Release.zip" \
    && mkdir odbc \
    && unzip -p odbc.zip "clickhouse-odbc-${ODBC_VERSION}-Linux.tar.gz" | tar -xzf - --strip-components 1 -C odbc

RUN ls -lah
FROM --platform=${BUILDPLATFORM} sqitch/sqitch:latest

# Install runtime dependencies and remove unnecessary files.
USER root
RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install unixodbc \
    && apt-get clean \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    && rm -rf /man /usr/share/man /usr/share/doc

# # Install clickhouse and its ODBC driver from ch-build
COPY --from=ch-build /work/usr/bin/clickhouse /usr/bin/
COPY --from=ch-build /work/odbc /opt/clickhouse
COPY odbcinst.ini /etc/

USER sqitch
