FROM debian:stable-slim AS snow-build

WORKDIR /work
COPY *.tgz *.bash conf ./

# Tell SnowSQL where to store its versions and config. Need to keep it inside
# the image so it doesn't try to load the version from $HOME, which will
# typically be mounted to point to the originating host.
ENV WORKSPACE /var/snowsql

# Set locale for Python triggers.
ENV LC_ALL=C.UTF-8 LANG=C.UTF-8

# Install prereqs.
ARG sf_account
RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install odbcinst \
    # Configure ODBC. https://docs.snowflake.net/manuals/user-guide/odbc-linux.html
    && gunzip *.tgz && tar xf *.tar  \
    && mkdir odbc \
    && mv snowflake_odbc/lib snowflake_odbc/ErrorMessages odbc/ \
    && mv simba.snowflake.ini odbc/lib/ \
    && perl -i -pe "s/SF_ACCOUNT/$sf_account/g" odbc.ini \
    && cat odbc.ini >> /etc/odbc.ini \
    && cat odbcinst.ini >> /etc/odbcinst.ini \
    # Unpack and upgrade snowsql, then overwrite its config file.
    && sed -e '1,/^exit$/d' snowsql-*-linux_x86_64.bash | tar zxf - \
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
    # XXX Workaround for Snowflake missing table error code fixed in v1.0.0.
    && perl -i -pe 's/02000/42S02/' /lib/perl5/App/Sqitch/Engine/snowflake.pm \
    && mkdir -p /usr/lib/snowflake/odbc/log \
    && printf '#!/bin/sh\n/var/snowsql --config /home/.snowsql/config "$@"\n' > /bin/snowsql \
    && chmod +x /bin/snowsql

# Install SnowSQL plus the ODDB driver and config.
COPY --from=snow-build /work/snowsql /var/
COPY --from=snow-build --chown=sqitch:sqitch /var/snowsql /var/
COPY --from=snow-build /work/odbc /usr/lib/snowflake/odbc/
COPY --from=snow-build /etc/odbc* /etc/

# The .snowsql directory is copied to /var.
USER sqitch
ENV WORKSPACE /var
