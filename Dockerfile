FROM debian:stable-slim AS sqitch-build
MAINTAINER David E. Wheeler <david@justatheory.com>
ENV BUILDROOT /work
ENV VERSION=0.9998

WORKDIR /$BUILDROOT
WORKDIR $BUILDROOT
COPY App-Sqitch-$VERSION.tar.gz .

# Install system dependencies.
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7 \
    && apt-get -qq update \
    && apt-get -qq install build-essential perl curl \
       unixodbc-dev firebird-dev sqlite libpq-dev libmariadbclient-dev \
    && mkdir src \
    && tar -zxf App-Sqitch-$VERSION.tar.gz --strip-components 1 -C src

# Install cpan and build dependencies.
ENV PERL5LIB $BUILDROOT/local/lib/perl5
RUN curl -sL --compressed https://git.io/cpm > cpm && chmod +x cpm \
    && ./cpm install -L local --verbose --no-test ExtUtils::MakeMaker \
    && ./cpm install -L local --verbose --no-test --with-recommends \
        --with-configure --cpanfile src/dist/cpanfile

# Build, test, bundle.
WORKDIR $BUILDROOT/src
RUN perl Build.PL --quiet --install_base /app --etcdir /etc \
    --config installman1dir= --config installsiteman1dir= --config installman3dir= --config installsiteman3dir= \
    --with sqlite --with postgres --with firebird \
    && ./Build test && ./Build bundle \
    && find /app -name '*.pod' | grep -v sqitch | xargs rm -rf

# Copy to the final image without all the build stuff.
FROM debian:stable-slim AS sqitch

# Install runtime system dependencies.
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man7 \
    && apt-get -qq update \
    && apt-get -qq install sqlite3 libodbc1 \
       firebird3.0-utils libfbclient2 \
       libpq5 postgresql-client \
       mariadb-client-core-10.1 libmariadbclient18 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /usr/bin/mysql?*

# Copy the app and config from the build image.
COPY --from=sqitch-build /app .
COPY --from=sqitch-build /etc /etc/

# Remove unnecessary files.
RUN rm -rf /man /usr/share/man /usr/share/doc /usr/share/postgresql \
    && find / -name '*.pod' | grep -v sqitch | xargs rm -rf

# Set up environment, entrypoint, and default command.
ENV LESS -R
ENV HOME /home
WORKDIR /repo
# ENTRYPOINT ["/bin/sqitch"]
# CMD ["help"]
