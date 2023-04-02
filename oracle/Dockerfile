FROM debian:stable-slim AS ora-build

WORKDIR /work
# https://www.oracle.com/database/technologies/instant-client/linux-x86-64-downloads.html
ARG INSTANTCLIENT_VERSION=21.9.0.0.0dbru
ARG INSTANTCLIENT_VDIR=219000

ADD https://download.oracle.com/otn_software/linux/instantclient/${INSTANTCLIENT_VDIR}/instantclient-basic-linux.x64-${INSTANTCLIENT_VERSION}.zip ./
ADD https://download.oracle.com/otn_software/linux/instantclient/${INSTANTCLIENT_VDIR}/instantclient-sqlplus-linux.x64-${INSTANTCLIENT_VERSION}.zip ./
ADD https://download.oracle.com/otn_software/linux/instantclient/${INSTANTCLIENT_VDIR}/instantclient-sdk-linux.x64-${INSTANTCLIENT_VERSION}.zip ./

ENV ORACLE_HOME /work/instantclient
ENV LD_LIBRARY_PATH /work/instantclient
ENV PERL5LIB /work/tmp/lib/perl5

RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7 \
    # Install dependen cies
    && apt-get -qq update \
    && apt-get -qq install build-essential libarchive-tools curl libaio-dev \
    && mkdir instantclient \
    && bsdtar -C instantclient --strip-components 1 -zxf instantclient-basic-linux.x64-${INSTANTCLIENT_VERSION}.zip \
    && bsdtar -C instantclient --strip-components 1 -zxf instantclient-sqlplus-linux.x64-${INSTANTCLIENT_VERSION}.zip \
    # Copy basic and SQL*Plus for installation below.
    && cp -rf instantclient instantclient.install \
    && bsdtar -C instantclient --strip-components 1 -zxf instantclient-sdk-linux.x64-${INSTANTCLIENT_VERSION}.zip \
    # Install DBI in its own directory, then install DBD::Oracle.
    && curl https://cpanmin.us > cpanm && chmod +x cpanm \
    && ./cpanm install -l tmp --quiet --notest DBI \
    && ./cpanm install -l local --quiet --notest --no-man-pages DBD::Oracle \
    # Remove unneeded files.
    && find local -name '*.pod' -delete \
    && find local -name '*.h' -delete \
    && find local -name .meta -exec rm -rf {} + \
    && find local -name .packlist -exec rm -rf {} + \
    && find local -type d -empty -delete \
    && rm -rf instantclient.install/*.jar instantclient.install/*README instantclient.install/nework

FROM sqitch/sqitch:latest

# Install instantclient basic and SQL*Plus and copy DBD::Oracle.
USER root
COPY --from=ora-build /work/instantclient.install /instantclient/
COPY --from=ora-build /work/local/lib/perl5 /lib/perl5/

# Install runtime system dependencies and remove unnecesary files.
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7 \
    && apt-get -qq update \
    && apt-get install -qq --no-install-recommends libaio1 \
    && apt-get clean \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /usr/bin/mysql?* \
    && rm -rf /plibs /man /usr/share/man /usr/share/doc

# Set up user and environment.
USER sqitch
ENV ORACLE_HOME=/instantclient LD_LIBRARY_PATH=/instantclient
