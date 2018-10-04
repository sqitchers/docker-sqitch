.DEFAULT_GOAL := sqitch

VERSION=0.9998
GIT_COMMIT=$(shell git rev-parse --short HEAD)
GIT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
BRANCH_TAG=$(shell basename ${GIT_BRANCH})

sqitch: Dockerfile
	docker build --pull \
	  --label org.opencontainers.image.created=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	  --label org.opencontainers.image.authors='Sqitch Hackers <sqitch-hackers@googlegroups.com>' \'
	  --label org.opencontainers.image.url="https://hub.docker.com/r/sqitch/sqitch/" \
	  --label org.opencontainers.image.documentation="https://github.com/sqitchers/docker-sqitch#readme" \
	  --label org.opencontainers.image.source="https://github.com/sqitchers/docker-sqitch" \
	  --label org.opencontainers.image.version="0.9998" \
	  --label org.opencontainers.image.revision=${GIT_COMMIT} \
	  --label org.opencontainers.image.vendor="The Sqitch Community" \
	  --label org.opencontainers.image.licenses="MIT" \
	  --label org.opencontainers.image.ref.name="sqitch-${VERSION}" \
	  --label org.opencontainers.image.title="Sqitch" \
	  --label org.opencontainers.image.description="Sane database change management" \
	  --tag sqitch/sqitch:latest \
	  --tag sqitch/sqitch:${VERSION} \
	  --build-arg VERSION=${VERSION} \
	  .
