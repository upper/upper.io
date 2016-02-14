# SQLite

The `sqlite` adapter for the [SQLite3][3] wraps the
`github.com/mattn/go-sqlite3` driver written by [Yasuhiro Matsumoto][1].

## Installation

This package uses cgo, so in order to compile and install it you'll also need a
C compiler, such as `gcc`:

```
# Debian
sudo apt-get install gcc

# FreeBSD
sudo pkg install gcc
sudo ln -s /usr/local/bin/gcc47 /usr/local/bin/gcc
```

If you're on a Mac, you'll need [Xcode](https://developer.apple.com/xcode/) and
the Command Line Tools.

Otherwise, you'll end with an error like this:

```
# github.com/mattn/go-sqlite3
exec: "gcc": executable file not found in $PATH
```

Once `gcc` is installed, use `go get` to download, compile and install the
sqlite adapter.

```
go get upper.io/db.v2/sqlite
```

## Setting up database access

The `sqlite.ConnectionURL{}` struct is defined like this:

```go
// ConnectionURL implements a SQLite connection struct.
type ConnectionURL struct {
  Database string
  Options  map[string]string
}
```

Alternatively, a `sqlite.ParseURL()` function is provided to convert
a string into a `sqlite.ConnectionURL`:

```go
// ParseURL parses s into a ConnectionURL struct.
sqlite.ParseURL(s string) (ConnectionURL, error)
```

You may use `sqlite.ConnectionURL` as argument for `db.Open()`.

## Usage

To use this adapter, import `upper.io/db.v2` and the `upper.io/db.v2/sqlite` packages.

```go
// main.go
package main

import (
  "upper.io/db.v2"
  "upper.io/db.v2/sqlite"
)
```

Then, you can use the `db.Open()` method to open a SQLite3 database file:

```go
var settings = sqlite.ConnectionURL{
  Database: `/path/to/example.db`, // Path to a sqlite3 database file.
}

sess, err = db.Open(sqlite.Adapter, settings)
```

## Example

The following SQL statement creates a table with "name" and "born"
columns.

```sql
--' example.sql

DROP TABLE IF EXISTS "birthday";

CREATE TABLE "birthday" (
  "name" varchar(50) DEFAULT NULL,
  "born" varchar(12) DEFAULT NULL
);
```

Use the `sqlite3` command line tool to create a `example.db`
database file.

```
rm -f example.db
cat example.sql | sqlite3 example.db
```

The Go code below will add some rows to the "birthday" table and then will
print the same rows that were inserted.

```go
// example.go

package main

import (
  "fmt"
  "log"
  "time"
  "upper.io/db.v2"          // Imports the main db package.
  "upper.io/db.v2/sqlite"   // Imports the sqlite adapter.
)

var settings = sqlite.ConnectionURL{
  Database: `example.db`, // Path to database file.
}

type Birthday struct {
  // Maps the "Name" property to the "name" column
  // of the "birthday" table.
  Name string `db:"name"`
  // Maps the "Born" property to the "born" column
  // of the "birthday" table.
  Born time.Time `db:"born"`
}

func main() {

  // Attemping to open the "example.db" database file.
  sess, err := db.Open(sqlite.Adapter, settings)

  if err != nil {
    log.Fatalf("db.Open(): %q\n", err)
  }

  // Remember to close the database session.
  defer sess.Close()

  // Pointing to the "birthday" table.
  birthdayCollection, err := sess.Collection("birthday")

  if err != nil {
    log.Fatalf("sess.Collection(): %q\n", err)
  }

  // Attempt to remove existing rows (if any).
  err = birthdayCollection.Truncate()

  if err != nil {
    log.Fatalf("Truncate(): %q\n", err)
  }

  // Inserting some rows into the "birthday" table.

  birthdayCollection.Append(Birthday{
    Name: "Hayao Miyazaki",
    Born: time.Date(1941, time.January, 5, 0, 0, 0, 0, time.Local),
  })

  birthdayCollection.Append(Birthday{
    Name: "Nobuo Uematsu",
    Born: time.Date(1959, time.March, 21, 0, 0, 0, 0, time.Local),
  })

  birthdayCollection.Append(Birthday{
    Name: "Hironobu Sakaguchi",
    Born: time.Date(1962, time.November, 25, 0, 0, 0, 0, time.Local),
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
    fmt.Printf("%s was born in %s.\n",
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

## Unique adapter features

### SQL builder

You can use que query builder for any complex SQL query:

```go
q := b.Select(
    "p.id",
    "p.title AD publication_title",
    "a.name AS artist_name",
  ).From("artists AS a", "publication AS p").
  Where("a.id = p.author_id")

iter := q.Iterator()

var publications []Publication

if err = iter.All(&publications); err != nil {
  log.Fatal(err)
}
```

### Auto-incremental keys

If you want to use auto-increment keys with a SQLite database, you must define
the column type as `INTEGER PRIMARY KEY`, like this:

```sql
CREATE TABLE foo(
  id INTEGER PRIMARY KEY,
  title VARCHAR(255)
);
```

Remember to set the `omitempty` option to the ID field:

```go
type Foo struct {
  Id    int64   `db:"id,omitempty"`
  Title string  `db:"title"`
}
```

### Using `db.Raw` and `db.Func`

If you need to provide a raw parameter for a method you can use the `db.Raw`
function. Plese note that raw means that the specified value won't be filtered:

```go
res = sess.Find().Select(db.Raw("DISTINCT(name)"))
```

`db.Raw` also works for condition values.

Another useful type that you could use to create an equivalent statement is
`db.Func`:

```go
res = sess.Find().Select(db.Func("DISTINCT", "name"))
```

[1]: https://github.com/mattn/go-sqlite3
[2]: http://golang.org/doc/effective_go.html#blank
[3]: http://www.sqlite.org/
