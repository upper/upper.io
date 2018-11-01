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

res = sess.Collection("people").Find("id >", 29) // Equality is the default operator
                                                 // but a different one can be used.

// Use the `?` placeholder to map arguments by position:
res = sess.Collection("people").Find("id > ? AND id < ?", 20, 39)

// Or the And/Or methods if you prefer:
res = sess.Collection("people").Find("id >", 20).And("id <", 39)

res = sess.Collection("people").Find("id", 20).Or("id", 21)

// If the table has a primary key, you can look up by that
// key by providing it as sole argument:
res = sess.Collection("people").Find(20)
```

`db.Collection.Find()` returns a result set reference, or `db.Result`.

### Adding constraints

`db.Cond{}` is a `map[interface{}]interface{}` type that represents conditions,
by default `db.Cond` expresses an equality between columns and values:

```go
cond = db.Cond{
  "id": 36, // id = 36
}
```

As with `Find()`, you can also add operators next to the column name to change
the equality into something else:

```go
cond = db.Cond{
  "id >=": 36, // id >= 36
}

cond = db.Cond{
  "name LIKE": "Pete%", // SQL: name LIKE 'Pete%'
}
```

Note that `db.Cond` is a just map and it accepts multiple keys:

```go
// name = 'John' AND last_name = 'Smi%'
cond = db.Cond{
  "name": "John",
  "last_name LIKE": "Smi%",
}
```

### Composing conditions: db.Or and db.And

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

// Which is the same as:
db.Cond{
  "age >": 21,
  "age <": 28,
}

// Perhaps db.And is more useful in situations like:
db.And(
  db.Cond{"name": "john"},
  db.Cond{"name": "jhon"},
)
```

Both `db.Or()` and `db.And()` can take other `db.Or()` and `db.And()` nested
values:

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

### Special conditions for SQL databases

SQL databases support conditions with a string part:

```go
res = col.Find("id", 9)     // id = 9
...

res = col.Find("id = ?", 9) // id = 9
...

res = col.Find("id = 9")    // id = 9 is possible but not recommended
...
```

This is how you could compose queries with different conditions:

```go
// name = "John" OR name = "María"
res = col.Find("name", "John").Or("name", "María")
...

// name = "John" AND last_name = "Smith"
res = col.Find("name", "John").And("last_name", "Smith")

// The ? placeholder is automatically converted to $1, $2, etc. on databases
// that require it.

// name = "John" AND last_name = "Smith"
res = col.Find("name = ? AND last_name = ?", "John", "Smith")
...
```


### Getting the number of items in the result set

Use the `Count()` method to get the number of items on a result set:


```go
res = col.Find(...)
...

c, err = res.Count()
...

fmt.Printf("There are %d items", c)

```

### Options for limiting and sorting results

Reduce the number of results you want to walk over using the `Limit()` and
`Offset()` methods of `db.Result`:

```go
res = col.Find(...)
...

err = res.Offset(2).Limit(8).All(&accounts)
...
```

Use the `OrderBy()` method to order them:

```go
res = col.Find(...)
...

err = res.OrderBy("-last_name").All(&accounts) // OrderBy by last_name descending order
...
```

Note: The `Limit()`, `Offset()`, and `OrderBy()` methods only affect the `All()`
and `One()` methods, they don't have any effect on `Delete()`, `Update()` or
`Count()`.


### Dealing with `NULL` values

The `database/sql` package provides some special types
([NullBool](http://golang.org/pkg/database/sql/#NullBool),
[NullFloat64](http://golang.org/pkg/database/sql/#NullBool),
[NullInt64](http://golang.org/pkg/database/sql/#NullInt64) and
[NullString](http://golang.org/pkg/database/sql/#NullString)) which can be used
to represent values than could be `NULL`.

SQL adapters support those special types with no additional effort:

```go
type TestType struct {
  ...
  Salary sql.NullInt64 `db:"salary"`
  ...
}
```

Another way of using null values is by using pointers on field values:

```go
type TestType struct {
  ...
  FirstName *string `db:"first_name"`
  ...
}
```

In the above struct, the `FirstName` pointer would be `nil` when no value was
present on the table. Use with care.

### The Marshaler and Unmarshaler interfaces

`db` defines two special interfaces that can be used to marshal struct fields
before saving them the database and unmarshal them when retrieving from it:

```go
type Marshaler interface {
  MarshalDB() (interface{}, error)
}

type Unmarshaler interface {
  UnmarshalDB(interface{}) error
}
```

This comes in very handy when dealing with custom struct field types that `db`
does not know how to convert.


```go
type LatLong struct {
  Lat  float64
  Long float64
}

func (ll LatLong) MarshalDB() (interface{}, error) {
  // Encode ll before saving it to the database.
  return encodeLatLng(ll), nil
}

func (ll *LatLong) UnmarshalDB(v interface{}) (error) {
  // Decode the encoded value v into the custom type.
  *ll = decodeLatLng(fmt.Sprintf("%v", v))
  return nil
}

type Point struct {
  ...
  LL LatLong `db:"ll,omitempty"`
  ...
}
```

## Advanced usage

The basic collection/result won't be appropriate for some situations, when this
happens, you can use `db` as a simple bridge between SQL queries and Go types.

SQL adapters come with a [SQL builder](/db.v3/lib/sqlbuilder), try it and see if it
fits your needs:

```go
q = sess.Select("name").From("accounts").
  Join("owners").
  Using("employee_id")
...

err = q.All(&accounts)
...
```

If the SQL builder is not able to express what you want, you can use hand-made
SQL queries directly:

```go
rows, err = sess.Query(`SELECT * FROM accounts WHERE id = ?`, 5)
...

row, err = sess.QueryRow(`SELECT * FROM accounts WHERE id = ? LIMIT ?`, 5, 1)
...

res, err = sess.Exec(`DELETE FROM accounts WHERE id = ?`, 5)
...
```

SQL queries like the above can also be mapped to Go structs by using an
iterator:

```go
import "upper.io/db.v3/lib/sqlbuilder"
...

rows, err = sess.Query(`SELECT * FROM accounts WHERE last_name = ?`, "Smith")
...

var accounts []Account
iter := sqlbuilder.NewIterator(rows)
err = iter.All(&accounts)
...
```

See [SQL builder](/db.v3/lib/sqlbuilder).

## Transactions

Use the `NewTx` method on a session to create a transaction context:

```go
tx, err = sess.NewTx(nil)
...

id, err = tx.Collection("accounts").Insert(account)
...

res = tx.Collection("people").Find(...)
...

err = tx.Commit()
...

```

The returned `tx` value is a `db.Transaction` type, which is identical to a
regular `db.Session`, except that it also has the `Commit()` and `Rollback()`
methods which can be used to execute the transaction or to discard it
completely.

Once the transaction is commited or rolled back, the transaction will close
itself and won't be able to accept more commands.

## Tips and tricks

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
