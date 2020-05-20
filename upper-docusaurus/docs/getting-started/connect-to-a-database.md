---
title: Connect to a database
---

Use `go get` to grab latest `upper/db`

```sh
go get -v -u github.com/upper/db
```

## Database Session

Import the adapter package into your application:

```go
import (
  "github.com/upper/db/adapter/{adapter_name}"
)
```

Where `{adapter_name}` could be any of the following supported adapters:
`postgresql`, `mysql`, `cockroachdb`, `mssql`, `sqlite`, `ql` or `mongodb`.

In this example we'll use the `postgresql` adapter:

```go
import (
  "github.com/upper/db/adapter/postgresql"
)
```

Use the `ConnectionURL` struct included in the adapter to create a DSN:

```go
var settings = postgresql.ConnectionURL{
  User:     "john",
  Password: "p4ss",
  Address:  "10.0.0.99",
  Database: "myprojectdb",
}

fmt.Printf("DSN: %s", settings)
```

> Instead of `postgresql.ConnectionURL` you can use `mysql.ConnectionURL`,
> `mssql.ConnectionURL`, etc. All of these structs satisfy `db.ConnectionURL`.

Start a database session by passing the `settings` value to the `Open()`
function of your adapter:

```go
// sess is a db.Session type
sess, err := postgresql.Open(settings)
...
```

> Once you finish to work with the database session, use `Close()` to free all
> associated resources and caches. Keep in mind that Go apps are long-lived
> processes, you may never need to manually `Close()` a session unless you
> don't need it at all anymore.

```go
// Closing session
err = sess.Close()
...
```

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
