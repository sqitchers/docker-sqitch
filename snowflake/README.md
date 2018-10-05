Sqitch Snowflake Docker Image
=============================

1.  Download the [SnowSQL installer] for x86_64 Linux to this directory. Its
    name should match this pattern: `snowsql-{VERSION}-linux_x86_64.bash`.

2.  Download the [ODBC driver] 64-bit TGZ for Linux to this directory. Its
    name should match this pattern: `snowflake_linux_x8664_odbc-{VERSION}.tgz`.

3.  Build an image named `sqitch-snowsql` with this command from the root
    directory of this project, replacing `$ACCOUNT` with your organization's
    Snowflake account name:

        env DIR=snowflake ./build --build-arg sf_account=$ACCOUNT

    If the resulting image will be pushed to a private Docker registry,
    set the `$REGISTRY` environment variable:

        env DIR=snowflake REGISTRY=registry.example.com/sqitch ./build --build-arg sf_account=$ACCOUNT

[SnowSQL installer]: https://docs.snowflake.net/manuals/user-guide/snowsql-install-config.html
[ODBC driver]: https://docs.snowflake.net/manuals/user-guide/odbc-download.html