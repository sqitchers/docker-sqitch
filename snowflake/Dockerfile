FROM debian:bookworm-slim AS snow-build

WORKDIR /work

# Download the ODBC driver and SnowSQL.
# https://docs.snowflake.com/en/user-guide/snowsql-install-config
# https://docs.snowflake.com/en/release-notes/client-change-log-snowsql
# https://sfc-repo.snowflakecomputing.com/index.html
ENV ODBC_VERSION=3.1.0
# No ARM-specific SnowSQL yet.
# https://community.snowflake.com/s/question/0D5Do00000ltxpVKAQ/snowsql-linuxarm64-support
ADD https://sfc-repo.snowflakecomputing.com/snowsql/bootstrap/1.2/linux_x86_64/snowsql-1.2.28-linux_x86_64.bash snowsql.bash
COPY conf ./

# Tell SnowSQL where to store its versions and config. Need to keep it inside
# the image so it doesn't try to load the version from $HOME, which will
# typically be mounted to point to the originating host.
ENV WORKSPACE /var/snowsql

# Set locale for Python triggers.
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

# Install prereqs.
ARG sf_account
RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install odbcinst curl ca-certificates \
    # Configure ODBC. https://docs.snowflake.net/manuals/user-guide/odbc-linux.html
    && case "$(arch)" in aarch64) export SNOWPLAT=aarch64 DIRARCH=aarch64 ;; x86_64) export SNOWPLAT=x8664 ;; esac \
    && curl https://sfc-repo.snowflakecomputing.com/odbc/linux${DIRARCH}/${ODBC_VERSION}/snowflake_linux_${SNOWPLAT}_odbc-${ODBC_VERSION}.tgz -o snowflake_odbc.tgz \
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
    && sed -e '1,/^exit$/d' snowsql.bash | tar zxf - \
    && ./snowsql -Uv \
    && echo "[connections]\naccountname = $sf_account\n\n[options]\nnoup = true" > /var/snowsql/.snowsql/config

FROM sqitch/sqitch:latest

# Install runtime dependencies, remove unnecesary files, and create log dir.
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
ENV SNOWSQL_DOWNLOAD_DIR /var/.snowsql
