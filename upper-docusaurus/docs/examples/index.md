# Examples and patterns

# Key concepts

A **session** is a database context created with the `Open()` function featured
in the adapter package.

A **collection** is a set of items that belong to a SQL _table_ or a NoSQL
_collection_.

> The term 'collection' is used indistinctively by methods that work on both
> SQL and NoSQL databases.

A **result set** is a subset of items in a collection that match specific
conditions. It is retrieved with `Find()`. The whole result set can be
delimited or modified through different methods, like `Update()`, `Delete()`,
`Insert()`, `All()`, or `One()`.

The figure below ilustrates the session, collection, and result set concepts:

// TODO: add example
<center>
![Collections](/db.v3/res/collection.png)
</center>

# SQL/NoSQL Considerations

In order to use `upper/db` efficiently, it is advisable that you:

1. Understand the database you're working with (relational or
   document-oriented)
1. Use Go structs to describe data models. One struct per collection is a good
   practice.
1. Try to use `db.Collection` methods applicable to both SQL and NoSQL first.
1. Use the SQL builder or raw SQL only when needed.


## Collection Reference

Use the session you created to get a `db.Collection` reference (SQL table or
NoSQL collection):

```go
// Reference to a table/collection named "people"
people := sess.Collection("people")
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

You can also set the adapter to ignore specific fields by means of a hyphen
(`-`):

```go
type Person struct {
  ...
  Token    string `db:"-"` // Field to be skipped
}
```

> If mapping is not explicit, the adapter will perform a case-sensitive lookup
> of field names.

# CRUD Functions

## Retrieval

Get specific pieces of information (result sets) using `Find()`:

```go
// Requesting all items in the "people" collection
res := sess.Collection("people").Find()
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

You can determine the number of items you want to go through using `Offset()`
and `Limit()`:

```go
res = col.Find(...)
...


// The result set will consist of 8 items and skip the first 2 rows.
err = res.Offset(2).
  Limit(8).
  All(&accounts)
...
```

Results can also be sorted according to a given value with `OrderBy()`:

```go
res := col.Find(...)
...

// Descending order by `last_name`
err = res.OrderBy("-last_name").All(&accounts)
...
```

> Remember that the total number of items in a result set can be calculated
> with `Count()`:

```go
res = col.Find(...)
...

count, err = res.Count()
...

fmt.Printf("There are %d items in the result set", count)
```

> `Limit()`, `Offset()`, and `OrderBy()` affect exclusively the `All()`
> and `One()` methods.

## Creation, Update, and Deletion

Insert, modify, and remove items in the result set.

To get the full picture on how to perform all CRUD tasks (starting right from
the installation and setup steps), take the upper-db
[tour](https://tour.upper.io/welcome/01).

> The methods related to sessions, collections, and result sets are exemplified
> using the approaches 'SQL/NoSQL' and 'SQL only'. For further reference about
> what applies in each case, click [here](https://upper.io/db.v3/examples).

# Tips and tricks

## Logging

`upper/db` can be set to print SQL statements and errors to standard output
through the `UPPERIO_DB_DEBUG` environment variable:

```console
UPPERIO_DB_DEBUG=1 ./go-program
// TODO: add example
```

## Underlying driver

In case you require methods that are only available from the underlying driver,
you can use the `db.Database.Driver()` method, which returns an `interface{}`.
For instance, if you need the
[mgo.Session.Ping](http://godoc.org/labix.org/v2/mgo#Session.Ping) method, you
can retrieve the underlying `*mgo.Session` as an `interface{}`, cast it into
the appropriate type, and use `Ping()`, as shown below:

```go
drv = sess.Driver().(*mgo.Session) // The driver is cast into the
                                   // the appropriate type.
err = drv.Ping()
```

You can do the same when working with an SQL adapter by changing the casting:

```go
drv = sess.Driver().(*sql.DB)
rows, err = drv.Query("SELECT name FROM users WHERE age = ?", age)
```

# License (MIT)

> Copyright (c) 2013-today The upper/db authors.
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
[3]: /db/mysql
[4]: /db/postgresql
[5]: /db/sqlite
[6]: /db/ql
[7]: /db/mongo
[8]: /db/mssql

This is a small list of the most essential examples on how to work with `upper/db`.

## Mapping structs to tables

The typical starting point with `upper/db` is writing Go structs that define a
mapping between your Go application and the database it uses.

Struct fields can be mapped to table columns by using a special `db` tag:

```go
type User struct {
  Name `db:"name"`
}
```

add the `omitempty` tag option to struct fields that you don't want to send to
the database if they don't have a value, like IDs that are set to
auto-increment (or auto-generate) themselves:

```go
type Employee struct {
  ID         uint64         `db:"id,omitempty"` // Skip `id` column when zero.
  FirstName  sql.NullString `db:"first_name"`
  LastName   string         `db:"last_name"`
}
```

### Example: Show all employees

<div>
<textarea class="go-playground-snippet" data-title="Live example: A list of employees">
</textarea>
</div>

### Example: Find an employee without a last name

<div>
<textarea class="go-playground-snippet" data-title="Live example: Find an employee without a last name">
</textarea>
</div>

`upper/db` takes care of type conversions between the database and Go:

```go
type Shipment struct {
  ID         int       `db:"id,omitempty"`
  CustomerID int       `db:"customer_id"`
  ISBN       string    `db:"isbn"`
  ShipDate   time.Time `db:"ship_date"` // Time values just work.
}
```

### Example: List all shipments from September 2001

<div>
<textarea class="go-playground-snippet" data-title="Live example: List all shipments from September 2001">
</textarea>
</div>

### Embedding structs

Using the `inline` option you can embed structs into other structs. See this
`Person` struct, for instance:

```go
type Person struct {
  FirstName string `db:"first_name"`
  LastName  string `db:"last_name"`
}
```

This is a common struct that can be shared with other structs which also need
`FirstName` and `LastName`:

```go
type Author struct {
  ID     int  `db:"id,omitempty"`

  Person      `db:",inline"` // Embedded Person
}

type Employee struct {
  ID     int  `db:"id,omitempty"`

  Person      `db:",inline"` // Embedded Person
}
```

### Example: Embedding `Person` struct into `Author` and `Employee`

<div>
<textarea class="go-playground-snippet" data-title="Live example: Embedding Person into Author and Employee">
{{ include "webroot/examples/embedded-structs/main.go" }}
</textarea>
</div>

This will work as long as you use the `db:",inline"` tag. You can even embed
more than one struct into another, but you should be careful with column
ambiguities:

```go
// Book that has ID.
type Book struct {
  ID        int    `db:"id"` // Has an ID column.
  Title     string `db:"title"`
  AuthorID  int    `db:"author_id"`
  SubjectID int    `db:"subject_id"`
}

// Author that has ID.
type Author struct {
  ID        int    `db:"id"` // Also has an ID column.
  LastName  string `db:"last_name"`
  FirstName string `db:"first_name"`
}
```

Embedding these two structs into a third one will cause a conflict of IDs, to
solve this conflict you can add an extra `book_id` column mapping and use a
`book_id` alias when querying for the book ID.

```go
// BookAuthor
type BookAuthor struct {
  // Both Author and Book have and ID column, we need this extra field to tell
  // the difference between the ID of the book and the ID of the author.
  BookID int `db:"book_id"`

  Author `db:",inline"`
  Book   `db:",inline"`
}
```

### Example: Solving ambiguities with aliases

<div>
<textarea class="go-playground-snippet" data-title="Live example: Solving ambiguities with aliases">{{ include "webroot/examples/embedded-structs-join/main.go" }}</textarea>
</div>

## Connecting to a database

All adapters come with a `ConnectionURL` struct that you can use to describe
parameters to open a database:

```go
import (
  ...
  "github.com/upper/db/postgresql"
  ...
)

// This ConnectionURL defines how to connect to a PostgreSQL database.
var settings = postgresql.ConnectionURL{
  Database: `booktown`,
  Host:     `localhost`,
  User:     `demouser`,
  Password: `demop4ss`,
}

```

also, every adapter comes with an `Open()` function that takes a
`ConnectionURL` and attempts to create a database session:

```
...
sess, err := postgresql.Open(settings)
...

log.Println("Now you're connected to the database!")
```

### Example: Connecting to a database

<div>
<textarea class="go-playground-snippet" data-title="Live example: Connecting to a database.">{{ include "webroot/examples/open/main.go" }}</textarea>
</div>

It is also possible to use a DSN
(`[adapter]://[user]:[password]@[host]/[database]`), you can easily convert it
into a `ConnectionURL` struct and use it to connect to a database by using the
`ParseURL` function from your adapter:

```go
import (
  ...
  "github.com/upper/db/postgresql"
  ...
)

const connectDSN = `postgres://demouser:demop4ss@demo.upper.io/booktown`

// Convert the DSN into a ConnectionURL
settings, err := postgresql.ParseURL(connectDSN)
...

// And use it to connect to your database.
sess, err := postgresql.Open(settings)
...

log.Println("Now you're connected to the database!")
```

### Example: Connecting to a database using a DSN

<div>
<textarea class="go-playground-snippet" data-title="Live example: Connecting to a database using a DSN.">{{ include "webroot/examples/open-with-dsn/main.go" }}</textarea>
</div>

Different databases may have different ways of connecting to a database server
or openning a database file, some databases like SQLite do not have a server
concept and they just use files. Please refer to the page of the adapter you're
using to see such particularities.

## Collections and tables

Collections are sets of items of a particular kind. In order to make it easier
to work with concepts from both SQL and NoSQL databases, `upper/db` refers to
both NoSQL collections and SQL tables as "collections".

### Using the `Collection()` method

The `Collection()` method of a session takes a collection name and returns an
reference that you can use to do simple operations on that collection:

```go
col := sess.Collection("accounts")
...

res = col.Find(...)
...

err := res.All(&items)
...
```

## Insert

### Inserting an element into a collection

Use the `Insert()` method on a collection reference to insert an new item, just
pass a struct value:

```go
account := Account{
  Name: "Eliza",
  LastName: "Smith",
  ...
}

newID, err := col.Insert(account)
...

log.Printf("Created element with ID %v", newID)
```

You can also use maps to insert new items:

```go
newID, err := col.Insert(map[string]interface{}{
  "name":      "Elizabeth",
  "last_name": "Smith",
  ...,
})
...
```

### Inserting elements with the SQL builder

If you rather not use collections, you can also use Go with a SQLish syntax to
[insert](/db/lib/sqlbuilder#insert-statement) elements:

```
q = sess.InsertInto("people").
  Columns("name").
  Values("John")

res, err := q.Exec() // res is a sql.Result
...
```

This SQLish syntax is only available on SQL adapters. See [INSERT
statement](/db.v3/lib/sqlbuilder#insert-statement).

## Result sets

A result set is a subset of items from a collection. If you have a collection
reference, you can create a result set by using the `Find()` method:

```go
col = sess.Collection("accounts")
...

// Using Find with no arguments creates a result set containing all items
// in `col`.
res = col.Find()
...
err = res.All(&items)
...

// This other result set has a constraint, only items with id = 11 will be part
// of the result set.
res = col.Find(db.Cond{"id": 11})
...
err = res.One(&item)
...

// This Find() does the same as above with a shorter syntax only supported by
// SQL adapters.
res = col.Find("id", 11)
...
err = res.Delete()
...
```

A result set reference provides simple operations like `All()`, `One()`,
`Delete()` and `Update()` that allow you to work easily with all the items that
belong to the result set.

## Retrieving items

### Mapping all results from a result set

If you're dealing with a relatively small number of items, you may want to dump
them all at once, use the `All()` method on a result set to do so:

```go
var customers []Customer

// A result set can be mapped into an slice of structs
err = res.All(&customers)

// Or into a map
var customers map[string]interface{}
err = res.All(&customers)
```

You can chain `Limit()` and `Offset()` to a result set in order to adjust the
number of results to be mapped:

```
// LIMIT 5 OFFSET 2
err = res.Limit(5).Offset(2).All(&customers)
```

you can also use `OrderBy()` to define ordering:

```
q := res.Limit(5).
  Offset(2).
  OrderBy("name").

err := q.All(&customers)
```

Note that the result set is not reduced when using `Limit()`, `Offset()` or
`OrderBy()`, the only thing that is reduced is the number of elements mapped by
`All()`.

There is no need to `Close()` the result set when using `All()`, it's closed
automatically.

<div>
<textarea class="go-playground-snippet" data-title="Live example: Dump all books into a slice.">{{ include "webroot/examples/find-map-all-books/main.go" }}</textarea>
</div>

### Mapping only one result

If you expect or need only one element from the result set use `One()` instead
of `All()`:

```go
var account Customer
err = res.One(&account)
```

All the other options for `All()` work with `One()`:

```
err = res.Offset(2).OrderBy("-name").One(&account)
```

As with `All()` there is also no need to `Close()` the result set after using
`One()`.

<div>
<textarea class="go-playground-snippet" data-title="Live example: Search for one book.">{{ include "webroot/examples/find-map-one-book/main.go" }}</textarea>
</div>

### Mapping large result sets

If your result set is too large for being just dumped into an slice without
wasting a lot of memory, you can also fetch one by one using `Next()` on a
result set:

```go
res := sess.Collection("customers").Find().OrderBy("last_name")
defer res.Close() // Remember to close the result set!

var customer Customer
for res.Next(&customer) {
  log.Printf("%d: %s, %s\n", customer.ID, customer.LastName, customer.FirstName)
}
```

All the other chaining methods for `All()` and `One()` work with `Next()`:

When using `Next()` you are the only one that knows when you're done reading
the result set, so you'll have to `Close()` the result set manually after
finishing using it.

<div>
<textarea class="go-playground-snippet" data-title="Live example: Search for one book.">{{ include "webroot/examples/find-map-one-by-one/main.go" }}</textarea>
</div>

## Update

### Updating a result set

You can update all rows on the result set with the `Update()` method.

```go
var account Account
res = col.Find("id", 5) // WHERE id = 5

err = res.One(account)
...

account.Name = "New name"
...

err = res.Update(account)
...
```

`Update()` affects all elements that match the conditions given to `Find()`,
whether it is just one or many elements.

It is not necessary to pull the element before updating it, this would work as
well:

```go
res = col.Find("id", 5) // WHERE id = 5
...

err = res.Update(Account{
  Name: "New name",
})
...
```

Please note that all the struct fields without a value will be sent to the
database as if they were empty (because they are). If you rather skip empty
fields remember to use the `omitempty` option on them.

```
type Account struct {
  ID uint `db:"id,omitempty"`
}
```

You can also use maps to define an update:

```go
res = col.Find("id", 5)
...

err = res.Update(map[string]interface{}{
  "last_login": time.Now(),
})
...
```

### Updating with the SQL builder

See [UPDATE statement](/db.v3/lib/sqlbuilder#update-statement):

```
q = sess.Update("people").Set("name", "John").Where("id = ?", 5)

res, err = q.Exec()
...
```

## Delete

### Deleting all items from a result set

Use `Delete()` on a result set to remove all the elements on the result set.

```go
// Delete elements in `col` with id equals 4
res = col.Find("id", 4)
err = res.Delete()
...

// Delelte elements in `col` with id greater than 8
res = col.Find("id >", 8)
err = res.Delete()
...

// Delete items in `col` with id 1 or 2 or 3 or 4
res = col.Find("id IN", []int{1, 2, 3, 4})
err = res.Delete()
...
```

### Deleting with the SQL builder

See [DELETE statement](/db.v3/lib/sqlbuilder#delete-statement):

```go
q = sess.DeleteFrom("accounts").Where("id", 5)

res, err = q.Exec()
...
```

## Count

### Counting elements on a result set

Use the `Count()` method on a result set to count the number of elements on it:

```go
var cond db.Cond = ...
res = col.Find(cond)
...

total, err := res.Count()
...
```

<div>
<textarea class="go-playground-snippet" data-title="Live example: Counting books">{{ include "webroot/examples/count-books/main.go" }}</textarea>
</div>

## Conditions

### Constraining result sets

The `db.Cond{}` map can be used to add constraints to result sets:

```go
// Rows that match "id = 5"
res = col.Find(db.Cond{"id": 5})

// Rows that match "age > 21"
ageCond = db.Cond{
  "age >": 21,
}
res = col.Find(ageCond)

// All rows that match name != "Joanna", only for SQL databases.
res = col.Find(db.Cond{"name != ?": "Joanna"})

// Same as above, but shorter.
res = col.Find(db.Cond{"name !=": "Joanna"})
```

`db.Cond{}` can also be used to express conditions that require special
escaping or custom operators:

```go
// SQL: "id" IN (1, 2, 3, 4)
res = col.Find(db.Cond{"id": []int{1, 2, 3, 4}})

// SQL: "id" NOT IN (1, 2, 3, 4)
res = col.Find(db.Cond{"id NOT IN": []int{1, 2, 3, 4}})

// SQL: "last_name" IS NULL
res = col.Find(db.Cond{"last_name": nil})

// SQL: "last_name" IS NOT NULL
res = col.Find(db.Cond{"last_name IS NOT": nil})

// SQL: "last_name" LIKE "Smi%"
res = col.Find(db.Cond{"last_name LIKE": "Smi%"})
```

When using SQL adapters, conditions can also be expressed in string form, the
first argument to `Find()` is a string that is followed by a list of arguments:

```go
// These two lines are equivalent.
res = col.Find("id = ?", 5)
res = col.Find("id", 5) // Means equality by default

// These two as well.
res = col.Find("id > ?", 5)
res = col.Find("id >", 5) // Explicitly using the > comparison operator.

// The placeholder can be omitted when we only have one argument at the end
// of the statement.
res = col.Find("id IN ?", []int{1, 2, 3, 4})
res = col.Find("id IN", []int{1, 2, 3, 4})

// We can't omit placeholders if the argument is not at the end or when we
// expect more than one argument.
res = col.Find("id = ?::integer", "23")

// You can express complex statements as well.
var pattern string = ...
res = col.Find("MATCH(name) AGAINST(? IN BOOLEAN MODE)", pattern)
```

The `?` symbol represents a placeholder for an argument that needs to be
properly escaped, there's no need to provide numbered placeholders like `$1`,
`$2` as `?` placeholders will be transformed to the format the database driver
expects before building a query.

## Transactions

Transactions are special operations that you can carry out with the guarantee
that if one fails the whole batch fails. The typical example on transactions is
a bank operation in which you want to move money from one account to another
without worrying about a power failure or a write error in the middle of a
transaction that would create an inconsistency.

You can create and use transaction blocks with the `Tx` method:

```go
import (
  "context"
  "log"

  "github.com/upper/db"
  "github.com/upper/db/pkg/sqlbuilder"
)

func main() {
  ...
  // The first argument for `Tx()` is either `nil` or a `context.Context` type.
  // Use `db.DefaultContext` if you want the session's default context to be
  // used.
  err := sess.Tx(context.Background(), func(tx sqlbuilder.Tx) error {
    // Use `tx` like you would normally use `sess`.
    ...
    id, err := tx.Collection("accounts").Insert(...)
    if err != nil {
      // Rollback the transaction by returning an error value.
      return err
    }
    ...
    rows, err := tx.Query(...)
    ...

    ...
    // Commit the transaction by returning `nil`.
    return nil
  })
  if err != nil {
    log.Fatal("Transaction failed: ", err)
  }
}
```

If you want to know more about the context Tx requires see:
https://golang.org/pkg/context/

### Manual transactions

Alternatively, you can also request a transaction context and manage it
yourself using the `NewTx` method:

```go
tx, err := sess.NewTx(ctx)
...
```

Use `tx` as you would normally use `sess`:

```go
id, err = tx.Collection("accounts").Insert(...)
...

res = tx.Collection("accounts").Find(...)

err = res.Update(...)
...

```

Remember that in order for your changes to be permanent, you'll have to use the
`Commit()` method:

```go
err = tx.Commit() // or tx.Rollback()
...
```

If you want to cancel the whole operation, use `Rollback()`.

There is no need to `Close()` the transaction, after commiting or rolling back
the transaction gets closed and it's no longer valid.

<div>
<textarea class="go-playground-snippet" data-title="Live example: A simple transaction.">{{ include "webroot/examples/simple-transaction/main.go" }}</textarea>
</div>

## Query logger

Use `UPPERIO_DB_DEBUG=1 ./program` to enable the built-in query logger, you'll
see the generated SQL queries and the result from their execution printed to
`stdout`.

```
2016/10/04 19:14:28
	Session ID:     00003
	Query:          SELECT "pg_attribute"."attname" AS "pkey" FROM "pg_index", "pg_class", "pg_attribute" WHERE ( pg_class.oid = '"option_types"'::regclass AND indrelid = pg_class.oid AND pg_attribute.attrelid = pg_class.oid AND pg_attribute.attnum = ANY(pg_index.indkey) AND indisprimary ) ORDER BY "pkey" ASC
	Time taken:     0.00314s

2016/10/04 19:14:28
	Session ID:     00003
	Query:          TRUNCATE TABLE "option_types" RESTART IDENTITY
	Rows affected:  0
	Time taken:     0.01813s

...
```

Besides the `UPPERIO_DB_DEBUG` env, you can enable or disable the built-in
query logger during runtime using `sess.SetLogging`:

```go
sess.SetLogging(true)
```

If you want to do something different with this log, such as reporting query
errors to a different system, you can also provide a custom logger:

```go
type customLogger struct {
}

func (*customLogger) Log(q *db.QueryStatus) {
  switch q.Err {
  case nil, db.ErrNoMoreRows:
    return // Don't log successful queries.
  }
  // Alert of any other error.
  loggingsystem.ReportError("Unexpected database error: %v\n%s", q.Err, q.String())
}
```

Use `sess.SetLogger` to overwrite the built-in logger:

```go
sess.SetLogging(true)
sess.SetLogger(&customLogger{})
```

If you want to restore the built-in logger set the logger to `nil`:

```go
sess.SetLogger(nil)
```

## SQL builder

The `Find()` method on a collection provides a compatibility layer between SQL
and NoSQL databases, but that might feel short in some situations. That's the
reason why SQL adapters also provide a powerful **SQL query builder**.

This is how you would create a query reference using the SQL builder on a
session:

```go
q := sess.SelectAllFrom("accounts")
...

q := sess.Select("id", "last_name").From("accounts")
...

q := sess.SelectAllFrom("accounts").Where("last_name LIKE ?", "Smi%")
...
```

A query reference also provides the `All()` and `One()` methods from `Result`:

```go
var accounts []Account
err = q.All(&accounts)
...
```

Using the query builder you can express simple queries:

```go
q = sess.Select("id", "name").From("accounts").
  Where("last_name = ?", "Smith").
  OrderBy("name").Limit(10)
```

But even SQL-specific features, like joins, are supported (still depends on the
database, though):

```go
q = sess.Select("a.name").From("accounts AS a").
  Join("profiles AS p").
  On("p.account_id = a.id")

q = sess.Select("name").From("accounts").
  Join("owners").
  Using("employee_id")
```

Sometimes the builder won't be able to represent complex queries, if this
happens it may be more effective to use plain SQL:

```go
rows, err = sess.Query(`SELECT * FROM accounts WHERE id = ?`, 5)
...

row, err = sess.QueryRow(`SELECT * FROM accounts WHERE id = ? LIMIT ?`, 5, 1)
...

res, err = sess.Exec(`DELETE FROM accounts WHERE id = ?`, 5)
...
```

Mapping results from raw queries is also straightforward:

```go
rows, err = sess.Query(`SELECT * FROM accounts WHERE last_name = ?`, "Smith")
...

var accounts []Account
iter := sqlbuilder.NewIterator(rows)
iter.All(&accounts)
...
```

See [builder examples][2] to learn how to master the SQL query builder.

[1]: /db.v3/getting-started
[2]: /db.v3/lib/sqlbuilder
[3]: /db.v3/contribute
