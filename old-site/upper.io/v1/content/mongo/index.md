# MongoDB adapter for upper.io/db.v1

The `mongo` adapter for [MongoDB][3] wraps the `labix.org/v2/mgo`
driver by [Gustavo Niemeyer][1].

This adapter supports CRUD but does not currently supports transactions.

## Known limitations

* Does not support transactions.
* Does not support the `db` tag. You must use [bson][4] tags instead.

## Installation

If you want to install the package with `go get`, you'll need the [bazaar][2]
version control system.

You can install `bzr` like this:

```
sudo apt-get install bzr -y
```

After bazaar is installed, use `go get` to download and install the adapter.

```
go get upper.io/db.v1/mongo
```

## Setting up database access

The `mongo.ConnectionURL{}` struct is defined like this:

```go
// ConnectionURL implements a MongoDB connection struct.
type ConnectionURL struct {
  User     string
  Password string
  Address  db.Address
  Database string
  Options  map[string]string
}
```

The `db.Address` interface can be satisfied by the `db.Host()`, `db.HostPort()`
or `db.Cluster()` functions.

Alternatively, a `mongo.ParseURL()` function is provided:

```go
// ParseURL parses s into a ConnectionURL struct.
mongo.ParseURL(s string) (ConnectionURL, error)
```

You may use `mongo.ConnectionURL` as argument for `db.Open()`.

## Usage

To use this adapter, import `upper.io/db.v1` and the `upper.io/db.v1/mongo` packages.

```go
# main.go
package main

import (
  "upper.io/db.v1"
  "upper.io/db.v1/mongo"
)
```

Then, you can use the `db.Open()` method to connect to a MongoDB server:

```go
var settings = mongo.ConnectionURL{
  Address:  db.Host("localhost"), // MongoDB hostname.
  Database: "peanuts",            // Database name.
  User:     "cbrown",             // Optional user name.
  Password: "snoopy",             // Optional user password.
}

sess, err = db.Open(mongo.Adapter, settings)
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
  "upper.io/db.v1"         // Imports the main db package.
  "upper.io/db.v1/mongo"   // Imports the mongo adapter.
)

var settings = mongo.ConnectionURL{
  Database: `upperio_tests`,        // Database name.
  Address:   db.Host("127.0.0.1"),  // Host's IP.
}

type Birthday struct {
  // Maps the "Name" property to the "name" column of the "birthday" table.
  Name string `bson:"name"`
  // Maps the "Born" property to the "born" column of the "birthday" table.
  Born time.Time `bson:"born"`
}

func main() {

  // Attemping to establish a connection to the database.
  sess, err := db.Open(mongo.Adapter, settings)

  if err != nil {
    log.Fatalf("db.Open(): %q\n", err)
  }

  // Remember to close the database session.
  defer sess.Close()

  // Pointing to the "birthday" table.
  birthdayCollection, err := sess.Collection("birthday")

  if err != nil {
    if err != db.ErrCollectionDoesNotExists {
      log.Fatalf("Could not use collection: %q\n", err)
    }
  } else {
    err = birthdayCollection.Truncate()

    if err != nil {
      log.Fatalf("Truncate(): %q\n", err)
    }
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
  var res db.Result

  res = birthdayCollection.Find()

  var birthday []Birthday

  // Query all results and fill the birthday variable with them.
  err = res.All(&birthday)

  if err != nil {
    log.Fatalf("res.All(): %q\n", err)
  }

  // Printing to stdout.
  for _, birthday := range birthday {
    fmt.Printf("%s was born in %s.\n", birthday.Name, birthday.Born.Format("January 2, 2006"))
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

## Custom ID Setter

This driver implements the canonical [IDSetter][5] interface but it also
implements the more specific [ObjectIdIDSetter][6] that you could use with an
struct like this:

```go
type artistWithObjectIdKey struct {
	id   bson.ObjectId
	Name string
}

// This SetID() will be called after a successful Append().
func (artist *artistWithObjectIdKey) SetID(id bson.ObjectId) error {
	artist.id = id
	return nil
}
```

[1]: http://labix.org/v2/mgo
[2]: http://bazaar.canonical.com/en/
[3]: http://www.mongodb.org/
[4]: http://labix.org/gobson
[5]: http://godoc.org/upper.io/db.v1#IDSetter
[6]: http://godoc.org/upper.io/db.v1/mongo#ObjectIdIDSetter

