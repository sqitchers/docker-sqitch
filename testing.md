Testing the Image
=================

MySQL
-----

*   Run MySQL in a separate container:

        docker run --name=mysqld -d -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -p 3306:3306 mysql:8.0 --default-authentication-plugin=mysql_native_password

*   Create a database:

        docker run -it --rm mysql mysql -h host.docker.internal --execute 'CREATE DATABASE flipr'

*   Test with the URI `db:mysql://root@host.docker.internal/flipr`.

