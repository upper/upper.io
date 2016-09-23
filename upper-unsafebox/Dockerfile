FROM xiam/playgo-unsafebox

RUN apt-get update && apt-get install -y iptables net-tools iftop htop netcat curl

COPY entrypoint.sh /bin/entrypoint.sh

ENV WORKDIR /home/sandbox
WORKDIR $WORKDIR

RUN useradd -ms /bin/bash sandbox

ENV GOPATH /go
ENV UPPERPATH $GOPATH/src/upper.io/db.v2
ENV REVISION 16e06e6298f93f10cddba5c8476d873ba09a40ee

RUN mkdir -p $UPPERPATH && git clone https://github.com/upper/db.git $UPPERPATH
RUN cd $UPPERPATH && git checkout $REVISION && go get -v ./...

ENTRYPOINT ["/bin/entrypoint.sh"]
