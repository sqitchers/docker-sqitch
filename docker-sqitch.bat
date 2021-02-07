@echo off & setlocal enableextensions enabledelayedexpansion
REM # Determine which Docker image to run.
IF NOT DEFINED SQITCH_IMAGE (
    set SQITCH_IMAGE=sqitch/sqitch:latest
)
REM set SQITCH_IMAGE=sqitch/sqitch:latest

REM # Set up required pass-through variables.
FOR /F "tokens=*" %%g IN ('whoami') do (SET user=%%g)
set passopt= -e SQITCH_ORIG_SYSUSER="%username%"
FOR /F "tokens=*" %%g IN ('hostname') do (SET machinehostname=%%g)
set passopt=%passopt% -e SQITCH_ORIG_EMAIL="%username%@%machinehostname%"
FOR /F "tokens=*" %%g IN ('tzutil /g') do (SET TZ=%%g)
set passopt=%passopt% -e TZ="%TZ%"
if NOT DEFINED LESS (
    set LESS=-R
)
set passopt=%passopt% -e LESS=%LESS%

for %%i in (
    SQITCH_CONFIG SQITCH_USERNAME SQITCH_PASSWORD SQITCH_FULLNAME SQITCH_EMAIL SQITCH_TARGET
    DBI_TRACE
    PGUSER PGPASSWORD PGHOST PGHOSTADDR PGPORT PGDATABASE PGSERVICE PGOPTIONS PGSSLMODE PGREQUIRESSL PGSSLCOMPRESSION PGREQUIREPEER PGKRBSRVNAME PGKRBSRVNAME PGGSSLIB PGCONNECT_TIMEOUT PGCLIENTENCODING PGTARGETSESSIONATTRS
    MYSQL_PWD MYSQL_HOST MYSQL_TCP_PORT
    TNS_ADMIN TWO_TASK ORACLE_SID
    ISC_USER ISC_PASSWORD
    VSQL_HOST VSQL_PORT VSQL_USER VSQL_PASSWORD VSQL_SSLMODE
    SNOWSQL_ACCOUNT SNOWSQL_USER SNOWSQL_PWD SNOWSQL_HOST SNOWSQL_PORT SNOWSQL_DATABASE SNOWSQL_REGION SNOWSQL_WAREHOUSE SNOWSQL_PRIVATE_KEY_PASSPHRASE
) do if defined %%i (
    echo %%i is defined as !%%i!
    SET passopt=!passopt! -e !%%i!
)

REM # Determine the name of the container home directory.
set homedst=/home
REM if [ $(id -u ${user}) -eq 0 ]; then
REM     homedst=/root
REM fi
REM # Set HOME, since the user ID likely won't be the same as for the sqitch user.
set passopt=%passopt% -e HOME="%homedst%"

echo %passopt%

REM # Run the container with the current and home directories mounted.
@echo on
docker run -it --rm --network host ^
    --mount "type=bind,src=%cd%,dst=/repo" ^
    --mount "type=bind,src=%UserProfile%,dst=%homedst%" ^
    %passopt% %SQITCH_IMAGE% %*

@endlocal
