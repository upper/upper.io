FROM xiam/playgo-unsafebox

RUN apt-get update && apt-get install -y iptables net-tools iftop htop netcat curl

COPY entrypoint.sh /bin/entrypoint.sh

ENV GOPATH /go

RUN go get -v upper.io/db.v2
RUN go get -v upper.io/db.v2/...

RUN useradd -ms /bin/bash sandbox

ENV WORKDIR /home/sandbox
WORKDIR $WORKDIR

ENTRYPOINT ["/bin/entrypoint.sh"]
