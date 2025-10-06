.DEFAULT_GOAL := sqitch
.PHONY: oracle snowflake vertica exasol firebird postgres mysql sqlite

sqitch: Dockerfile .envrc
	./build

# Oracle only on amd64 till an issue building DBD::Oracle is sorted.
# https://github.com/perl5-dbi/DBD-Oracle/issues/197
oracle: oracle/Dockerfile
	env DIR=oracle REGISTRY=sqitch ARCHS=amd64 ./build

# Snowflake only on amd64 till SnowSQL ARM support released.
# https://snowflake.discourse.group/t/snowsql-linux-arm64-support/5295/3
snowflake: snowflake/Dockerfile
	env DIR=snowflake REGISTRY=sqitch ARCHS=amd64 ./build --build-arg sf_account=example

# Exasol currently offers no ARM support.
exasol: exasol/Dockerfile
	env DIR=exasol REGISTRY=sqitch ARCHS=amd64 ./build

# ClickHouse currently offers no ARM support for its ODBC driver.
# https://github.com/ClickHouse/clickhouse-odbc/issues/524
clickhouse: clickhouse/Dockerfile
	env DIR=clickhouse REGISTRY=sqitch ARCHS=amd64 ./build
