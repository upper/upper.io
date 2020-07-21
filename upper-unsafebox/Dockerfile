FROM xiam/go-playground-unsafebox:0.9.2

RUN apt-get update && \
  apt-get install -y \
    gcc \
    iptables \
    net-tools \
    iftop \
    htop \
    netcat \
    curl

COPY entrypoint.sh /bin/entrypoint.sh

ENV WORKDIR /home/sandbox
WORKDIR $WORKDIR

RUN useradd -ms /bin/bash sandbox

ENV GOPATH /go

#ENV TAG_V1 v1.0.1
ENV TAG_V2 v2.0.7
ENV TAG_V3 v3.7.1
ENV TAG_V4 233c81551bff73e62b0994723122230796a95a0a

ENV UPPER_ROOT $GOPATH/src/upper.io

RUN mkdir -p $UPPER_ROOT

#RUN git clone https://github.com/upper/db.git $UPPER_ROOT/db.v1 && \
#  cd $UPPER_ROOT/db.v1 && \
#  git checkout $TAG_V1 && \
#  go get -v ./...

RUN git clone https://github.com/upper/db.git $UPPER_ROOT/db.v2 && \
  cd $UPPER_ROOT/db.v2 && \
  git checkout $TAG_V2 && \
  go get -v ./...

RUN git clone https://github.com/upper/db.git $UPPER_ROOT/db.v3 && \
  cd $UPPER_ROOT/db.v3 && \
  git checkout $TAG_V3 && \
  go get -v ./...

RUN git clone https://github.com/upper/db.git $GOPATH/src/github.com/upper/db && \
  cd $GOPATH/src/github.com/upper/db && \
  git checkout $TAG_V4 && \
  go get -v github.com/upper/db/v4/...


ENTRYPOINT ["/bin/entrypoint.sh"]
