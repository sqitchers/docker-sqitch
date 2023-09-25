.DEFAULT_GOAL := sqitch
.PHONY: oracle snowflake vertica exasol firebird postgres mysql sqlite

sqitch: Dockerfile .envrc
	./build

# Oracle only on amd64 till an issue building DBD::Oracle is sorted.
# https://rt.cpan.org/Ticket/Display.html?id=149876
oracle: oracle/Dockerfile
	env DIR=oracle REGISTRY=sqitch ARCHS=amd64 ./build

# Snowflake only on amd64 till SnowSQL ARM support released.
# https://community.snowflake.com/s/question/0D5Do00000ltxpVKAQ/snowsql-linuxarm64-support
snowflake: snowflake/Dockerfile
	env DIR=snowflake REGISTRY=sqitch ARCHS=amd64 ./build --build-arg sf_account=example

# Exasol currently offers no ARM support.
exasol: exasol/Dockerfile
	env DIR=exasol REGISTRY=sqitch ARCHS=amd64 ./build
