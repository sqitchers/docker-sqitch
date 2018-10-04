#!/bin/bash

# Determine which Docker image to run.
SQITCH_IMAGE=${SQITCH_IMAGE:=sqitch/sqitch:latest}

# Figure out who I am.
user=${USER-$(whoami)}
if [ "Darwin" = $(uname) ]; then
    fullname=$(id -P $user | awk -F '[:]' '{print $8}')
else
    fullname=$(getent passwd $user | cut -d: -f5 | cut -d, -f1)
fi

# Set up required pass-through variables.
passenv=(
    -e "SQITCH_ORIG_SYSUSER=$user"
    -e "SQITCH_ORIG_FULLNAME=$fullname"
    -e "SQITCH_ORIG_EMAIL=$user@$(hostname)"
    -e "TZ=$(date +%Z)" \
    -e "LESS=${LESS:--R}" \
)

# Iterate over optional Sqitch and engine variables.
for var in \
    SQITCH_CONFIG SQITCH_USER SQITCH_USERNAME SQITCH_PASSWORD SQITCH_FULLNAME SQITCH_EMAIL SQITCH_EDITOR \
    DBI_TRACE \
    PGUSER PGPASSWORD PGHOST PGHOSTADDR PGPORT PGDATABASE PGPASSFILE PGSERVICE PGSERVICEFILE PGOPTIONS PGSSLMODE PGREQUIRESSL PGSSLCOMPRESSION PGSSLCERT PGSSLKEY PGSSLROOTCERT PGSSLCRL PGREQUIREPEER PGKRBSRVNAME PGKRBSRVNAME PGGSSLIB PGCONNECT_TIMEOUT PGCLIENTENCODING  PGTARGETSESSIONATTRS \
    MYSQL_PWD MYSQL_HOST MYSQL_TCP_PORT MYSQL_HOME \
    TNS_ADMIN TWO_TASK ORACLE_SID \
    ISC_USER ISC_PASSWORD \
    VSQL_HOME VSQL_HOST VSQL_PORT VSQL_USER VSQL_PASSWORD VSQL_SSLMODE \
    SNOWSQL_ACCOUNT SNOWSQL_USER SNOWSQL_PWD SNOWSQL_HOST SNOWSQL_PORT SNOWSQL_DATABASE SNOWSQL_REGION NOWSQL_WAREHOUSE
do
    if [ ! -z "${!var}" ]; then
       passenv+=("-e" "$var=${!var}")
    fi
done

# Run the container with the current and home directories mounted.
docker run -it --rm --network host \
    --mount "type=bind,src=$(pwd),dst=/repo" \
    --mount "type=bind,src=$HOME,dst=/home" \
    "${passenv[@]}" "$SQITCH_IMAGE" "$@"
