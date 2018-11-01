# PostgreSQL

The `postgresql` adapter for [PostgreSQL][2] wraps the `github.com/lib/pq`
driver written by [Blake Mizerany][1].

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> Here you'll learn about the particularities of the [PostgreSQL][2] adapter. Before starting to read this detailed information, it is advisable that you take a look at the [getting started](https://upper.io/db.v3/getting-started) page so you become acquainted with the basics of upper-db and you can grasp concepts better. 

## Installation

Use `go get` to download and install the adapter:

```
go get upper.io/db.v3/postgresql
```

## Setup
### Database Session

Import the `upper.io/db.v3/postgresql` package into your application:

```go
// main.go
package main

import (
  "upper.io/db.v3/postgresql"
)
```

Define the `postgresql.ConnectionURL{}` struct:

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

Pass the `postgresql.ConnectionURL` value as argument to `postgresql.Open()`
so the `postgresql.Database` session is created.

```go
settings = postgresql.ConnectionURL{
  ...
}

sess, err = postgresql.Open(settings)
...
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> The `postgresql.ParseURL()` function is also provided in case you need to convert the DSN into a `postgresql.ConnectionURL`:

```go
// ParseURL parses a DSN into a ConnectionURL struct.
postgresql.ParseURL(dsn string) (ConnectionURL, error)
```
## Common Database Operations
Once the connection is established, you can start performing operations on the database.

### Example
In the following example, a table named 'birthday' consisting of two columns ('name' and 'born') will be created. Before starting, the table will be searched in the database and, in the event it already exists, it will be removed. Then, three rows will be inserted into the table and checked for accuracy. To this end, the database will be queried and the matches (insertions) will be printed to standard output. 

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> The database operations described above refer to an advanced use of upper-db, hence they do not follow the exact same patterns of the [tour](https://tour.upper.io/welcome/01) and [getting started](https://upper.io/db.v3/getting-started) page.

The `birthday` table with the `name` and `born` columns is created with these SQL statements:

```sql
--' example.sql
DROP TABLE IF EXISTS "birthday";

CREATE TABLE "birthday" (
  "name" CHARACTER VARYING(50),
  "born" TIMESTAMP
);
```

Use the `psql` command line tool to create the birthday table into the
`upperio_tests` database.

```
cat example.sql | PGPASSWORD=upperio psql -Uupperio upperio_tests
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

  "upper.io/db.v3/postgresql"
)

var settings = postgresql.ConnectionURL{
  Database: `upperio_tests`,
  Host:     `localhost`,
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
  sess, err := postgresql.Open(settings)
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

## Unique adapter features

### JSON types

The `postgresql` adapter supports saving and retrieving JSON data when using
[JSON types](https://www.postgresql.org/docs/9.4/static/datatype-json.html), if
you want to try this out, make sure that the table column was created as
`jsonb` and that the field has the `postgresql.JSONB` type.

```
import (
  ...
  "upper.io/db.v3/postgresql"
  ...
)

type Person struct {
  ...
  Properties  postgresql.JSONB  `db:"properties"`
  Meta        postgresql.JSONB  `db:"meta"`
}
```

JSON types area supported on PostgreSQL 9.4+.

Besides JSON, the `postgresql` adapter provides you with other custom types
like `postgresql.StringArray` and `postgresql.Int64Array`.

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

### Auto-incremental keys (serial)

If you want to use auto-increment (or serial) keys with PostgreSQL database,
you must define the column type as `SERIAL`, like this:

```sql
CREATE TABLE foo(
  id SERIAL PRIMARY KEY,
  title VARCHAR
);
```

Remember to set the `omitempty` option to the ID field:

```go
type Foo struct {
  ID    int64   `db:"id,omitempty"`
  Title string  `db:"title"`
}
```

Otherwise, you'll end up with an error like this:

```
ERROR:  duplicate key violates unique constraint "id"
```

In order for the ID to be returned by `db.Collection.Insert()`, the `SERIAL`
field must be set as `PRIMARY KEY` too.

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

[1]: https://github.com/lib/pq
[2]: http://www.postgresql.org/
[3]: /db.v3/getting-started
[4]: /db.v3/examples
