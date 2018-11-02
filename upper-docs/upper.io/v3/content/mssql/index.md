# SQL Server

The `mssql` adapter for [SQL Server][2] wraps the `github.com/denisenkom/go-mssqldb`
driver written by [denisenkom][1].

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> Here you’ll learn about the particularities of the [SQL Server][2] adapter. Before starting to read this detailed information, it is advisable that you take a look at the [getting started](https://upper.io/db.v3/getting-started) page so you become acquainted with the basics of upper-db and you can grasp concepts better.

## Installation

Use `go get` to download and install the adapter:

```
go get upper.io/db.v3/mssql
```

## Setup
### Database Session

Import the `upper.io/db.v3/mssql` package into your application:

```go
// main.go
package main

import (
  "upper.io/db.v3/mssql"
)
```

Define the `mssql.ConnectionURL{}` struct:

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

Pass the `mssql.ConnectionURL` value as argument to `mssql.Open()` so the `mssql.Database` session is created.

```go
settings = mssql.ConnectionURL{
  ...
}

sess, err = mssql.Open(settings)
...
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> The `mssql.ParseURL()` function is also provided in case you need to convert the DSN into a `mssql.ConnectionURL`:

```go
// ParseURL parses a DSN into a ConnectionURL struct.
mssql.ParseURL(dsn string) (ConnectionURL, error)
```

## Example

The following SQL statement creates a `birthday` table with `name` and `born`
columns.

```sql
--' example.sql
CREATE TABLE [birthdays] (
  id BIGINT PRIMARY KEY NOT NULL IDENTITY(1,1),
  name NVARCHAR(50),
  born DATETIME,
  born_ut BIGINT
);
```

The Go code below will add some rows to the `birthday` table and it then will
print the same rows that were inserted.

```go
// example.go

package main

import (
  "fmt"
  "log"
  "time"

  "upper.io/db.v3/mssql"
)

var settings = mssql.ConnectionURL{
  Database: `upperio_tests`,
  Host:     `localhost,`
  User:     `upperio`,
  Password: `upperio`,
}

type Birthday struct {
  // Name maps the "Name" property to the "name" column
  // of the "birthday" table.
  Name string `db:"name"`

  // Born maps the "Born" property to the "born" column
  // of the "birthday" table.
  Born time.Time `db:"born"`
}

func main() {

  // Attemping to establish a connection to the database.
  sess, err := mssql.Open(settings)
  if err != nil {
    log.Fatalf("db.Open(): %q\n", err)
  }
  defer sess.Close() // Remember to close the database session.

  // Pointing to the "birthday" table.
  birthdayCollection := sess.Collection("birthday")

  // Attempt to remove existing rows (if any).
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

  // Query all results and fill the birthdays variable with them.
  var birthdays []Birthday

  err = res.All(&birthdays)
  if err != nil {
    log.Fatalf("res.All(): %q\n", err)
  }

  // Printing to stdout.
  for _, birthday := range birthdays {
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

### SQL builder

You can use the [query builder](/db.v3/lib/sqlbuilder) for any complex SQL query:

```go
q := sess.Select(
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

### The identity type

If you want to use auto-increment (or serial) keys with a SQL Server database,
you must define the column type as an `IDENTITY(1, 1)`, like this:

```sql
CREATE TABLE foo(
  id BIGINT PRIMARY KEY NOT NULL IDENTITY(1,1),
  title NVARCHAR(50)
);
```

Remember to set the `omitempty` option to the ID field:

```go
type Foo struct {
  ID    int64   `db:"id,omitempty"`
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

[1]: https://github.com/denisenkom
[2]: https://www.microsoft.com/en-us/sql-server/sql-server-2016
[3]: /db.v3/getting-started
[4]: /db.v3/examples
