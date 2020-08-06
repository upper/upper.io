FROM golang:1.14 AS builder

WORKDIR /go/src/github.com/upper/tour

COPY . .

ENV GO111MODULE=on

RUN cd cmd/tour && \
  go mod init \
  && go get ./... \
  && go build -o /go/bin/tour .

FROM debian:buster

COPY --from=builder /go/src/github.com/upper/tour/tutorials /app/tutorials
COPY --from=builder /go/src/github.com/upper/tour/static /app/static
COPY --from=builder /go/bin/tour /app/tour

WORKDIR /app

ENTRYPOINT [ "/app/tour" ]
