Sqitch Docker Packaging
=======================

    docker pull sqitch/sqitch
    curl -L https://git.io/fAX6Z -o sqitch && chmod +x sqitch
    ./sqitch help

This project is the source for creating the official [Sqitch Project] Docker
Image. It's built on [stable Debian slim] in an effort to keep the image as
small as possible while supporting all known engines. It includes support for
managing [PostgreSQL], [SQLite], [MariaDB] ([MySQL]), and [Firebird] databases,
and other images may be built to support for the other database engines that
Sqitch supports.

Notes
-----

*   The [`docker-sqitch.sh`] shell script is the easiest way to run Sqitch from
    a Docker image. The script mounts the current directory and the home
    directory, so that it acts on the Sqitch project in the current directory
    and reads configuration from the home directory almost as if it was running
    natively on the local host. It also copies over most of the environment
    variables that Sqitch cares about, for transparent configuration.
*   By default, the container runs as the `sqitch` user. On macOS and Windows
    this works well, as files created by Sqitch in the working directory on the
    host will be properly owned by the host user. On Linux, however,
    [`docker-sqitch.sh`] runs the container with the UID and GID of the current
    host user, again so that files created by Sqitch will be owned by that user.
    If you find that the container cannot access configuration files in your
    home directory or write change scripts to the local directory, run
    `sudo docker-sqitch.sh` to run as the root user. Just be sure to `chown`
    files that Sqitch created for the consistency of your project.
*   If your engine falls back on the system username when connecting to the
    database (as the PostgreSQL engine does), you will likely want to set the
    username in sqitch target URIs, or set the proper [environment variables] to
    fall back on. Database authentication failures for the usernames `sqitch` or
    `root` are the hint you'll want to look for.
*   If you need to connect to a database server on your local host (or running
    in a container with the listening port mapped to the local host), use the
    host name `host.docker.internal` instead of `localhost`. Connections should
    work transparently when running Docker on Windows or macOS, although not yet
    on Linux (watch [this PR](https://github.com/docker/libnetwork/pull/2348)
    for it to land). In the meantime you can [use a NAT gateway
    container](https://github.com/qoomon/docker-host) to forward traffic to the
    Docker host.
*   Custom images for [Oracle], [Snowflake], [Exasol], or [Vertica] can be built
    by downloading the appropriate binary files and using the `Dockerfile`s in
    the appropriately-named subdirectories of this repository.
*   In an effort to keep things as simple as possible, the only editor included
    and configured for use in the image is [nano]. This is a very simple, tiny
    text editor suitable for editing change descriptions and the like. Its
    interface always provides menus to make it easy to figure out how to use it.
    If you need another editor, this image isn't for you, but you can create
    one based on this image and add whatever editors you like.

  [Sqitch Project]: https://sqitch.org
  [stable Debian slim]: https://docs.docker.com/samples/library/debian/#debiansuite-slim
  [PostgreSQL]: https://postgresql.org
  [SQLite]: https://sqlite.org/
  [MariaDB]: https://mariadb.com/
  [MySQL]: https://mysql.com/
  [Firebird]: https://www.firebirdsql.org
  [`docker-sqitch.sh`]: https://git.io/fAX6Z
  [environment variables]: http://metacpan.org/pod/sqitch-environment
  [Oracle]: https://www.oracle.com/database/
  [Snowflake]:https://www.snowflake.com
  [Exasol]:https://www.exasol.com/
  [Vertica]: https://www.vertica.com
  [nano]: https://www.nano-editor.org/
