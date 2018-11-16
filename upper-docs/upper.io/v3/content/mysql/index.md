# MySQL

The `mysql` adapter for [MySQL][2] wraps the `github.com/go-sql-driver/mysql`
driver written by [Julien Schmidt][1].

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> Here you’ll learn about the particularities of the [MySQL][2] adapter. Before starting to read this detailed information, it is advisable that you take a look at the [getting started](https://upper.io/db.v3/getting-started) page so you become acquainted with the basics of upper-db and you can grasp concepts better.

## Installation

Use `go get` to download and install the adapter:

```
go get upper.io/db.v3/mysql
```

## Setup
### Database Session

Import the `upper.io/db.v3/mysql` package into your application:

```go
// main.go
package main

import (
  "upper.io/db.v3/mysql"
)
```

Define the `mysql.ConnectionURL{}` struct:

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

Pass the `mysql.ConnectionURL` value as argument to `mysql.Open()` so the `mysql.Database` session is created.

```go
settings = mysql.ConnectionURL{
  ...
}

sess, err = mysql.Open(settings)
...
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> The `mysql.ParseURL()` function is also provided in case you need to convert the DSN into a `mysql.ConnectionURL`:

```go
// ParseURL parses a DSN into a ConnectionURL struct.
mysql.ParseURL(dsn string) (ConnectionURL, error)
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
DROP TABLE IF EXISTS birthday;

CREATE TABLE birthday (
  `name` VARCHAR(50),
  `born` DATE
);
```

The `mysql` command line tool is used to run the statements in the `upperio_tests` database.

```
cat example.sql | mysql -uupperio -pupperio upperio_tests
```

The rows are inserted into the `birthday` table. The database is queried for the insertions and is set to print them to standard output. 

```go
// example.go

package main

import (
  "fmt"
  "log"
  "time"
  "upper.io/db.v3/mysql"   // Imports the mysql adapter.
)

var settings = mysql.ConnectionURL{
  Database: `upperio_tests`,  // Database name
  Host:     `localhost,`      // Server IP or name
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
  sess, err := mysql.Open(settings)
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
  var res db.Result
  res = birthdayCollection.Find()

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

You can save and retrieve data when using [JSON types](https://dev.mysql.com/doc/refman/8.0/en/json.html). If you want to try this out, make sure the column type is `json` and the field type is `mysql.JSON`:

```
import (
  ...
  "upper.io/db.v3/mysql"
  ...
)

type Person struct {
  ...
  Properties  mysql.JSON  `db:"properties"`
  Meta        mysql.JSON  `db:"meta"`
}
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> JSON types area supported on MySQL 8.0+. 

### SQL Builder

You can use the [query builder](/db.v3/lib/sqlbuilder) for any complex SQL query:

```go
q := b.Select(
    "p.id",
    "p.title AS publication_title",
    "a.name AS artist_name",
  ).From("artists AS a", "publication AS p").
  Where("a.id = p.author_id")

var publications []Publication
if err = q.All(&publications); err != nil {
  log.Fatal(err)
}
```

### Auto-incremental Keys

If you want to generate a unique number automatically whenever a new record is inserted, you can use auto-incremental keys. In this case, the column must be defined as `NOT NULL AUTO_INCREMENT`.

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> In order for the ID to be returned by `db.Collection.Insert()`, the `AUTO_INCREMENT`
column must be set as `PRIMARY KEY` too.

```sql
CREATE TABLE foo(
  id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT, PRIMARY KEY(id),
  title VARCHAR(255)
);
```

Remember to use `omitempty` to specify that the ID field should be ignored if it has an empty value:

```go
type Foo struct {
  ID    int64   `db:"id,omitempty"`
  Title string  `db:"title"`
}
```

Otherwise, an error will be returned. 

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
[3]: /db.v3/getting-started
[4]: /db.v3/examples
