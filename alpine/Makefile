.DEFAULT_GOAL := postgres
.PHONY: oracle snowflake vertica exasol firebird postgres mysql sqlite alpine

postgres: postgres/Dockerfile
	env DIR=postgres REGISTRY=sqitch ./build

sqlite: sqlite/Dockerfile
	env DIR=sqlite REGISTRY=sqitch ./build

mysql: mysql/Dockerfile
	env DIR=mysql REGISTRY=sqitch ./build
