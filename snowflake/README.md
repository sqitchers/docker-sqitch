Sqitch Snowflake Docker Image
=============================

Build an image with the tags `sqitch/sqitch:snowflake` and
`sqitch/sqitch:$VERSION-snowflake` (where `$VERSION` is the current version of
Sqitch) with this command from the root directory of this project, replacing
`$ACCOUNT` with your organization's Snowflake account name:

    env DIR=snowflake ./build --build-arg sf_account=$ACCOUNT

The build will download the [SnowSQL installer] and [ODBC driver] from public
repositories; if there are errors, check that the version number are correct
in the [client changes].

If the resulting image will be pushed to a private Docker registry, set the
`$REGISTRY` environment variable:

``` sh
env DIR=snowflake REGISTRY=registry.example.com/sqitch ./build --build-arg sf_account=$ACCOUNT
```

This example would result in the tags `registry.example.com/sqitch:snowflake` and
`registry.example.com/sqitch/sqitch:$VERSION-snowflake`.

To use this image with the [`docker-sqitch.sh`] shell script, set the
`$SQITCH_IMAGE` environment variable to the container tag it should use, e.g.,

``` sh
curl -L https://git.io/fAX6Z -o sqitch && chmod +x sqitch
env SQITCH_IMAGE=sqitch/sqitch:snowflake ./sqitch
```

Or from a private repository:

``` sh
env SQITCH_IMAGE=registry.example.com/sqitch:snowflake ./sqitch
```

  [SnowSQL installer]: https://docs.snowflake.net/manuals/user-guide/snowsql-install-config.html
  [ODBC driver]: https://docs.snowflake.net/manuals/user-guide/odbc-download.html
  [client changes]: https://docs.snowflake.net/manuals/release-notes/client-change-log.html
  [`docker-sqitch.sh`]: https://git.io/fAX6Z
