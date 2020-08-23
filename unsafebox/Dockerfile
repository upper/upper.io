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

RUN useradd -ms /bin/bash sandbox

ENV GOPATH /go

ENV WORKDIR /home/sandbox
WORKDIR $WORKDIR

#ENV TAG_V1 v1.0.1
ENV TAG_V2 v2.0.7
ENV TAG_V3 v3.7.1
ENV TAG_V4 d40a001b839feeb41b3873b3d5abff99da077ca1

ENV SRC_DIR ./src

ENV LEGACY_ROOT $GOPATH/src/upper.io
ENV UPPER_ROOT $GOPATH/src/github.com/upper/db

RUN mkdir -p $LEGACY_ROOT $UPPER_ROOT

#RUN git clone https://github.com/upper/db.git $LEGACY_ROOT/db.v1 && \
#  cd $LEGACY_ROOT/db.v1 && \
#  git checkout $TAG_V1 && \
#  go get -v ./...

COPY _tests ./_tests

RUN git clone https://github.com/upper/db.git $SRC_DIR

RUN cp -r $SRC_DIR $LEGACY_ROOT/db.v2 && \
  cd $LEGACY_ROOT/db.v2 && \
  git checkout $TAG_V2 && \
  go get -v ./...
RUN cd ./_tests/v2 && go build -v

RUN cp -r $SRC_DIR $LEGACY_ROOT/db.v3 && \
  cd $LEGACY_ROOT/db.v3 && \
  git checkout $TAG_V3 && \
  go get -v ./...
RUN cd ./_tests/v3 && go build -v

RUN cp -r $SRC_DIR $UPPER_ROOT/v4 && \
  cd $UPPER_ROOT/v4 && \
  git checkout $TAG_V4 && \
  go get -v ./...
RUN cd ./_tests/v4 && go build

ENTRYPOINT ["/bin/entrypoint.sh"]
