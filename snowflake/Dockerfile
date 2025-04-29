FROM debian:bookworm-slim AS snow-build

WORKDIR /work

COPY conf ./

# Tell SnowSQL where to store its versions and config. Need to keep it inside
# the image so it doesn't try to load the version from $HOME, which will
# typically be mounted to point to the originating host.
ENV WORKSPACE=/var/snowsql

# Set locale for Python triggers.
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

# CONFIGURE the ODBC driver and SnowSQL versions to download.
# https://docs.snowflake.com/en/user-guide/snowsql-install-config
# https://docs.snowflake.com/en/release-notes/clients-drivers/snowsql
# https://sfc-repo.snowflakecomputing.com/index.html
ARG ODBC_VERSION=3.6.0
ARG SNOWSQL_VERSION=1.3.3

# Install prereqs.
ARG sf_account
RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install odbcinst curl ca-certificates \
    # Set variables for downloading the proper ODBC & SnowSQL files.
    && case "$(arch)" in aarch64) export SNOWPLAT=aarch64 ODBCPLAT=aarch64 DIRARCH=aarch64 ;; x86_64) export ODBCPLAT=x8664 SNOWPLAT=x86_64 ;; esac \
    # Configure ODBC.
    # https://docs.snowflake.net/manuals/user-guide/odbc-linux.html
    && curl https://sfc-repo.snowflakecomputing.com/odbc/linux${DIRARCH}/${ODBC_VERSION}/snowflake_linux_${ODBCPLAT}_odbc-${ODBC_VERSION}.tgz -o snowflake_odbc.tgz \
    && gunzip -f *.tgz && tar vxf *.tar \
    && mkdir odbc \
    && mv snowflake_odbc/lib snowflake_odbc/ErrorMessages odbc/ \
    && perl -i -pe "s/x86_64/$(arch)/g" simba.snowflake.ini \
    && mv simba.snowflake.ini odbc/lib/ \
    && perl -i -pe "s/SF_ACCOUNT/$sf_account/g" odbc.ini \
    && cat odbc.ini >> /etc/odbc.ini \
    && cat odbcinst.ini >> /etc/odbcinst.ini \
    # Unpack and upgrade snowsql, then overwrite its config file.
    # && SNOWSQL_DEST=. SNOWSQL_LOGIN_SHELL=/dev/null bash snowsql.bash \
    && curl https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.3/linux_${SNOWPLAT}/snowsql-1.3.2-linux_${SNOWPLAT}.bash -o snowsql.bash \
    && sed -e '1,/^exit$/d' snowsql.bash | tar zxf - \
    && ./snowsql -Uv \
    && echo "[connections]\naccountname = $sf_account\n\n[options]\nnoup = true" > /var/snowsql/.snowsql/config

FROM sqitch/sqitch:latest

# Install runtime dependencies, remove unnecessary files, and create log dir.
USER root
RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install unixodbc \
    && apt-get clean \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    && rm -rf /man /usr/share/man /usr/share/doc \
    && mkdir -p /usr/lib/snowflake/odbc/log

# Install SnowSQL plus the ODBC driver and config.
COPY --from=snow-build /work/snowsql /bin/
COPY --from=snow-build --chown=sqitch:sqitch /var/snowsql /var/
COPY --from=snow-build /work/odbc /usr/lib/snowflake/odbc/
COPY --from=snow-build /etc/odbc* /etc/
RUN chmod --recursive a+rx /var/.snowsql

# The .snowsql directory is copied to /var.
USER sqitch
ENV SNOWSQL_DOWNLOAD_DIR=/var/.snowsql
