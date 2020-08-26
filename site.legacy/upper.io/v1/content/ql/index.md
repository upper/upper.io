# QL adapter for upper.io/db.v1

The `upper.io/db.v1/ql` adapter for the [QL][1] is a wrapper of the
`github.com/cznic/ql/ql` driver by [Jan Mercl][1].

## Installation

Use `go get` to download and install the adapter:

```go
go get upper.io/db.v1/ql
```

## Setting up database access

The `ql.ConnectionURL{}` struct is defined like this:

```go
// ConnectionURL implements a SQLite connection struct.
type ConnectionURL struct {
  Database string
  Options  map[string]string
}
```

Alternatively, a `ql.ParseURL()` function is provided:

```go
// ParseURL parses s into a ConnectionURL struct.
ql.ParseURL(s string) (ConnectionURL, error)
```

You may use `ql.ConnectionURL` as argument for `db.Open()`.

## Usage

To use this adapter, import `upper.io/db.v1` and the `upper.io/db.v1/ql` packages.

```go
# main.go
package main

import (
  "upper.io/db.v1"
  "upper.io/db.v1/ql"
)
```

Then, you can use the `db.Open()` method to open a QL database file:

```go
var settings = ql.ConnectionURL{
  Database: `/path/to/example.db`, // Path to a QL database file.
}

sess, err = db.Open(ql.Adapter, settings)
```

## Example

The following SQL statement creates a table with "name" and "born"
columns.

```sql
--' example.sql

DROP TABLE IF EXISTS birthday;

CREATE TABLE birthday (
  name string,
  born time
);
```

Use the `ql` command line tool to create a `example.db` database
file.

```
rm -f example.db
cat example.sql | ql -db example.db
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
  "upper.io/db.v1"      // Imports the main db package.
  "upper.io/db.v1/ql"   // Imports the ql adapter.
)

var settings = ql.ConnectionURL{
  Database: `example.db`, // Path to database file.
}

type Birthday struct {
  // Maps the "Name" property to the "name" column of the "birthday" table.
  Name string `db:"name"`
  // Maps the "Born" property to the "born" column of the "birthday" table.
  Born time.Time `db:"born"`
}

func main() {

  // Attemping to open the "example.db" database file.
  sess, err := db.Open(ql.Adapter, settings)

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

### Raw SQL

Sometimes you'll need to run complex SQL queries with joins and database
specific magic, there is an extra package `sqlutil` that you could use in this
situation:

```go
import "upper.io/db.v1/util/sqlutil"
```

This is an example for `sqlutil.FetchRows`:

```go
  var sess db.Database
  var rows *sql.Rows
  var err error
  var drv *sql.DB

  type publication_t struct {
    Id       int64  `db:"id,omitempty"`
    Title    string `db:"title"`
    AuthorId int64  `db:"author_id"`
  }

  if sess, err = db.Open(Adapter, settings); err != nil {
    t.Fatal(err)
  }

  defer sess.Close()

  drv = sess.Driver().(*sql.DB)

  rows, err = drv.Query(`
    SELECT
      p.id,
      p.title AS publication_title,
      a.name AS artist_name
    FROM
      artist AS a,
      publication AS p
    WHERE
      a.id = p.author_id
  `)

  if err != nil {
    t.Fatal(err)
  }

  var all []publication_t

  // Mapping to an array.
  if err = sqlutil.FetchRows(rows, &all); err != nil {
    t.Fatal(err)
  }

  if len(all) != 9 {
    t.Fatalf("Expecting some rows.")
  }
```

You can also use `sqlutil.FetchRow(*sql.Rows, interface{})` for mapping results
obtained from `sql.DB.Query()` calls to a pointer of a single struct instead of
a pointer to an array of structs. Please note that there is no support for
`sql.DB.QueryRow()` and that you must provide a `*sql.Rows` value to both
`sqlutil.FetchRow()` and `sqlutil.FetchRows()`.

### Using `db.Raw` and `db.Func`

If you need to provide a raw parameter for a method you can use the `db.Raw`
type. Plese note that raw means that the specified value won't be filtered:

```go
res = sess.Find().Select(db.Raw{`DISTINCT(name)`})
```

`db.Raw` also works for condition values.

Another useful type that you could use to create an equivalent statement is
`db.Func`:

```go
res = sess.Find().Select(db.Func{`DISTINCT`, `name`})
```

[1]: https://github.com/cznic/ql
[2]: http://golang.org/doc/effective_go.html#blank
