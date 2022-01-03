FROM xiam/go-playground-unsafebox:v0.10.0-rc1

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

RUN useradd -ms /bin/bash unsafebox

ENV GOPATH /go

ENV WORKDIR /home/unsafebox
WORKDIR $WORKDIR

ENV TAG_V2 v2.0.7
ENV TAG_V3 v3.8.0
ENV TAG_V4 v4.5.0-rc1

ENV SRC_DIR ./src

ENV LEGACY_ROOT $GOPATH/src/upper.io
ENV UPPER_ROOT $GOPATH/src/github.com/upper/db

RUN mkdir -p $LEGACY_ROOT $UPPER_ROOT

ENV GO111MODULE auto

COPY _tests ./_tests.modules

RUN cd ./_tests.modules/v2 && \
  go mod init github.com/upper/upper.io/unsafebox/_tests.modules/v2 && \
  go mod edit -replace upper.io/db.v2=upper.io/db.v2@${TAG_V2}+incompatible && \
  go mod vendor && \
  go build -v

RUN cd ./_tests.modules/v3 && \
  go mod init github.com/upper/upper.io/unsafebox/_tests.modules/v3 && \
  go mod edit -replace upper.io/db.v3=upper.io/db.v3@${TAG_V3}+incompatible && \
  go mod vendor && \
  go build -v

RUN cd ./_tests.modules/v4 && \
  go mod init github.com/upper/upper.io/unsafebox/_tests.modules/v4 && \
  go mod edit -replace github.com/upper/db/v4=github.com/upper/db/v4@${TAG_V4} && \
  go mod vendor && \
  go build -v

COPY _tests ./_tests.no-modules

RUN git clone https://github.com/upper/db.git $SRC_DIR

RUN cp -r $SRC_DIR $LEGACY_ROOT/db.v2 && \
  cd $LEGACY_ROOT/db.v2 && \
  git checkout $TAG_V2 && \
  GO111MODULE=off go get -v ./...

RUN cp -r $SRC_DIR $LEGACY_ROOT/db.v3 && \
  cd $LEGACY_ROOT/db.v3 && \
  git checkout $TAG_V3 && \
  GO111MODULE=off go get -v ./...

RUN cp -r $SRC_DIR $UPPER_ROOT/v4 && \
  cd $UPPER_ROOT/v4 && \
  git checkout $TAG_V4 && \
  GO111MODULE=off go get -v ./...

RUN cd ./_tests.no-modules/v2 && \
  GO111MODULE=off go build -v

RUN cd ./_tests.no-modules/v3 && \
  GO111MODULE=off go build -v

RUN cd ./_tests.no-modules/v4 && \
  GO111MODULE=off go build -v

ENTRYPOINT ["/bin/entrypoint.sh"]
