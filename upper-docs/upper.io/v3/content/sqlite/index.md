# SQLite

The `sqlite` adapter for [SQLite3][3] wraps the
`github.com/mattn/go-sqlite3` driver written by [Yasuhiro Matsumoto][1].

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> Here you’ll learn about the particularities of the [SQLite3][3] adapter. Before starting to read this detailed information, it is advisable that you take a look at the [getting started](https://upper.io/db.v3/getting-started) page so you become acquainted with the basics of upper-db and you can grasp concepts better.

## Installation

This package uses [cgo][4]. To use it, you'll need a C compiler, such as `gcc`:

```
# Debian
sudo apt-get install gcc

# FreeBSD
sudo pkg install gcc
sudo ln -s /usr/local/bin/gcc47 /usr/local/bin/gcc
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> If you're using Mac, you'll need [Xcode](https://developer.apple.com/xcode/) and
Command Line Tools.

Once this requirement is met, you can use `go get` to download, compile and install the adapter:

```
go get upper.io/db.v3/sqlite
```

Otherwise, you'll see the following error:

```
# github.com/mattn/go-sqlite3
exec: "gcc": executable file not found in $PATH
```

## Setup
### Database Session

Import the `upper.io/db.v3/sqlite` package into your application:

```go
// main.go
package main

import (
  "upper.io/db.v3/sqlite"
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

Pass the `sqlite.ConnectionURL` value as argument to `sqlite.Open()` so the `sqlite.Database` session is created.

```go
settings = sqlite.ConnectionURL{
  ...
}

sess, err = sqlite.Open(settings)
...
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> The `sqlite.ParseURL()` function is also provided in case you need to convert the DSN into a `sqlite.ConnectionURL`:

```go
// ParseURL parses a DSN into a ConnectionURL struct.
sqlite.ParseURL(dsn string) (ConnectionURL, error)
```

## Common Database Operations

Once the connection is established, you can start performing operations on the database.

### Example

In the following example, a table named ‘birthday’ consisting of two columns (‘name’ and ‘born’) will be created. Before starting, the table will be searched in the database and, in the event it already exists, it will be removed. Then, three rows will be inserted into the table and checked for accuracy. To this end, the database will be queried and the matches (insertions) will be printed to standard output.

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> The database operations described above refer to an advanced use of upper-db, hence
they do not follow the exact same patterns of the [tour](https://tour.upper.io/welcome/01) and [getting started](https://upper.io/db.v3/getting-started) page.

The `birthday` table with the `name` and `born` columns is created with these SQL statements:

```sql
--' example.sql
DROP TABLE IF EXISTS "birthday";

CREATE TABLE "birthday" (
  "name" varchar(50) DEFAULT NULL,
  "born" varchar(12) DEFAULT NULL
);
```

The `sqlite3` command line tool is used to create an `example.db` database file:

```
rm -f example.db
cat example.sql | sqlite3 example.db
```

The rows are inserted into the `birthday` table. The database is queried for the insertions and is set to print them to standard output.

```go
// example.go

package main

import (
  "fmt"
  "log"
  "time"

  "upper.io/db.v3/sqlite"
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
### SQL Builder

You can use the [query builder](/db.v3/lib/sqlbuilder) for any complex SQL query:

```go
q := b.Select(
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
[4]: https://golang.org/cmd/cgo/
[5]: /db.v3/getting-started
[6]: /db.v3/examples
