# upper.io/db.v2

![upper.io/db.v2 package](/db.v2/res/general.png)

The `upper.io/db.v2` package for [Go][1] provides a *common interface* to work
with different data sources using *adapters* that wrap mature database drivers.

```go
import(
  "upper.io/db.v2"             // main package
  "upper.io/db.v2/postgresql"  // adapter for PostgreSQL
)
```

`db` supports the [MySQL][3], [PostgreSQL][4], [SQLite][5] and [QL][6]
databases and provides partial support (CRUD, no transactions) for
[MongoDB][7].

## Introduction

### What's the idea behind `upper.io/db.v2`?

`db` centers around the concept of sets. A collection (or table) represents a
set that contains data items (or rows).

![Database](/db.v2/res/database.png)

In the following example we load the `people` slice with all the elements from
the "people" collection whose "name" field (or column) equals the value "Max".

### Differences from v1

1. v2 has a query builder.
1. `db.And()`, `db.Or()`, `db.Func()` and `db.Raw()` are now functions.
1. `db.Session.Collection()` only accepts one table.
1. JOIN capabilities where removed from `Find()` (in favour of `Builder()`).

### How to install v2?

Use `go get` to pull the package:

```go
go get -v upper.io/db.v2
```

If the above command does not work for some reason, you can also pull the
source directly from GitHub:

```sh
export UPPERIO_V2=$GOPATH/src/upper.io/db.v2
rm -rf $UPPERIO_V2
mkdir -p $UPPERIO_V2
git clone https://github.com/upper/db.git $UPPERIO_V2
cd $UPPERIO_V2 && git checkout v2
go build && go install
```

### Code example

```go
var people []Person

col, err = sess.Collection("people")
...

res = col.Find(db.Cond{"name": "Max"})
err = res.All(&people)
...
```

If we only wanted one result, we could have used `res.One()` instead:

```go
var person Person

col, err = sess.Collection("people")
...

res = col.Find(db.Cond{"name": "Max"})
err = res.All(&person)
...
```

In the above example, we use `sess.Collection()` to get a collection reference
and then the `Find()` method on `col` to filter out the results we want; this
creates a result set `res` which we can use to map results into an slice (with
`All()`) or into a single struct (with `One()`).

The result res points to all the rows from the "people" table that match
whatever conditions were passed to `db.Collection.Find()`. This result set is
not only useful for getting and mapping data from permanent storage, but to
update or delete all the items in the subset as well.

```go
res = col.Find(db.Cond{"name": "Jhon"})
err = res.Update(db.M{"name": "John"})
...
err = res.Remove()
...
```

![Collections](/db.v2/res/collection.png)

A result set cannot be used to add an item to the collection, because a it can
only define a subset of rows that already exists. If you wanted to add a row to
the collection you can use the `Append()` method on it:

```go
person = Person{
  Name:     "Harper",
  LastName: "Lee",
}
nid, err = col.Append(person)
...
```

If the table supports automatic indexes, then the `nid` returned by `Append()`
would be set to the value of the newly added index. The `nid` is actually an
`interface{}` type, so you'll probably need to cast it:

```go
rid, err = col.Append(person)
...
id, _ = nid.(int64)
```

The simple CRUD operations described above may come in handy for getting and
saving data from different databases, but what if you wanted to use custom
queries on SQL databases? It is also easy, you can just use the same SQL
builder that powers `db`:

```go
bob = sess.Builder()
...

q = bob.Select("a.name").From("accounts a").
  Join("profile p").On("a.profile_id = p.id")

var accounts []Account
err = q.Iterator().All(&accounts)
...
```

If you think the SQL builder methods are not flexible enough you can also use
raw SQL:

```go
bob = sess.Builder()
...

q = bob.Query("SELECT * FROM accounts WHERE id = ?", 5)

var account Account
err = q.Iterator().One(&account)
```

Please note that SQL builder is only supported on SQL databases.

As you can see `db` offers you a range of tools that are designed to make
working with databases less tedious and more productive.

## Installation

The `upper.io/db.v2` package depends on the [Go compiler and tools][2] and it's
compatible with Go 1.1 and above.

Use `go get` to download `db`:

```sh
go get -v -u upper.io/db.v2
```

## Database adapters

The `db` package provides basic functions and interfaces but you'll also need a
**database adapter** in order to actually communicate with a database.

![Adapters](/db.v2/res/adapters.png)

Here's the list of currently supported adapters, make sure to read the
instructions from the specific adapter for installation instructions:

* [MySQL](/db.v2/mysql/)
* [MongoDB](/db.v2/mongo)
* [PostgreSQL](/db.v2/postgresql)
* [QL](/db.v2/ql)
* [SQLite](/db.v2/sqlite/)

## Quick start

### Mapping tables to structs

Mapping a table to a struct is easy, you only have to add the `db` tag next to
an **exported field** definition and provide options if you need them:

```go
type Person struct {
  ID       uint64 `db:"id,omitempty"` // use `omitempty` to let the database set the value.
  Name     string `db:"name"`
  LastName string `db:"last_name"`
}
```

You can mix `db` tags with other tags, such as those used to map JSON:

```go
type Person struct {
  ID        uint64 `db:"id,omitempty" json:"id"`
  Name      string `db:"name" json:"name"`
  ...
  Password  string `db:"password,omitempty" json:"-"`
}
```

If you don't provide explicit mappings, `db` will try to use the field name
(case-sensitive), but you can also set `-` as the name of the field to skip it:

```go
type Person struct {
  ...
  Token    string `db:"-"` // ignore this field completely.
}
```

### Setting up a database session

Import both the `upper.io/db.v2` and the adapter packages into your application:

```go
import (
  "upper.io/db.v2"
  "upper.io/db.v2/postgresql" // example adapter package
)
```

All adapters include a `ConnectionURL` function that you can use to create a
DSN:

```go
var settings = postgresql.ConnectionURL{
  User:     "john",
  Password: "p4ss",
  Address:  db.Host("localhost"),
  Database: "myprojectdb",
}
```

With a DSN you can create a database session:

```go
sess, err = db.Open(postgresql.Adapter, settings)
...
```

You can use any `db.Database` methods on `sess`, such as `Collection()`; that
one will get you a collection reference.

```go
usersCol, err = sess.Collection("users")
...
```

The `C()` method does the same as `Collection()` but panics if the collection
does not exists:

```go
res = sess.C("users").Find()
...
```

Once you're done with the database session, you must use `Close()` to close it:

```go
err = sess.Close()
...
```

### Inserting a new item into a collection

We can use the database session `sess` to get a collection reference and insert
a value into it:

```go
person := Person{
  Name:     "Hedy",
  LastName: "Lamarr",
}

peopleCol, err = sess.Collection("people")
...

id, err = peopleCol.Append(person)
...
```

If you're absolutely sure the collection exists and you don't fear a panic in
case it doesn't, you could also use the `C()` method and chain `db.Collection`
methods to it:

```go
id, err = sess.C("people").Append(person)
...
```

The recommened way however is to use `Collection()` and manage errors by
yourself.

### Defining a result set with `Find()`

You can use `Find()` on a collection reference to get a result set from that
collection.

```go
res = sess.C("people").Find()
```

`Find()` accepts conditions that you can describe with the `db.Cond{}` map:

```go
res = sess.C("people").Find(db.Cond{
  "id": 25,
})
```

### Simple conditions: db.Cond{}

`db.Cond{}` is a map with `string` keys and `interface{}` values, the keys
represent columns and the values represent, yes! values.

By default `db.Cond{}` expresses an equality between columns and values:

```go
cond = db.Cond{
  "id": 36, // id equals 36
}
```

But you can also add special operators next to the column to change the
equality relation for something else:

```go
cond = db.Cond{
  "id >": 36, // id greater than 36
}
```

Besides basic operators, you can also use special operators that may only work
on certain databases, such as `LIKE` on SQL databases:

```go
cond = db.Cond{
  "name LIKE": "Pete%", // SQL: name LIKE 'Pete%'
}
```

You can create a `db.Cond{}` map with more than one key-value pair, that is
interpreted like you want both conditions to be met:

```go
// name = 'John' AND "last_name" = 'Smi%'
cond = db.Cond{
  "name": "John",
  "last_name LIKE": "Smi%",
}
```

### Composed conditions: db.Or and db.And

The `db.Or()` function takes one or more `db.Cond{}` maps and joins them under
the OR disjunction:

```go
// (name = 'John' OR name = 'Jhon')
db.Or(
  db.Cond{"name": "John"},
  db.Cond{"name": "Jhon"},
)
```

The `db.And()` function is like `db.Or()`, except it joins statements under the
AND conjunction:

```go
// (age > 21 AND age < 28)
db.And(
  db.Cond{"age >": 21},
  db.Cond{"age <": 28},
)
```

Both `db.Or()` and `db.And()` can take other `db.Or()` and `db.And()`
statements as well:

```go
// (
//   (age > 21 AND age < 28)
//   AND
//   (name = 'Joanna' OR name = 'John' OR name = 'Jhon')
// )

db.And(
  db.And(
    db.Cond{"age >": 21},
    db.Cond{"age <": 28},
  ),
  db.Or(
    db.Cond{"name": "Joanna"},
    db.Cond{"name": "John"},
    db.Cond{"name": "Jhon"},
  ),
)
```

### Getting the number of items in the result set

Use the `Count()` method to get the number of items in the result set:


```go
res = col.Find(...)
...
c, err = res.Count()
...

```

### Options for limiting and sorting results

You can limit the results you want to walk over using the `Skip()` and
`Limit()` methods:

```go
res = col.Find(...)
...
err = res.Skip(2).Limit(8).All(&accounts)
...
```

Or you can sort them:

```go
res = col.Find(...)
...
err = res.Sort("-last_name").All(&accounts) // sort by last_name descending order
...
```

Note: The `Limit()`, `Offset()`, and `Sort()` methods only affect the `All()`
and `One()` methods, they don't have any effect on `Remove()`, `Update()` or
`Count()`.


### Dealing with `NULL` values

The `database/sql` package provides some special types
([NullBool](http://golang.org/pkg/database/sql/#NullBool),
[NullFloat64](http://golang.org/pkg/database/sql/#NullBool),
[NullInt64](http://golang.org/pkg/database/sql/#NullInt64) and
[NullString](http://golang.org/pkg/database/sql/#NullString)) that can be used
to represent values than could be `NULL` at some point.

SQL adapters support those special types with no additional effort:

```go
type TestType struct {
  ...
  salary sql.NullInt64
  ...
}
```

### The Marshaler and Unmarshaler interfaces

`db` defines two special interfaces that can be used to marshal fields before
saving to the database and unmarshal them when retrieving from it:

```go
type Marshaler interface {
  MarshalDB() (interface{}, error)
}

type Unmarshaler interface {
  UnmarshalDB(interface{}) error
}
```

This comes in very handy when dealing with custom field types that `db` does
not how to convert.

## Transactions

It is very easy to group operations under a transaction, just use the
`Transaction()` method on a session:

```go
tx, err = sess.Transaction()
...
tx.C("accounts").Append(account)
...
res = tx.C("people").Find(...)
...
err = tx.Commit()
...

```

The returned `tx` value is identical to `db.Session`, except that it also has
the `Commit()` and `Rollback()` methods that can be used to execute the
transaction or to discard it completely.

Once the transaction is commited or rolled back, the transaction will no longer
accept more commands.

## Examples

See code examples and patterns at our [examples](/db.v2/examples) page.

## Tips and tricks

### Logging

You can force `upper.io/db.v2` to print SQL statements and errors to standard
output by using the `UPPERIO_DB_DEBUG` environment variable:

```console
UPPERIO_DB_DEBUG=1 ./go-program
```

You can also use this environment variable when running tests.

```console
cd $GOPATH/src/upper.io/db.v2/sqlite
UPPERIO_DB_DEBUG=1 go test
...
2014/06/22 05:15:20
  SQL: SELECT "tbl_name" FROM "sqlite_master" WHERE ("type" = 'table')

2014/06/22 05:15:20
  SQL: SELECT "tbl_name" FROM "sqlite_master" WHERE ("type" = ? AND "tbl_name" = ?)
  ARG: [table artist]
...
```

### Working with the underlying driver

Many situations will require you to use methods that are specific to the
underlying driver, for example, if you're in the need of using the
[mgo.Session.Ping](http://godoc.org/labix.org/v2/mgo#Session.Ping) method you
can retrieve the underlying `*mgo.Session` as an `interface{}`, cast it with
the appropriate type and use the `mgo.Session.Ping()` method on it, like this:

```go
drv = sess.Driver().(*mgo.Session)
err = drv.Ping()
```

This is another example using `db.Database.Driver()` with a SQL adapter:

```go
drv = sess.Driver().(*sql.DB)
rows, err = drv.Query("SELECT name FROM users WHERE age = ?", age)
```

If you're in the need of using raw SQL you may want to try with the SQL builder
first.

## License

The MIT license:

> Copyright (c) 2013-2015 The upper.io/db authors.
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
[3]: http://www.mysql.com/
[4]: http://www.postgresql.org/
[5]: http://www.sqlite.org/
[6]: https://github.com/cznic/ql
[7]: http://www.mongodb.org/
