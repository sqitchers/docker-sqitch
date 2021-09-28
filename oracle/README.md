Sqitch Oracle Docker Image
==========================

1.  Build an image named `sqitch-oracle` with this command

        docker build -t sqitch-oracle .

    If you want to control the version of [Instant Client], pass the
    `INSTANTCLIENT_VERSION` AND `INSTANTCLIENT_VDIR` (the version with dots
    removed) arguments:

        docker build -t sqitch-oracle \
               --build-arg INSTANTCLIENT_VERSION=21.3.0.0.0 \
               --build-arg INSTANTCLIENT_VDIR=213000 \
               .

2.  Set up a [`tnsnames.ora` file] in your home directory. For example,
    `~./sqlplus/tnsnames.ora`.

3.  Set the `$TNS_ADMIN` environment variable to the directory of the `tnsnames.ora`
    file, replacing the path to your home directory with `/home`. For example, if
    the file is `~./sqlplus/tnsnames.ora`, run Sqitch like so:

        SQITCH_IMAGE=sqitch-oracle TNS_ADMIN=/home/.sqlplus ../docker-sqitch.sh status

    The `docker-sqitch.sh` wrapper mounts your home directory on the host
    machine to `/home` in the container, letting it find `tnsnames.ora` and
    Sqitch configuration files.

  [Instant Client] https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html
  [`tnsnames.ora` file]: https://orafaq.com/wiki/Tnsnames.ora
