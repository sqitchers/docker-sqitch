.DEFAULT_GOAL := sqitch
.PHONY: oracle snowflake vertica exasol firebird postgres mysql sqlite

sqitch: Dockerfile
	./build

oracle: oracle/Dockerfile
	env DIR=oracle REGISTRY=sqitch ./build

snowflake: snowflake/Dockerfile
	env DIR=snowflake REGISTRY=sqitch ./build --build-arg sf_account=example

exasol: exasol/Dockerfile
	env DIR=exasol REGISTRY=sqitch ./build
