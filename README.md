Sqitch Docker Packaging
=======================

    docker pull sqitch/sqitch
    curl -L https://git.io/fAX6Z -o sqitch && chmod +x sqitch
    ./sqitch help

This project is the source for creating the official [Sqitch Project] Docker
Image. It's built on [Alpine Linux] in an effort to keep the image as compact as
possible. It includes support for managing PostgreSQL, SQLite, and MySQL
databases, and may be extended to add support for the other database engines
that Sqitch supports.

Caveats
-------

*   Built on [Alpine Linux], which currently provides a [Maria DB package],
    but not MySQL, [because reasons].
*   The driver for [Firebird] is included, but not the Firebird driver
    library or the `isql` client. They might be included in the future if
    a package Firebird is ever created for Alpine; otherwise, one can create
    a new Docker image from this one, add Firebird, and go.
*   Oracle support may never be provided, since the required [Instant Client]
    are not publicly available. If you have access to the libraries, you
    can create a new docker image from this one and add the the Basic, API,
    and SQL*Plus libraries, as well as [DBD::Oracle], and it should work.
*   The [unixODBC] library is included, so adding support for Snowflake, Exasol,
    or Vertica shoiuld be as simple as creating a new image from this one and
    adding the necessary native client and the ODBC drivers and configuration.

[Sqitch Project]: https://sqitch.org
[Alpine Linux]: https://alpinelinux.org
[Maria DB package]: https://pkgs.alpinelinux.org/packages?name=mariadb-client&branch=edge
[because reasons]: https://github.com/docker-library/mysql/issues/179
[Firebird]: https://www.firebirdsql.org
[Instant Client]: http://www.oracle.com/technetwork/database/database-technologies/instant-client/overview/index.html
[DBD::Oracle]: https://metacpan.org/pod/DBD::Oracle
[unixODBC]: http://www.unixodbc.org