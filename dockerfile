#!/usr/bin/env -S docker build --compress -t eth0izzle/shhgit -f

ARG GOPATH=/data
ARG PACKAGE=github.com/eth0izzle/shhgit
FROM debian as build

RUN apt update
RUN apt install -y \
	curl git golang

ENV PATH "$PATH:/usr/local/go/bin"

ARG GOPATH
ARG PACKAGE
ARG CGO_ENABLED=0
ARG GO111MODULE=on
WORKDIR "${GOPATH}/src/${PACKAGE}"
COPY ./ ./
RUN echo get build test install \
	| xargs -n1 \
	| xargs -n1 -I% -- go % -a -ldflags '-s' .
RUN sed -i.org "s:^  - '':  - \${GITHUB_TOKEN}:" ./config.yaml

FROM scratch
ARG GOPATH
ARG PACKAGE
COPY --from=build "/etc/ssl" "/etc/ssl"
COPY --from=build "${GOPATH}/bin/shhgit" /shhgit
COPY --from=build "${GOPATH}/src/${PACKAGE}/config.yaml" /config.yaml
ENTRYPOINT [ "/shhgit" ]
CMD        [ ]
