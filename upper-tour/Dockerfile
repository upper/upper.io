FROM golang:1.14 AS builder

WORKDIR /go/src/github.com/upper/tour

COPY . .

RUN go install github.com/upper/tour/cmd/tour

FROM debian:buster

COPY --from=builder /go/src/github.com/upper/tour/tutorials /app/tutorials
COPY --from=builder /go/src/github.com/upper/tour/static /app/static
COPY --from=builder /go/bin/tour /app/tour

WORKDIR /app

ENTRYPOINT [ "/app/tour" ]
