FROM sqitch:latest
MAINTAINER David E. Wheeler <david@justatheory.com>

# Install prereqs.
RUN apt-get -qq update \
    && apt-get -qq --no-install-recommends install unixodbc \
    && apt-get clean \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

WORKDIR /work
COPY *.tgz *.bash conf ./

# Configure ODBC. https://docs.snowflake.net/manuals/user-guide/odbc-linux.html
ARG sf_account
RUN gunzip *.tgz && tar xf *.tar  \
    && mv simba.snowflake.ini snowflake_odbc/lib/ \
    && mkdir -p /usr/lib/snowflake/odbc/log \
    && mv snowflake_odbc/lib /usr/lib/snowflake/odbc/ \
    && mv snowflake_odbc/ErrorMessages /usr/lib/snowflake/odbc \
    && perl -i -pe "s/SF_ACCOUNT/$sf_account/g" odbc.ini \
    && cat odbc.ini >> /etc/odbc.ini \
    && cat odbcinst.ini >> /etc/odbcinst.ini \
    # Unpack and upgrade snowsql.
    && sed -e '1,/^exit$/d' snowsql-*-linux_x86_64.bash | (cd /bin && tar zxf -) \
    && snowsql -Uv \
    # Clean up.
    && cd / && rm -rf /work

# Move to repo directory and clean up.
WORKDIR /repo
