# upper.io/db.v3

`upper-db` provides a *common interface* to work with different data sources
using *adapters* that wrap mature database drivers.

The main purpose of `db` is to abstract common database tasks (CRUD) and
provide tools for [Go 1.8+][1] developers to perform complex queries when they
need to.

`db` supports the [MySQL][3], [PostgreSQL][4], [SQLite][5], [MSSQL][8] and
[QL][6] databases and provides partial support (CRUD, no transactions) for
[MongoDB][7].

<center>
![upper.io/db.v3 package](/db.v3/res/general.png)
</center>

Coming from [db.v2](https://upper.io/db.v2)? we have a [migration
guide](https://upper.io/db.v3/migrate-from-v2) that may come in handy.

## Key concepts

<center>
![Database](/db.v3/res/database.png)
</center>

A database context is known as a **session**. You can create a session by
importing the adapter package and using the `Open()` function that all adapters
provide:

```
import (
  ...
  "upper.io/db.v3/postgresql" // The PostgreSQL adapter
  ...
)

// Connection settings.
var settings = postgresql.ConnectionURL{
  Host:     "127.0.0.1",
  User:     "foo",
  Password: "bar",
}

func main() {
  sess, err := postgresql.Open(settings) // Open a connection.
  ...
}
```

The `Collection()` method of a session gives you a table reference, known as
**collection**:

```go
// The "people" table.
people = sess.Collection("people")
```

A collection reference provides special methods to perform operations on the
underlying table, such as `Find()` which can be used to define a subset of
items that match given conditions, this is known as a **result set**:

```go
var marias []Person
// SELECT * FROM people WHERE name = 'María'
res = people.Find("name", "María")
err = res.All(&marias)
...
```

`Find()` returns a result set, which is like lazy query that gets compiled and
executed only when a method is called on it.

```go
// All builds and executes a `SELECT * FROM ...` query.
err = res.All(&marias)

// One builds and executes a `SELECT * FROM ... LIMIT 1` query.
err = res.One(&maria)
```

Besides querying data, you can also perform other operations on `res`, such as
updating all the items on the result set at once:

```go
// UPDATE people SET ... WHERE ...
err = res.Update(newData)
...
```

Or deleting all matching items:

```go
// DELETE FROM article WHERE ...
err = sess.Collection("article").
  Find("date_created < ? and draft = ?", oneWeekAgo, true).
  Delete()
...
```

The figure below ilustrates the session, collection, `Find()` and result set
concepts:

<center>
![Collections](/db.v3/res/collection.png)
</center>

Besides giving tools for collections and result sets, sessions also have a
built-in SQLish [query builder](/db.v3/lib/sqlbuilder) that gives more freedom
while keeping manual SQL writing at bay.

```go
q = sess.SelectFrom("people")
  .Where("name = ?", "María")
err = q.All(&marias)
```

Advanced SQL commands should not be over-thinked or forced to fit into the
collection / result set syntax, if you feel like you need SQL then you can just
feed queries into the session:

```go
sqlRes, err = sess.Exec("CREATE TABLE ...") // sqlRes is a sql.Result
...

// The ? placeholder is automatically expanded into whatever placeholder the
// database expects.
sqlRows, err = tx.Query("SELECT * FROM (SELECT ... UNION ...) WHERE id > ?", 9)
...

// sqlRows is an *sql.Rows object, so you can use Scan() on it
err = sqlRows.Scan(&a, &b, ...)

// Or you could create and iterator to help you with mapping fields into
// a struct

// Just make sure you're importing the `sqlbuilder` package:
import "upper.io/db.v3/lib/sqlbuilder"
...

// And create a new Iterator with any *sql.Rows object:
iter = sqlbuilder.NewIterator(sqlRows)
err = iter.All(&item)
```

See more code examples and patterns on our [examples](/db.v3/examples) page.

## Installation

The `upper.io/db.v3` package depends on the [Go compiler and tools][2] and it's
compatible with Go 1.4 and above.

```sh
go get -v -u upper.io/db.v3
```

If the above command does not work for some reason, you can always pull the
source directly from GitHub:

```sh
export UPPERIO_V3=$GOPATH/src/upper.io/db.v3
rm -rf $UPPERIO_V3
mkdir -p $UPPERIO_V3
git clone https://github.com/upper/db.git $UPPERIO_V3
cd $UPPERIO_V3
go build && go install
```

### Supported databases

See the [adapters](/db.v3/adapters) for the complete list of supported
adapters.

## Basic usage

In order to use `db` efficiently you can follow some recommended patterns:

1. This is not a full-featured ORM, make sure you understand the database
   you're working with.
1. Use Go structs to describe data models. One struct per table is a common
   thing.
1. Try to use the collection / result set model first.
1. When in doubt, use the query builder or plain SQL.

### Mapping tables to structs

Add a `db` struct tag next to an *exported field* to map that field to a table
column:

```go
type Person struct {
  ID       uint64 `db:"id,omitempty"` // Use `omitempty` to prevent
                                      // the adapter from sending
                                      // this value if it's zero.
  Name     string `db:"name"`
  LastName string `db:"last_name"`
}
```

You can safely mix `db` struct tags with other struct tags, such as those used
to map JSON:

```go
type Person struct {
  ID        uint64 `db:"id,omitempty" json:"id"`
  Name      string `db:"name" json:"name"`
  ...
  Password  string `db:"password,omitempty" json:"-"`
}
```

If you want the adapter to ignore a field completely, set a hyphen (`-`) as its
name:

```go
type Person struct {
  ...
  Token    string `db:"-"` // The adapter will skip this field.
}
```

Note that if you don't provide explicit mappings the adapter will try to use
the field name with a case-sensitive lookup.

### Other mappings: Using JSON on PostgreSQL

The `postgresql` adapter supports saving and retrieving JSON data when using
[JSON types](https://www.postgresql.org/docs/9.4/static/datatype-json.html), if
you want to try this out, make sure your column is of `jsonb` type and that
you're using the `jsonb` option when mapping your field:

```go
type Person struct {
  ...
  Properties  []string                `db:"properties,jsonb"`
  Meta        map[string]interface{}  `db:"meta,jsonb"`
}
```

JSON types area supported on PostgreSQL 9.4+.

### Setting up a database session

Import the adapter package into your application:

```go
import (
  "upper.io/db.v3/postgresql" // PostgreSQL package
)
```

All adapters include a `ConnectionURL` struct that you can use to create a DSN:

```go
var settings = postgresql.ConnectionURL{
  User:     "john",
  Password: "p4ss",
  Address:  "10.0.0.99",
  Database: "myprojectdb",
}

fmt.Printf("DSN: %s", settings) // settings.String() is a DSN
```

You can use the `settings` value to create a database session by passing it to
the `Open()` function of your adapter:

```go
sess, err = postgresql.Open(settings)
...
```

This `sess` variable is a `db.Database` type.

One important `db.Database` method is `Collection()`, use it to get a
collection reference.

```go
users = sess.Collection("users") // A reference to the users table.
...
```

Once you're done with the database session, you must use the `Close()` method
on it to close and free all associated resources:

```go
err = sess.Close()
...
```

Note that Go servers are long-lived process, you may never need to manually
`Close()` a session unless you don't need it at all anymore.

### Inserting a new item into a collection

You can use the database session `sess` to get a collection reference and insert
a value into it:

```go
// Creates a value
person := Person{
  Name:     "Hedy",
  LastName: "Lamarr",
}

// Gets a collection reference
people  = sess.Collection("people")
...

// Inserts the value into the collection
id, err = people.Insert(person)
...

// Note that chaining works fine too
id, err = sess.Collection("people").Insert(person)
```

### Defining a result set with `Find()`

You can use `Find()` on a collection reference to get a result set from that
collection.

```go
// Find() with no conditions is a reference to all items
// on the collection:
res = sess.Collection("people").Find()
...

// You can use a `db.Cond` map to reduce the subset of
// items that will be queried:
res = sess.Collection("people").Find(db.Cond{
  "id": 25,
})

// On SQL databases a string-like syntax is also accepted:
res = sess.Collection("people").Find("id", 25)

// Equality is the default operator, but it's easy to use
// different operators:
res = sess.Collection("people").Find("id >", 29)

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

Use the `NewTx()` method on a session to create a transaction context:

```go
tx, err = sess.NewTx()
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
