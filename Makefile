.DEFAULT_GOAL := sqitch
.PHONY: oracle snowflake vertica exasol firebird postgres mysql sqlite

sqitch: Dockerfile
	./build .

oracle: oracle/Dockerfile
	./build oracle

snowflake: snowflake/Dockerfile
	./build snowflake


