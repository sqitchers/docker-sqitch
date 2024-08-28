Sqitch Oracle Docker Image
==========================

1.  Build an x86 image named `sqitch-oracle` with the latest version of
    [Instant Client] by running this command from the root directory:

    ``` sh
    env env DIR=oracle ARCHS=amd64 ./build
    ```

    > Support for arm64 is included, but DBD::Oracle fails to build with this
    > error:
    >
    >     39.41 /usr/bin/ld: cannot find -lclntshcore: No such file or directory
    >
    > The file seems to be missing from the arm64 Instant Client download.
    > Once it's fixed, remove `ARCHS=amd64` from the above command to build
    > both x86 and arm64 images.

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
