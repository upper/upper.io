---
title: CockroachDB + upper/db + docker
author: xiam
authorURL: https://github.com/xiam
---

The fantastic people at [Cockroach labs](https://www.cockroachlabs.com/) made
it possible for us to work on an adapter for
[CockroachDB](https://www.cockroachlabs.com/product/).

[CockroachDB](https://www.cockroachlabs.com/product/) is a distributed database
that can scale horizontally among different clouds without any special
configuration, if you haven't had the chance to work with it you should
definitelly give it a try!

In this example, we're going to setup a local 3-node cluster, load a sample
database into it and run some queries against these nodes.

<!--truncate-->

## Tutorial

### Setting up cockroachdb

Step 1. Get the CockroachDB docker imaege

```
docker pull cockroachdb/cockroach:latest
```

Step 2. Create a CA certificate and a key

```sh
$ mkdir certs private
```

```sh
$ docker run \
  -v $PWD/certs:/certs \
  -v $PWD/private:/private \
  cockroachdb/cockroach \
    cert create-ca \
      --certs-dir=/certs \
      --ca-key=/private/ca.key
```

Step 3. Create additional certificates and keys for all of the nodes

```sh
$ docker run \
  -v $PWD/certs:/certs \
  -v $PWD/private:/private \
  cockroachdb/cockroach \
    cert create-node localhost node1.crdbnet node2.crdbnet node3.crdbnet \
      --certs-dir=/certs \
      --ca-key=/private/ca.key
```

Step 4. Create a certificate and a key for the root user

```sh
$ docker run \
  -v $PWD/certs:/certs \
  -v $PWD/private:/private \
  cockroachdb/cockroach \
    cert create-client root \
```

Step 5. Create a docker network `crdbnet` for our nodes to communicate

```sh
$ docker network create crdbnet
```

Step 6. Spin-up the first node

```sh
$ docker run \
  --rm \
  --name node1.crdbnet \
  --network crdbnet \
  -v $PWD/certs:/certs \
  -p 127.0.0.1:26257:26257 \
  -p 127.0.0.1:8080:8080 \
  cockroachdb/cockroach \
    start \
      --certs-dir=/certs \
      --advertise-addr=node1.crdbnet \
      --listen-addr=0.0.0.0:26257 \
      --http-addr=0.0.0.0:8080 \
      --join=node1.crdbnet,node2.crdbnet,node3.crdbnet
      --background
```

Step 7. Initialize the first node

```sh
$ docker run \
  --rm \
  --network crdbnet \
  -v $PWD/certs:/certs \
  cockroachdb/cockroach \
    init \
      --certs-dir=/certs \
      --host node1.crdbnet
```

Step 8. Spin-up the other two nodes

```sh
$ docker run \
  --rm \
  --name node2.crdbnet \
  --network crdbnet \
  -v $PWD/certs:/certs \
  -p 127.0.0.1:26258:26257 \
  -p 127.0.0.1:8081:8080 \
  cockroachdb/cockroach \
    start \
      --certs-dir=/certs \
      --advertise-addr=node2.crdbnet \
      --listen-addr=0.0.0.0:26257 \
      --http-addr=0.0.0.0:8080 \
      --join=node1.crdbnet,node2.crdbnet,node3.crdbnet
      --background

$ docker run \
  --rm \
  --name node3.crdbnet \
  --network crdbnet \
  -v $PWD/certs:/certs \
  -p 127.0.0.1:26259:26257 \
  -p 127.0.0.1:8082:8080 \
  cockroachdb/cockroach \
    start \
      --certs-dir=/certs \
      --advertise-addr=node3.crdbnet \
      --listen-addr=0.0.0.0:26257 \
      --http-addr=0.0.0.0:8080 \
      --join=node1.crdbnet,node2.crdbnet,node3.crdbnet
      --background
```

If you run `docker ps`, you should see your 3 nodes:

```
$ docker ps
CONTAINER ID        IMAGE                  NAMES
fd68a650....        .../cockroach      ... node3.crdbnet
812986e1....        .../cockroach      ... node2.crdbnet
8dd17890....        .../cockroach      ... node1.crdbnet
```

Enter into any of the nodes and create a new database and a new user using the
`cockroach sql` utility:

```
docker exec -it node1.crdbnet cockroach sql --certs-dir=/certs
#
# Welcome to the CockroachDB SQL shell.
# ...
root@:26257/defaultdb>
```

Execute the following SQL commants in the `cockroach sql` shell to create a
database and a user with all the privileges on this database:

```
CREATE DATABASE booktown;
CREATE USER demouser WITH PASSWORD 'demop4ss';
GRANT ALL ON DATABASE booktown TO demouser;
```

Now you should be able to connect to any of the nodes using `psql` and the
login we've just created:

```
# node1
psql -Udemouser -h127.0.0.1 -p26257 -dbooktown
Password for user demouser: demop4ss

# node2
psql -Udemouser -h127.0.0.1 -p26258 -dbooktown
Password for user demouser: demop4ss

# node3
psql -Udemouser -h127.0.0.1 -p26259 -dbooktown
Password for user demouser: demop4ss
```

Step 9. Load the
[booktown.sql](https://raw.githubusercontent.com/upper/upper.io/docusaurus/cockroachdb-server/booktown.sql)
sample file with `psql`:

```
psql -Udemouser -h127.0.0.1 -p26257 -dbooktown  < booktown.sql
```

You should be able to connect to any of the nodes and see some content:

```
$ psql -Udemouser -h127.0.0.1 -p26259 -dbooktown

booktown=> select * from books;
  id   |            title            | author_id | subject_id
-------+-----------------------------+-----------+------------
   156 | The Tell-Tale Heart         |       115 |          9
   190 | Little Women                |        16 |          6
  1234 | The Velveteen Rabbit        |     25041 |          3
  1501 | Goodnight Moon              |      2031 |          2
  1590 | Bartholomew and the Oobleck |      1809 |          2
  1608 | The Cat in the Hat          |      1809 |          2
  2038 | Dynamic Anatomy             |      1644 |          0
  4267 | 2001: A Space Odyssey       |      2001 |         15
  4513 | Dune                        |      1866 |         15
  7808 | The Shining                 |      4156 |          9
 25908 | Franklin in the Dark        |     15990 |          2
 41472 | Practical PostgreSQL        |      1212 |          4
 41473 | Programming Python          |      7805 |          4
 41477 | Learning Python             |      7805 |          4
 41478 | Perl Cookbook               |      7806 |          4
(15 rows)
```

### Using the cockroach adapter

Step 10. Get the CockroachDB adapter

Grab the `cockroachdb` adapter with `go get`.

```
go get github.com/upper/db/v4/adapter/cockroachdb
```

Step 11. Create a new `main.go` file

Create a minimal `main.go` file to test if the connection works:

$$
package main

import (
  "log"

  "github.com/upper/db/v4/adapter/cockroachdb"
)

// Use "127.0.0.1:26257", "127.0.0.1:26258" or "127.0.0.1:26259" for local
// testing.
const crdbNode = "cockroachdb.demo.upper.io"

var settings = cockroachdb.ConnectionURL{
  Database: `booktown`,
  Host:     crdbNode,
  User:     `demouser`,
  Password: `demop4ss`,
}

func main() {
  sess, err := cockroachdb.Open(settings)
  if err != nil {
    log.Fatal("cockroachdb.Open: ", err)
  }
  defer sess.Close()

  log.Printf("Connected!")
}
$$

Step 12. Query the "books" table

Now that you're connected, try to do query any of the tables:

$$
package main

import (
  "log"

  "github.com/upper/db/v4/adapter/cockroachdb"
)

// Use "127.0.0.1:26257", "127.0.0.1:26258" or "127.0.0.1:26259" for local
// testing.
const crdbNode = "cockroachdb.demo.upper.io"

var settings = cockroachdb.ConnectionURL{
  Database: `booktown`,
  Host:     crdbNode,
  User:     `demouser`,
  Password: `demop4ss`,
}

// Book represents an item from the "books" table. The fields accompanying the
// item represent the columns in the table and are mapped to Go values below.
type Book struct {
  ID  uint   `db:"id,omitempty"`
  Title     string `db:"title"`
  AuthorID  uint   `db:"author_id"`
  SubjectID uint   `db:"subject_id"`

  SkippedField string `db:"-"`
}

func main() {
  sess, err := cockroachdb.Open(settings)
  if err != nil {
    log.Fatal("cockroachdb.Open: ", err)
  }
  defer sess.Close()

  booksCol := sess.Collection("books")

  // Find().All() maps all the items from the books collection.
  books := []Book{}
  err = booksCol.Find().All(&books)
  if err != nil {
    log.Fatal("booksCol.Find: ", err)
  }

  // Print the queried information.
  log.Printf("Items in the %q collection:", booksCol.Name())
  for i := range books {
    log.Printf("item #%d: %#v", i, books[i])
  }
}
$$

## What's next?

Want to know more about CockroachDB?

* See all the [CockroachDB features](https://www.cockroachlabs.com/docs/stable/demo-replication-and-rebalancing.html)
* Take the [upper/db tour](https://tour.upper.io)

