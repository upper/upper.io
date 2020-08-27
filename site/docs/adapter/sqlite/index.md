---
title: SQLite adapter
---

The `sqlite` adapter for [SQLite3][3] wraps the `github.com/mattn/go-sqlite3`
driver written by [Yasuhiro Matsumoto][1].

> Here you’ll learn about the particularities of the [SQLite][2] adapter.
> Before starting to read this detailed information, it is advisable that you
> take a look at the [getting started](/v4/getting-started) page so you become
> acquainted with the basics of `upper/db` and you can grasp concepts better.

## Installation

This package uses [cgo][4]. To use it, you'll need a C compiler, such as `gcc`:

```
# Debian
sudo apt-get install gcc

# FreeBSD
sudo pkg install gcc
sudo ln -s /usr/local/bin/gcc47 /usr/local/bin/gcc
```

> If you're using Mac, you'll need [Xcode](https://developer.apple.com/xcode/)
> and Command Line Tools.

Once this requirement is met, you can use `go get` to download, compile and
install the adapter:

```
go get github.com/upper/db/v4/adapter/sqlite
```

Otherwise, you'll see the following error:

```
# github.com/mattn/go-sqlite3
exec: "gcc": executable file not found in $PATH
```

## Setup

### Database Session

Import the `sqlite` package into your application:

```go
// main.go
package main

import (
  "github.com/upper/db/v4/adapter/sqlite"
)
```

Define the `sqlite.ConnectionURL{}` struct:

```go
// ConnectionURL defines the DSN attributes.
type ConnectionURL struct {
  Database string
  Options  map[string]string
}
```

Pass the `sqlite.ConnectionURL` value as argument to `sqlite.Open()` so the
session is created.

```go
settings = sqlite.ConnectionURL{
  ...
}

sess, err = sqlite.Open(settings)
...
```

> The `sqlite.ParseURL()` function is also provided in case you need to convert
> the DSN into a `sqlite.ConnectionURL`:

```go
// ParseURL parses a DSN into a ConnectionURL struct.
sqlite.ParseURL(dsn string) (ConnectionURL, error)
```

## Common Database Operations

Once the connection is established, you can start performing operations on the
database.

### Example

In the following example, a table named ‘birthday’ consisting of two columns
(‘name’ and ‘born’) will be created. Before starting, the table will be
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
  "name" varchar(50) DEFAULT NULL,
  "born" DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

The `sqlite3` command line tool is used to create an `example.db` database
file:

```
rm -f example.db
cat example.sql | sqlite3 example.db
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

  "github.com/upper/db/v4/adapter/sqlite"
)

var settings = sqlite.ConnectionURL{
  Database: `example.db`, // Path to database file
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

  // Attempt to open the 'example.db' database file
  sess, err := sqlite.Open(settings)
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

  // Three rows are inserted into the 'birthday' table.
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
  for _, birthday := range birthday {
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
types](https://www.sqlite.org/json1.html). If you want to try this out, make
sure the column type is `json` and the field type is `sqlite.JSON`:

```
import (
  ...
  "github.com/upper/db/v4/adapter/sqlite"
  ...
)

type Person struct {
  ...
  Properties  sqlite.JSON  `db:"properties"`
  Meta        sqlite.JSON  `db:"meta"`
}
```

> JSON types area supported on SQLite 3.9.0+.

### SQL Builder

You can use the SQL builder for any complex SQL query:

```go
q := b.SQL().Select(
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

### Auto-incremental Keys

If you want tables to generate a unique number automatically whenever a new
record is inserted, you can use auto-incremental keys. In this case, the column
must be defined as `INTEGER PRIMARY KEY`.

```sql
CREATE TABLE foo(
  id INTEGER PRIMARY KEY,
  title VARCHAR(255)
);
```

Remember to use `omitempty` to specify that the ID field should be ignored if
it has an empty value:

```go
type Foo struct {
  Id    int64   `db:"id,omitempty"`
  Title string  `db:"title"`
}
```

Otherwise, an error will be returned.

### Escape Sequences

There might be characters that cannot be typed in the context you're working,
or else would have an undesired interpretation. Through `db.Func` you can
encode the syntactic entities that cannot be directly represented by the
alphabet:

```go
res = sess.Find().Select(db.Func("DISTINCT", "name"))
```

On the other hand, you can use the `db.Raw` function so a given value is taken
literally:

```go
res = sess.Find().Select(db.Raw("DISTINCT(name)"))
```

> `db.Raw` can also be used as a condition argument, similarly to `db.Cond`.

## Take the tour

Get the real `upper/db` experience, take the [tour](//tour.upper.io).

[1]: https://github.com/mattn/go-sqlite3
[2]: http://golang.org/doc/effective_go.html#blank
[3]: http://www.sqlite.org/
[4]: https://golang.org/cmd/cgo/
