# MongoDB

The `mongo` adapter for [MongoDB][3] wraps the `labix.org/v2/mgo` driver
written by [Gustavo Niemeyer][1].

## Known limitations

* Does not support transactions.
* Does not support the `db` tag. You must use [bson][4] tags instead.
* Does not support query builder.

## Installation

If you want to install the package with `go get`, you'll need the [bazaar][2]
version control system.

You can install `bzr` like this:

```
sudo apt-get install bzr -y
```

After bazaar is installed, use `go get` to download and install the adapter.

```
go get upper.io/db.v2/mongo
```

## Setting up database access

The `mongo.ConnectionURL{}` struct is defined as follows:

```go
// ConnectionURL implements a MongoDB connection struct.
type ConnectionURL struct {
  User     string
  Password string
  Host     string
  Database string
  Options  map[string]string
}
```

Pass the `mongo.ConnectionURL` value as argument for `mongo.Open()`
to create a `mongo.Database` session.

A `mongo.ParseURL()` function is provided to convert a DSN into a
`mongo.ConnectionURL`:

```go
// ParseURL parses s into a ConnectionURL struct.
mongo.ParseURL(s string) (ConnectionURL, error)
```

## Usage

Import the `upper.io/db.v2/mongo` package into your application:

```go
// main.go
package main

import (
  "upper.io/db.v2/mongo"
)
```

Then, you can use the `mongo.Open()` method to create a session:

```go
var settings = mongo.ConnectionURL{
  Host:       "localhost",          // PostgreSQL server IP or name.
  Database:   "peanuts",            // Database name.
  User:       "cbrown",             // Optional user name.
  Password:   "snoopy",             // Optional user password.
}

sess, err = mongo.Open(settings)
```

## Example

The Go code below will add some rows to the "birthday" collection and then
will print the same rows that were inserted.

```go
// example.go

package main

import (
  "fmt"
  "log"
  "time"

  "upper.io/db.v2/mongo"
)

var settings = mongo.ConnectionURL{
  Database:  `upperio_tests`,
  Host:      `127.0.0.1`,
}

type Birthday struct {
  // Maps the "Name" property to the "name" column
  // of the "birthday" table.
  Name string `bson:"name"`
  // Maps the "Born" property to the "born" column
  // of the "birthday" table.
  Born time.Time `bson:"born"`
}

func main() {

  // Attemping to establish a connection to the database.
  sess, err := mongo.Open(settings)
  if err != nil {
    log.Fatalf("db.Open(): %q\n", err)
  }
  defer sess.Close() // Remember to close the database session.

  // Pointing to the "birthday" table.
  birthdayCollection := sess.Collection("birthday")

  err = birthdayCollection.Truncate()
  if err != nil {
    log.Fatalf("Truncate(): %q\n", err)
  }

  // Inserting some rows into the "birthday" table.
  birthdayCollection.Append(Birthday{
    Name: "Hayao Miyazaki",
    Born: time.Date(1941, time.January, 5, 0, 0, 0, 0, time.UTC),
  })

  birthdayCollection.Append(Birthday{
    Name: "Nobuo Uematsu",
    Born: time.Date(1959, time.March, 21, 0, 0, 0, 0, time.UTC),
  })

  birthdayCollection.Append(Birthday{
    Name: "Hironobu Sakaguchi",
    Born: time.Date(1962, time.November, 25, 0, 0, 0, 0, time.UTC),
  })

  // Let's query for the results we've just inserted.
  res := birthdayCollection.Find()

  // Query all results and fill the birthday variable with them.
  var birthday []Birthday

  err = res.All(&birthday)
  if err != nil {
    log.Fatalf("res.All(): %q\n", err)
  }

  // Printing to stdout.
  for _, birthday := range birthday {
    fmt.Printf(
      "%s was born in %s.\n",
      birthday.Name,
      birthday.Born.Format("January 2, 2006"),
    )
  }
}
```

Running the example above:

```
go run main.go
```

Expected output:

```
Hayao Miyazaki was born in January 5, 1941.
Nobuo Uematsu was born in March 21, 1959.
Hironobu Sakaguchi was born in November 25, 1962.
```

[1]: http://labix.org/v2/mgo
[2]: http://bazaar.canonical.com/en/
[3]: http://www.mongodb.org/
[4]: http://labix.org/gobson
[5]: http://godoc.org/upper.io/db.v2#IDSetter
[6]: http://godoc.org/upper.io/db.v2/mongo#ObjectIdIDSetter
