# MongoDB

The `mongo` adapter for [MongoDB][3] wraps the `labix.org/v2/mgo` driver
written by [Gustavo Niemeyer][1].

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> Please note that MongoDB:

* Does not support transactions.
* Does not support query builder.
* Uses [bson][4] tags instead of `db` for mapping.

## Installation

To use the package, you'll need the [bazaar][2] version control system:

```
sudo apt-get install bzr -y
```

Once this requirement is met, you can use `go get` to download and install the adapter:

```
go get upper.io/db.v3/mongo
```

## Setup
### Database Session

Import the `upper.io/db.v3/mongo` package into your application:

```go
// main.go
package main

import (
  "upper.io/db.v3/mongo"
)
```

Define the `mongo.ConnectionURL{}` struct:

```go
// ConnectionURL defines the DSN attributes.
type ConnectionURL struct {
  User     string
  Password string
  Host     string
  Database string
  Options  map[string]string
}
```

Pass the `mongo.ConnectionURL` value as argument to `mongo.Open()` so the `mongo.Database` session is created.

```go
settings = mongo.ConnectionURL{
  ...
}

sess, err = mongo.Open(settings)
...
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> The `mongo.ParseURL()` function is also provided in case you need to convert a DSN into a `mongo.ConnectionURL`:

```go
// ParseURL parses s into a ConnectionURL struct.
mongo.ParseURL(s string) (ConnectionURL, error)
```

## Common Database Operations
Once the connection is established, you can start performing operations on the database.

### Example
In the following example, a table named 'birthday' consisting of two columns ('name' and 'born') will be created. Before starting, the table will be searched in the database and, in the event it already exists, it will be removed. Then, three rows will be inserted into the table and checked for accuracy. To this end, the database will be queried and the matches (insertions) will be printed to standard output. 

The Go code below will add some rows to the "birthday" collection and then
will print the same rows that were inserted.

```go
// example.go

package main

import (
  "fmt"
  "log"
  "time"

  "upper.io/db.v3/mongo"
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
  birthdayCollection.Insert(Birthday{
    Name: "Hayao Miyazaki",
    Born: time.Date(1941, time.January, 5, 0, 0, 0, 0, time.UTC),
  })

  birthdayCollection.Insert(Birthday{
    Name: "Nobuo Uematsu",
    Born: time.Date(1959, time.March, 21, 0, 0, 0, 0, time.UTC),
  })

  birthdayCollection.Insert(Birthday{
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
[5]: http://godoc.org/upper.io/db.v3#IDSetter
[6]: http://godoc.org/upper.io/db.v3/mongo#ObjectIdIDSetter
