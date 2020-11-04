@echo off & setlocal EnableDelayedExpansion
setlocal
@REM # Determine which Docker image to run.
if "%SQITCH_IMAGE%"=="" (
    set SQITCH_IMAGE=sqitch/sqitch:latest
) 
echo %SQITCH_IMAGE%
@REM set SQITCH_IMAGE=sqitch/sqitch:latest

@REM # Set up required pass-through variables.
@REM set user=whoami
REM FOR /F "tokens=*" %%g IN ('whoami') do (SET user=%%g)
REM echo %user%
set passopt= -e "SQITCH_ORIG_SYSUSER=%username%"
FOR /F "tokens=*" %%g IN ('hostname') do (SET machinehostname=%%g)
set passopt=%passopt% -e "SQITCH_ORIG_EMAIL=%username%@%machinehostname%"
FOR /F "tokens=*" %%g IN ('tzutil /g') do (SET TZ=%%g)
set passopt=%passopt% -e "TZ=%TZ%"

echo %passopt% 
@REM passopt=(
@REM     -e "SQITCH_ORIG_SYSUSER=$user"
@REM     -e "SQITCH_ORIG_EMAIL=$user@$(hostname)"
@REM     -e "TZ=$(date +%Z)" \
@REM     -e "LESS=${LESS:--R}" \
@REM )

@REM # Handle OS-specific options.
@REM case "$(uname -s)" in
@REM     Linux*)
@REM         passopt+=(-e "SQITCH_ORIG_FULLNAME=$(getent passwd $user | cut -d: -f5 | cut -d, -f1)")
@REM         passopt+=(-u $(id -u ${user}):$(id -g ${user}))
@REM         ;;
@REM     Darwin*)
@REM         passopt+=(-e "SQITCH_ORIG_FULLNAME=$(/usr/bin/id -P $user | awk -F '[:]' '{print $8}')")
@REM         ;;
@REM     MINGW*|CYGWIN*)
@REM         passopt+=(-e "SQITCH_ORIG_FULLNAME=$(net user $user)")
@REM         ;;
@REM     *)
@REM         echo "Unknown OS: $(uname -s)"
@REM         exit 2
@REM         ;;
@REM esac

@REM # Iterate over optional Sqitch and engine variables.
@REM for var in \
@REM     SQITCH_CONFIG SQITCH_USERNAME SQITCH_PASSWORD SQITCH_FULLNAME SQITCH_EMAIL SQITCH_TARGET \
@REM     DBI_TRACE \
@REM     PGUSER PGPASSWORD PGHOST PGHOSTADDR PGPORT PGDATABASE PGSERVICE PGOPTIONS PGSSLMODE PGREQUIRESSL PGSSLCOMPRESSION PGREQUIREPEER PGKRBSRVNAME PGKRBSRVNAME PGGSSLIB PGCONNECT_TIMEOUT PGCLIENTENCODING PGTARGETSESSIONATTRS \
@REM     MYSQL_PWD MYSQL_HOST MYSQL_TCP_PORT \
@REM     TNS_ADMIN TWO_TASK ORACLE_SID \
@REM     ISC_USER ISC_PASSWORD \
@REM     VSQL_HOST VSQL_PORT VSQL_USER VSQL_PASSWORD VSQL_SSLMODE \
@REM     SNOWSQL_ACCOUNT SNOWSQL_USER SNOWSQL_PWD SNOWSQL_HOST SNOWSQL_PORT SNOWSQL_DATABASE SNOWSQL_REGION SNOWSQL_WAREHOUSE SNOWSQL_PRIVATE_KEY_PASSPHRASE
@REM do
@REM     if [ -n "${!var}" ]; then
@REM        passopt+=(-e $var)
@REM     fi
@REM done

@REM # Determine the name of the container home directory.
@REM homedst=/home
@REM if [ $(id -u ${user}) -eq 0 ]; then
@REM     homedst=/root
@REM fi
@REM # Set HOME, since the user ID likely won't be the same as for the sqitch user.
@REM passopt+=(-e "HOME=${homedst}")

@REM # Run the container with the current and home directories mounted.
@REM docker run -it --rm --network host \
@REM     --mount "type=bind,src=$(pwd),dst=/repo" \
@REM     --mount "type=bind,src=$HOME,dst=$homedst" \
@REM     "${passopt[@]}" "$SQITCH_IMAGE" "$@"

echo end
endlocal