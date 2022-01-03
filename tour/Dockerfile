FROM golang:1.17 AS builder

WORKDIR /go/src/github.com/upper/tour

COPY . .

RUN cd cmd/tour \
  && go build -o /go/bin/tour .

FROM debian:bullseye

COPY --from=builder /go/src/github.com/upper/tour/tutorials /app/tutorials
COPY --from=builder /go/src/github.com/upper/tour/static /app/static
COPY --from=builder /go/bin/tour /app/tour

WORKDIR /app

ENTRYPOINT [ "/app/tour" ]
