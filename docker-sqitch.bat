@echo off & setlocal enableextensions enabledelayedexpansion

REM # Determine which Docker image to run.
IF NOT DEFINED SQITCH_IMAGE (
    set SQITCH_IMAGE=sqitch/sqitch:latest
) 
echo %SQITCH_IMAGE%
REM set SQITCH_IMAGE=sqitch/sqitch:latest

REM # Set up required pass-through variables.
REM set user=whoami
echo ::: step1 ::::
FOR /F "tokens=*" %%g IN ('whoami') do (SET user=%%g)
set passopt= -e "SQITCH_ORIG_SYSUSER=%username%"
FOR /F "tokens=*" %%g IN ('hostname') do (SET machinehostname=%%g)
set passopt=%passopt% -e "SQITCH_ORIG_EMAIL=%username%@%machinehostname%"
FOR /F "tokens=*" %%g IN ('tzutil /g') do (SET TZ=%%g)
set passopt=%passopt% -e "TZ=%TZ%"
if NOT DEFINED LESS (
    set LESS=--R
)
REM if "%LESS%"=="" (

set passopt=%passopt% -e "LESS=%LESS%"

echo %passopt% 

REM IF DEFINED SQITCH_USERNAME (
REM     set passopt=%passopt% -e %SQITCH_USERNAME%
REM )
echo %SQITCH_CONFIG%
set "OPTIONALVARS=%SQITCH_CONFIG% %SQITCH_USERNAME% %SQITCH_PASSWORD% %SQITCH_FULLNAME%"
echo %passopt% 
echo ::: step1a ::::

for %%i in (%OPTIONALVARS%) do (
 echo %%i is defined 2
 SET passopt=!passopt! -e %%i
)
REM ECHO %passopt:~2%
echo ::: step1b ::::
echo %passopt% 
echo ::: step1c ::::

for %%i in (SQITCH_CONFIG SQITCH_USERNAME SQITCH_PASSWORD SQITCH_FULLNAME SQITCH_EMAIL SQITCH_TARGET) do if defined %%i (
    echo %%i is defined %%%i%
    SET passopt=!passopt! -e %%i
)

echo %passopt% 
REM # Iterate over optional Sqitch and engine variables.
REM for var in \
REM     SQITCH_CONFIG SQITCH_USERNAME SQITCH_PASSWORD SQITCH_FULLNAME SQITCH_EMAIL SQITCH_TARGET \
REM     DBI_TRACE \
REM     PGUSER PGPASSWORD PGHOST PGHOSTADDR PGPORT PGDATABASE PGSERVICE PGOPTIONS PGSSLMODE PGREQUIRESSL PGSSLCOMPRESSION PGREQUIREPEER PGKRBSRVNAME PGKRBSRVNAME PGGSSLIB PGCONNECT_TIMEOUT PGCLIENTENCODING PGTARGETSESSIONATTRS \
REM     MYSQL_PWD MYSQL_HOST MYSQL_TCP_PORT \
REM     TNS_ADMIN TWO_TASK ORACLE_SID \
REM     ISC_USER ISC_PASSWORD \
REM     VSQL_HOST VSQL_PORT VSQL_USER VSQL_PASSWORD VSQL_SSLMODE \
REM     SNOWSQL_ACCOUNT SNOWSQL_USER SNOWSQL_PWD SNOWSQL_HOST SNOWSQL_PORT SNOWSQL_DATABASE SNOWSQL_REGION SNOWSQL_WAREHOUSE SNOWSQL_PRIVATE_KEY_PASSPHRASE
REM do
REM     if [ -n "${!var}" ]; then
REM        passopt+=(-e $var)
REM     fi
REM done

REM # Determine the name of the container home directory.
set homedst=/home
REM if [ $(id -u ${user}) -eq 0 ]; then
REM     homedst=/root
REM fi
REM # Set HOME, since the user ID likely won't be the same as for the sqitch user.
set passopt=%passopt% -e "HOME=%homedst%"

echo %passopt% 

REM # Run the container with the current and home directories mounted.
REM docker run -it --rm --network host \
REM     --mount "type=bind,src=$(pwd),dst=/repo" \
REM     --mount "type=bind,src=%HOME%,dst=%homedst%" \
REM     "%passopt%" "%SQITCH_IMAGE%"

echo end
endlocal