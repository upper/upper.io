# MySQL

The `mysql` adapter for [MySQL][2] wraps the `github.com/go-sql-driver/mysql`
driver written by [Julien Schmidt][1].

## Installation

Use `go get` to download and install the adapter:

```
go get upper.io/db.v2/mysql
```

## Setting up database access

The `mysql.ConnectionURL{}` struct is defined as follows:

```go
// ConnectionURL implements a MySQL connection struct.
type ConnectionURL struct {
  User     string
  Password string
  Address  db.Address
  Database string
  Options  map[string]string
}
```

The `db.Address` interface can be satisfied by the `db.Host()`, `db.HostPort()`
or `db.Socket()` functions.

Alternatively, a `mysql.ParseURL()` function is provided to convert a string
into a `mysql.ConnectionURL`:

```go
// ParseURL parses s into a ConnectionURL struct.
mysql.ParseURL(s string) (ConnectionURL, error)
```

## Usage

To use this adapter, import `upper.io/db.v2` and the `upper.io/db.v2/mysql` packages.

```go
// main.go
package main

import (
  "upper.io/db.v2"
  "upper.io/db.v2/mysql"
)
```

Then, you can use the `db.Open()` method to connect to a MySQL server:

```go
var settings = mysql.ConnectionURL{
  Address:  db.Host("localhost"), // MySQL server IP or name.
  Database: "peanuts",            // Database name.
  User:     "cbrown",             // Optional user name.
  Password: "snoopy",             // Optional user password.
}

sess, err = db.Open(mysql.Adapter, settings)
```

## Example

The following SQL statement creates a table with "name" and "born"
columns.

```sql
--' example.sql
DROP TABLE IF EXISTS birthday;

CREATE TABLE birthday (
  `name` VARCHAR(50),
  `born` DATE
);
```

Use the `mysql` command line tool to create the birthday table on the
upperio_tests database.

```
cat example.sql | mysql -uupperio -pupperio upperio_tests
```

The Go code below will add some rows to the "birthday" table and then will
print the same rows that were inserted.

```go
// example.go

package main

import (
  "fmt"
  "time"
  "upper.io/db.v2"         // Imports the main db package.
  "upper.io/db.v2/mysql"   // Imports the mysql adapter.
)

var settings = mysql.ConnectionURL{
  Database: `upperio_tests`,
  Address:  db.ParseAddress(`127.0.0.1`),
  User:     `upperio`,
  Password: `upperio`,
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

  // Attemping to establish a connection to the database.
  sess, err := db.Open(mysql.Adapter, settings)

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

gives the following output:

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

If you want to use auto-increment keys with a MySQL database,
you must define the column type as `NOT NULL AUTO_INCREMENT`, like this:

```sql
CREATE TABLE foo(
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(id),
  title VARCHAR(255)
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

[1]: https://github.com/go-sql-driver/mysql
[2]: http://www.mysql.com
