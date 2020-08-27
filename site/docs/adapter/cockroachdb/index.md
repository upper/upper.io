---
title: CockroachDB adapter
---

The `cockroachdb` adapter for [CockroachDB][2] wraps the `github.com/lib/pq`
driver written by [Blake Mizerany][1].

> Here you'll learn about the particularities of the [CockroachDB][2] adapter.
> Before starting to read this detailed information, it is advisable that you
> take a look at the [getting started](/v4/getting-started) page so you become
> acquainted with the basics of `upper/db` and you can grasp concepts better.

## Installation

Use `go get` to download and install the adapter:

```
go get github.com/upper/db/v4/adapter/cockroachdb
```

## Setup

### Database Session

Import the `cockroachdb` package into your application:

```go
// main.go
package main

import (
  "github.com/upper/db/v4/adapter/cockroachdb"
)
```

Define the `cockroachdb.ConnectionURL{}` struct:

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

Pass the `cockroachdb.ConnectionURL` value as argument to `cockroachdb.Open()`
so the session is created.

```go
settings = cockroachdb.ConnectionURL{
  ...
}

sess, err = cockroachdb.Open(settings)
...
```

> The `cockroachdb.ParseURL()` function is also provided in case you need to
> convert the DSN into a `cockroachdb.ConnectionURL`:

```go
// ParseURL parses a DSN into a ConnectionURL struct.
cockroachdb.ParseURL(dsn string) (ConnectionURL, error)
```
## Common Database Operations

Once the connection is established, you can start performing operations on the
database.

### Example

In the following example, a table named 'birthday' consisting of two columns
('name' and 'born') will be created. Before starting, the table will be
searched in the database and, in the event it already exists, it will be
removed. Then, three rows will be inserted into the table and checked for
accuracy. To this end, the database will be queried and the matches
(insertions) will be printed to standard output.

The `birthday` table with the `name` and `born` columns is created with these
SQL statements:

```sql
--' example.sql
DROP TABLE IF EXISTS "birthday";

CREATE TABLE "birthday" (
  "name" CHARACTER VARYING(50),
  "born" TIMESTAMP
);
```

The `psql` command line tool is used to run the statements in the
`upperio_tests` database:

```
cat example.sql | PGPASSWORD=upperio psql -Uupperio -h127.0.0.1 -p26257 upperio_tests
```

The rows are inserted into the `birthday` table. The database is queried for
the insertions and is set to print them to standard output.

```go
// example.go

package main

import (
  "fmt"
  "log"
  "time"

  "github.com/upper/db/v4/adapter/cockroachdb"
)

var settings = cockroachdb.ConnectionURL{
  Database: `upperio_tests`,  // Database name
  Host:     `localhost`,      // Server IP or name
  User:     `upperio`,        // Username
  Password: `upperio`,        // Password
}

type Birthday struct {
  // The 'name' column of the 'birthday' table
  // is mapped to the 'name' property.
  Name string `db:"name"`

  // The 'born' column of the 'birthday' table
  // is mapped to the 'born' property.
  Born time.Time `db:"born"`
}

func main() {

  // The database connection is attempted.
  sess, err := cockroachdb.Open(settings)
  if err != nil {
    log.Fatalf("db.Open(): %q\n", err)
  }
  defer sess.Close() // Closing the session is a good practice.

  // The 'birthday' table is referenced.
  birthdayCollection := sess.Collection("birthday")

  // Any rows that might have been added between the creation of
  // the table and the execution of this function are removed.
  err = birthdayCollection.Truncate()
  if err != nil {
    log.Fatalf("Truncate(): %q\n", err)
  }

  // Three rows are inserted into the 'Birthday' table.
  birthdayCollection.Insert(Birthday{
    Name: "Hayao Miyazaki",
    Born: time.Date(1941, time.January, 5, 0, 0, 0, 0, time.Local),
  })

  birthdayCollection.Insert(Birthday{
    Name: "Nobuo Uematsu",
    Born: time.Date(1959, time.March, 21, 0, 0, 0, 0, time.Local),
  })

  birthdayCollection.Insert(Birthday{
    Name: "Hironobu Sakaguchi",
    Born: time.Date(1962, time.November, 25, 0, 0, 0, 0, time.Local),
  })

  // The database is queried for the rows inserted.
  res := birthdayCollection.Find()

  // The 'birthdays' variable is filled with the results found.
  var birthdays []Birthday

  err = res.All(&birthdays)
  if err != nil {
    log.Fatalf("res.All(): %q\n", err)
  }

  // The 'birthdays' variable is printed to stdout.
  for _, birthday := range birthdays {
    fmt.Printf("%s was born in %s.\n",
      birthday.Name,
      birthday.Born.Format("January 2, 2006"),
    )
  }
}
```

The Go file is compiled and executed using `go run`:

```
go run example.go
```

The output consists of three rows including names and birthdates:

```
Hayao Miyazaki was born in January 5, 1941.
Nobuo Uematsu was born in March 21, 1959.
Hironobu Sakaguchi was born in November 25, 1962.
```

## Specifications

### JSON Types

You can save and retrieve data when using [JSON
types](https://www.cockroachdb.org/docs/9.4/static/datatype-json.html). If you
want to try this out, make sure the column type is `jsonb` and the field type
is `cockroachdb.JSONB`:

```
import (
  // ...
  "github.com/upper/db/v4/adapter/cockroachdb"
  // ...
)

type Person struct {
  ...
  Properties  cockroachdb.JSONB  `db:"properties"`
  Meta        cockroachdb.JSONB  `db:"meta"`
}
```

### SQL builder

You can use the SQL builder for any complex SQL query:

```go
q := sess.SQL().Select(
    "p.id",
    "p.title AD publication_title",
    "a.name AS artist_name",
  ).From("artists AS a", "publication AS p").
  Where("a.id = p.author_id")

var publications []Publication
if err = q.All(&publications); err != nil {
  log.Fatal(err)
}
```

### Auto-incremental Keys (Serial)

If you want tables to generate a unique number automatically whenever a new
record is inserted, you can use auto-incremental keys. In this case, the column
must be defined as `SERIAL`.

> In order for the ID to be returned by `db.Collection.Insert()`, the `SERIAL`
> column must be set as `PRIMARY KEY` too.

```sql
CREATE TABLE foo(
  id SERIAL PRIMARY KEY,
  title VARCHAR
);
```

Remember to use `omitempty` to specify that the ID field should be ignored if
it has a zero value:

```go
type Foo struct {
  ID    int64   `db:"id,omitempty"`
  Title string  `db:"title"`
}
```

otherwise, an error will be returned.

### Escape Sequences

There might be characters that cannot be typed in the context you're working,
or else would have an undesired interpretation. Through `db.Func` you can
encode the syntactic entities that cannot be directly represented by the
alphabet:

```go
res = sess.Find().Select(db.Func("DISTINCT", "name"))
```

on the other hand, you can use the `db.Raw` function so a given value is taken
literally:

```go
res = sess.Find().Select(db.Raw("DISTINCT(name)"))
```

> `db.Raw` can also be used as a condition argument, similarly to `db.Cond`.

## Take the tour

Get the real `upper/db` experience, take the [tour](//tour.upper.io).

[1]: https://github.com/lib/pq
[2]: https://www.cockroachlabs.com/
