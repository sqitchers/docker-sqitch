Sqitch Snowflake Docker Image
=============================

Build an image named `sqitch-snowsql` with this command from the root directory
of this project, replacing `$ACCOUNT` with your organization's Snowflake account
name:

    env DIR=snowflake ./build --build-arg sf_account=$ACCOUNT

The build will download the [SnowSQL installer] and [ODBC driver] from public
repositories; if there are errors, check that the version number are correct
in the [client changes].

If the resulting image will be pushed to a private Docker registry, set the
`$REGISTRY` environment variable:

    env DIR=snowflake REGISTRY=registry.example.com/sqitch ./build --build-arg sf_account=$ACCOUNT

  [SnowSQL installer]: https://docs.snowflake.net/manuals/user-guide/snowsql-install-config.html
  [ODBC driver]: https://docs.snowflake.net/manuals/user-guide/odbc-download.html
  [client changes]: https://docs.snowflake.net/manuals/release-notes/client-change-log.html
