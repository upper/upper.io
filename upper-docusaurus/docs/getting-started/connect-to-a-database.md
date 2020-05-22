---
title: Create a database session
---

Use `go get` to grab the database adapter:

```sh
go get -v -u github.com/upper/db/adapter/$ADAPTER_NAME
```

Import the adapter package into your application:

```go
import (
  "github.com/upper/db/adapter/{{adapter_name}}"
)
```

`{{adapter_name}}` could be any of the following supported adapters:
`postgresql`, `mysql`, `cockroachdb`, `mssql`, `sqlite`, `ql` or `mongodb`.

In this example we'll use the `postgresql` adapter:

```go
import (
  "github.com/upper/db/adapter/postgresql"
)
```

All adapters come with a `ConnectionURL` struct that you can use to describe
parameters to open a database:

```go
// Use the `ConnectionURL` struct to create a DSN:
var settings = postgresql.ConnectionURL{
  User:     "maria",
  Password: "p4ss",
  Address:  "10.0.0.99",
  Database: "myprojectdb",
}

fmt.Printf("DSN: %s", settings)
```

also, every adapter comes with an `Open()` function that takes a
`ConnectionURL` and attempts to create a database session:

```go
// sess is a db.Session type
sess, err := postgresql.Open(settings)
...
```

> Instead of `postgresql.ConnectionURL` you can use `mysql.ConnectionURL`,
> `mssql.ConnectionURL`, etc. All of these structs satisfy `db.ConnectionURL`.

It is also possible to use a DSN string like
(`[adapter]://[user]:[password]@[host]/[database]`), you can easily convert it
into a `ConnectionURL` struct and use it to connect to a database by using the
`ParseURL` function that comes with your adapter:

```go
import (
  ...
  "github.com/upper/db/adapter/postgresql"
  ...
)

const connectDSN = `postgres://demouser:demop4ss@demo.upper.io/booktown`

// Convert the DSN into a ConnectionURL
settings, err := postgresql.ParseURL(connectDSN)
...

// And use it to connect to your database.
sess, err := postgresql.Open(settings)
...

log.Println("Now you're connected to the database!")
```

Once you finish to work with the database session, use `Close()` to free all
associated resources and caches. Keep in mind that Go apps are long-lived
processes, you may never need to manually `Close()` a session unless you don't
need it at all anymore.

```go
// Closing session
err = sess.Close()
...
```

The following example demonstrates how to connect, ping and disconnect from a
PostgreSQL database.

$$
package main

import (
	"log"

	"github.com/upper/db/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: "booktown",
	Host:     "demo.upper.io",
	User:     "demouser",
	Password: "demop4ss",
}

func main() {
	log.Printf("Connecting with DSN %q", settings)

	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}

	if err := sess.Ping(); err != nil {
		log.Fatal("Ping: ", err)
	}

	log.Printf("Successfully connected to database: %q", sess.Name())
	sess.Close()
}
$$

> Please note that different databases may have particular ways of connecting
> to a database server or openning a database file, some databases like SQLite
> do not have a server concept and they just use files. Please refer to the
> page of the adapter you're using to see such particularities.

## Underlying driver

In case you require methods that are only available from the underlying driver,
you can use the `db.Database.Driver()` method, which returns an `interface{}`.
For instance, if you need the
[mgo.Session.Ping](http://godoc.org/labix.org/v2/mgo#Session.Ping) method, you
can retrieve the underlying `*mgo.Session` as an `interface{}`, cast it into
the appropriate type, and use `Ping()`, as shown below:

```go
drv = sess.Driver().(*mgo.Session) // The driver is cast into the
                                   // the appropriate type.
err = drv.Ping()
```

You can do the same when working with an SQL adapter by changing the casting:

```go
drv = sess.Driver().(*sql.DB)
rows, err = drv.Query("SELECT name FROM users WHERE age = ?", age)
```

