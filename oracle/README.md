Sqitch Oracle Docker Image
==========================

1.  Download the basiclite (or basic), SQL*Plus, and SDK [Instant Client] Zip
    files for x64 Linux. The names should match these patterns:

    *   `instantclient-basic*-linux.x64-*.zip`
    *   `instantclient-sqlplus-linux.x64-*.zip`
    *   `instantclient-sdk-linux.x64-*.zip`

2.  Build an image named `sqitch-oracle` with this command

         docker build -t sqitch-oracle .

3.  Set up a [`tnsnames.ora` file] in your home directory. For example,
    `~./sqlplus/tnsnames.ora`.

4.  Set the `$TNS_ADMIN` environment variable to the directory of the `tnsnames.ora`
    file, replacing the path to your home directory with `/home`. For example, if
    the file is `~./sqlplus/tnsnames.ora`, run Sqitch like so:

        SQITCH_IMAGE=sqitch-oracle TNS_ADMIN=/home/.sqlplus ../docker-sqitch.sh status

    The `docker-sqitch.sh` wrapper mounts your home directory on the host
    machine to `/home` in the container, letting it find `tnsnames.ora` and
    Sqitch configuration files.

  [Instant Client] https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html
  [`tnsnames.ora` file]: https://orafaq.com/wiki/Tnsnames.ora
