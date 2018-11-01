# upper.io/db.v3

# Purpose

`upper-db` provides a *common interface* to work with different data sources
using *adapters* that wrap mature SQL and NoSQL database drivers.

Its main purpose is to enable [Go 1.8+][1] developers to perform database tasks (CRUD) in MySQL, PostgreSQL, SQLite, MSSQL, QL, or MongoDB.

<center>
![upper.io/db.v3 package](/db.v3/res/general.png)
</center>

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> Coming from [db.v2](https://upper.io/db.v2)? we have a [migration
> guide](https://upper.io/db.v3/migrate-from-v2) that may come in handy.

# Key concepts

<center>
![Database](/db.v3/res/database.png)
</center>

A **session** is a database context created with the `Open()` function featured in the adapter package. 

A **collection** is a set of similar data type items identified with the name 'table' in SQL or 'collection' in NoSQL.

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> The term 'collection' is used indistinctively by methods that work on both SQL and  NoSQL. Such is the case of `Collection()`, which creates a reference to the structures of any of these two database types.

A **result set** is a subset of items that match specific conditions. It is retrieved with `Find()` and can be delimited or modified through different methods, like `Update()`, `Delete()`, `Insert()`, `All()`, or `One()`.

The figure below ilustrates the session, collection, and result set
concepts:

<center>
![Collections](/db.v3/res/collection.png)
</center>

# SQL/NoSQL Considerations

In order to use `upper-db` efficiently, it is advisable that you:

1. Understand the database you're working with (object-relational or document-oriented)
1. Use Go structs to describe data models. One struct per table is a good practice.
1. Try to use methods applicable to both SQL and NoSQL first. 
1. Use SQL builder or raw SQL only when needed. 

# Installation

The `upper.io/db.v3` package depends on the [Go compiler and tools][2] and is
compatible with Go 1.4 and above.

```sh
go get -v -u upper.io/db.v3
```

In the event this command does not work, you can always pull the data source directly from GitHub:

```sh
export UPPERIO_V3=$GOPATH/src/upper.io/db.v3
rm -rf $UPPERIO_V3
mkdir -p $UPPERIO_V3
git clone https://github.com/upper/db.git $UPPERIO_V3
cd $UPPERIO_V3
go build && go install
```

## Supported databases

To see the complete list of supported adapters, click [here](/db.v3/adapters).

# Setup
## Database Session

Import the adapter package into your application:

```go
import (
  "upper.io/db.v3/postgresql" // PostgreSQL package
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

fmt.Printf("DSN: %s", settings) // settings.String() is a DSN
```

Start a database session by passing the `settings` value to the `Open()` function of your adapter:

```go
sess, err = postgresql.Open(settings) // sess is a db.Database type
...
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> Once you finish to work with the database session, use `Close()` to free all associated resources. Note that Go Servers are long-lived processes, you may never need to manually `Close()` a session unless you don`t need it at all anymore.

```go
err = sess.Close()
...
```

## Collection Reference

Set a given database structure (table or collection):

```go
users = sess.Collection("users") // Reference to a table named "users"
...
```
 
## Mapping

Map exported fields to structs by adding a `db` tag next to them:

```go
type Person struct {
  ID       uint64 `db:"id,omitempty"` // Use `omitempty` for zero-valued
                                      // fields that are not to be sent 
                                      // by the adapter.
  Name     string `db:"name"`
  LastName string `db:"last_name"`
}
```

You can mix different `db` struct tags, including those used to map JSON: 

```go
type Person struct {
  ID        uint64 `db:"id,omitempty" json:"id"`
  Name      string `db:"name" json:"name"`
  ...
  Password  string `db:"password,omitempty" json:"-"`
}
```

You can also set the adapter to ignore specific fields by means of a hyphen (`-`):

```go
type Person struct {
  ...
  Token    string `db:"-"` // Field to be skipped
}
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> If mapping is not explicit, the adapter will perform a case-sensitive lookup of field names.

# CRUD Functions
## Retrieval

Get specific pieces of information (result sets) using `Find()`:

```go
// All the items in the collection are requested.
res = sess.Collection("people").Find() 
...

// String-like syntax is accepted.
res = sess.Collection("people").Find("id", 25) 

// Equality is the default operator but a different one can be used.
res = sess.Collection("people").Find("id >", 29) 

// The `?` placeholder maps arguments by order.
res = sess.Collection("people").Find("id > ? AND id < ?", 20, 39)  

// The And/Or methods can serve the same purpose.
res = sess.Collection("people").Find("id >", 20).And("id <", 39)

res = sess.Collection("people").Find("id", 20).Or("id", 21)

// Primary keys can also be passed as arguments.
res = sess.Collection("people").Find(20)
```

### Constraints

You can narrow down result sets with db.Cond{}`:

```go
cond = db.Cond{ // Equality is the default operator 
  "id": 36, // id = 36
}
```

```go
cond = db.Cond{ // ...but a different one can be used. 
  "id >=": 36, // id >= 36
}
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> Note that `db.Cond` is a `map[interface{}]interface{}` type and accepts multiple keys.

```go
// John Smi% is to be located. 
cond = db.Cond{
  "name": "John",
  "last_name LIKE": "Smi%",
}
```

Constraints can also be composed using `db.Or()`/`db.And()`:

```go
db.Or(
  db.Cond{"name": "John"}, // The name to be retrieved can be John or Jhon.
  db.Cond{"name": "Jhon"},
)
```

```go
db.And(
  db.Cond{"age >": 21}, // The ages to be retrieved can range from 22 to 27.
  db.Cond{"age <": 28},
)

Nesting values is another option:

```go
db.And(
  db.And( // The result set will cover ages from 22 to 27
    db.Cond{"age >": 21},
    db.Cond{"age <": 28},
  ),
  db.Or( // along with the names Joanna, John, or Jhon.
    db.Cond{"name": "Joanna"},
    db.Cond{"name": "John"},
    db.Cond{"name": "Jhon"},
  ),
)
```

### Results Limit and Order

You can determine the number of items you want to go through using `Offset()` and
`Limit()`:

```go
res = col.Find(...)
...

err = res.Offset(2).Limit(8).All(&accounts) // The result set will consist of 8
                                            // items and skip the first 2 rows.
...
```

Results can also be sorted according to a given value with `OrderBy()`:

```go
res = col.Find(...)
...

err = res.OrderBy("-last_name").All(&accounts) // Descending order by last name
...
```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> Remember that the total number of items in a result set can be calculated with `Count()`:

```go
res = col.Find(...)
...

c, err = res.Count()
...

fmt.Printf("There are %d items", c)

```

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> `Limit()`, `Offset()`, and `OrderBy()` affect exclusively the `All()`
and `One()` methods.

## Creation, Update, and Deletion

Insert, modify, and remove items in the result set. 

To get the full picture on how to perform all CRUD tasks (starting right from the installation and setup steps), take the upper-db [tour](https://tour.upper.io/welcome/01).

![Note](https://github.com/LizGoro90/db-tour/tree/master/static/img)
> The methods related to sessions, collections, and result sets are exemplified using the approaches 'SQL/NoSQL' and 'SQL only'. For further reference about what applies in each case, click [here](https://upper.io/db.v3/examples).

# Tips and tricks

### Logging

You can force the adapter to print SQL statements and errors to standard output
by using the `UPPERIO_DB_DEBUG` environment variable:

```console
UPPERIO_DB_DEBUG=1 ./go-program
```

### Working with the underlying driver

Some situations will require you to use methods that are only available from
the underlying driver, the `db.Database.Driver()` is there to help. For
instance, if you're in the need of using the
[mgo.Session.Ping](http://godoc.org/labix.org/v2/mgo#Session.Ping) method you
can retrieve the underlying `*mgo.Session` as an `interface{}`, cast it with
the appropriate type and use the `mgo.Session.Ping()` method on it, like this:

```go
drv = sess.Driver().(*mgo.Session) // You'll need to cast the driver
                                   // into the appropiare type.
err = drv.Ping()
```

You can expect to do the same with an SQL adapter, just change the casting:

```go
drv = sess.Driver().(*sql.DB)
rows, err = drv.Query("SELECT name FROM users WHERE age = ?", age)
```

## License

The MIT license:

> Copyright (c) 2013-2016 The upper.io/db authors.
>
> Permission is hereby granted, free of charge, to any person obtaining
> a copy of this software and associated documentation files (the
> "Software"), to deal in the Software without restriction, including
> without limitation the rights to use, copy, modify, merge, publish,
> distribute, sublicense, and/or sell copies of the Software, and to
> permit persons to whom the Software is furnished to do so, subject to
> the following conditions:
>
> The above copyright notice and this permission notice shall be
> included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
> LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
> OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
> WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[1]: https://golang.org
[2]: https://golang.org/doc/install
[3]: /db.v3/mysql
[4]: /db.v3/postgresql
[5]: /db.v3/sqlite
[6]: /db.v3/ql
[7]: /db.v3/mongo
[8]: /db.v3/mssql
