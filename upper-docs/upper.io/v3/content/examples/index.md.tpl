# Examples and patterns

This is a small list of the most essential examples on how to work with `db`.

## Mapping structs to tables

The typical starting point with `db` is writing structs that define a mapping
between your Go application and the database it uses.

Struct fields can be mapped to table columns by using a special `db` tag:

```go
type Whatever struct {
  FieldName `db:"column_name"`
}
```

add the `omitempty` tag option to struct fields that you don't want to send to
the database if they don't have a value, like IDs that are set to
auto-increment themselves:

```go
type Employee struct {
  ID         uint64         `db:"id,omitempty"` // `omitempty` skips ID when zero
  FirstName  sql.NullString `db:"first_name"`
  LastName   string         `db:"last_name"`
}
```

<div>
<textarea class="go-playground-snippet" data-title="Live example: A list of employees">{{ include "webroot/examples/mapping-employees/main.go" }}</textarea>
</div>

<div>
<textarea class="go-playground-snippet" data-title="Live example: Find an employee without a last name">{{ include "webroot/examples/mapping-employees-null-field/main.go" }}</textarea>
</div>

`db` takes care of type conversions between the database and Go:

```go
type Shipment struct {
  ID         int       `db:"id,omitempty"`
  CustomerID int       `db:"customer_id"`
  ISBN       string    `db:"isbn"`
  ShipDate   time.Time `db:"ship_date"` // Time values just work.
}
```

<div>
<textarea class="go-playground-snippet" data-title="Live example: List all shipments from September 2001">{{ include "webroot/examples/list-shipments/main.go" }}</textarea>
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
  ID     int  `db:"id"`
  Person      `db:",inline"` // Embedded Person
}

type Employee struct {
  ID     int  `db:"id"`
  Person      `db:",inline"` // Embedded Person
}
```

<div>
<textarea class="go-playground-snippet" data-title="Live example: Embedding Person into Author and Employee">{{ include "webroot/examples/embedded-structs/main.go" }}</textarea>
</div>

This will work as long as you use the `db:",inline"` tag. You can even embed
more than one struct into another, but you should be careful with ambiguities:

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
solve this conflict you can add an extra `book_id` column name and use a
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

<div>
<textarea class="go-playground-snippet" data-title="Live example: Solving ambiguities with aliases">{{ include "webroot/examples/embedded-structs-join/main.go" }}</textarea>
</div>

## Connecting to a database

All adapters come with a `ConnectionURL` struct that you can use to describe
parameters to open a database:

```go
import (
  ...
  "upper.io/db.v2/postgresql"
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
  "upper.io/db.v2/postgresql"
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

<div>
<textarea class="go-playground-snippet" data-title="Live example: Connecting to a database using a DSN.">{{ include "webroot/examples/open-with-dsn/main.go" }}</textarea>
</div>

Different databases may have different ways of connecting to or openning a
database, some databases like SQLite do not have a server concept and they just
use files. Please refer to the page of the adapter you're using to see such
particularities.

## Collections and tables

Collections are sets of items of a particular kind. In order to make it easier
to work with concepts from both SQL and NoSQL databases, `db` refers to both
NoSQL collections and SQL tables as "collections".

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
  // Make sure you're using the omitempty option on IDs.
  ID          uint64 `db:"id,omitempty"`
  Department  string `db:"department"`
  ...
}

newID, err = col.Insert(account)
...

log.Printf("Created element with ID %v", newID)
```

You can also use maps to insert new items:

```go
newID, err = col.Insert(map[string]interface{}{
  "name":      "Elizabeth",
  "last_name": "Smith",
  ...,
})
...
```

### Inserting elements with the SQL builder

If you rather not use collections, you can also use a SQLish syntax
to [insert](/db.v2/lib/sqlbuilder#insert-statement) elements:

```
q = sess.InsertInto("people").Columns("name").Values("John")

res, err = q.Exec() // res is a sql.Result
...
```

This SQLish syntax is only available on SQL adapters. See [INSERT
statement](/db.v2/lib/sqlbuilder#insert-statement).

## Result sets

A result set is a subset of items from a collection. If you have a collection
reference, you can create a result set by using the `Find()` method:

```go
col = sess.Collection("accounts")
...

// Using Find with no arguments creates a result set containing
// all items in `col`.
res = col.Find()
...
err = res.All(&items)
...

// This other result set has a constraint, only items with
// id = 11 will be part of the result set.
res = col.Find(db.Cond{"id": 11})
...
err = res.One(&item)
...

// This Find() does the same as above with a shorter syntax
// only supported by SQL adapters.
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
err = res.Limit(5).Offset(2).OrderBy("name").All(&customers)
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

If you expect or need only one element from the result set use `One()` instead of `All()`:

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

err = col.One(account)
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

See [UPDATE statement](/db.v2/lib/sqlbuilder#update-statement):

```
q = sess.Update("people").Set("name", "John").Where("id = ?", 5)

res, err = q.Exec()
...
```

## Delete

### Deleting all items from a result set

Use `Delete()` on a result set to remove all the elements on the result set/

```go
res = col.Find("id", 4)
err = res.Delete()
...

res = col.Find("id >", 8)
err = res.Delete()
...

res = col.Find("id IN", []int{1, 2, 3, 4})
err = res.Delete()
...
```

### Deleting with the SQL builder

See [DELETE statement](/db.v2/lib/sqlbuilder#delete-statement):

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
  "log"
  "upper.io/db.v2"
  "upper.io/db.v2/lib/sqlbuilder"
)

func main() {
  ...
  err := sess.Tx(func(tx sqlbuilder.Tx) error {
    // Use `tx` like you would normally use `sess`.
    ...
    id, err := tx.Collection("accounts").Insert(...)
    if err != nil {
      // Rollback the transaction by returning any error.
      return err
    }
    ...
    rows, err := tx.Query(...)
    ...

    ...
    // Commit the transaction by returning nil.
    return nil
  })
  if err != nil {
    log.Fatal("Transaction failed: ", err)
  }
}
```


### Manual transactions

Alternatively, you can also request a transaction context and manage it
yourself using the `NewTx()` method:

```go
tx, err := sess.NewTx()
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

2016/10/04 19:14:28
	Session ID:     00003
	Query:          INSERT INTO "option_types" ("name", "settings", "tags") VALUES ($1, $2, $3) RETURNING "id"
	Arguments:      []interface {}{"Hi", sqlbuilder.jsonbType{V:postgresql.Settings{Name:"a", Num:123}}, sqlbuilder.stringArray{"aah", "ok"}}
	Time taken:     0.00202s
```

Besides the `UPPERIO_DB_DEBUG` env, you can enable or disable the built-in
query logger during runtime using `db.Conf.SetLogging`:

```go
db.Conf.SetLogging(true)
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

Use `db.Conf.SetLogger` to overwrite the built-in logger:

```go
db.Conf.SetLogging(true)
db.Conf.SetLogger(&customLogger{})
```

If you want to restore the built-in logger set the logger to `nil`:

```go
db.Conf.SetLogger(nil)
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

But even SQL-specific features, like joins, are supported (still depends on the database, though):

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

[1]: /db.v2/getting-started
[2]: /db.v2/lib/sqlbuilder
[3]: /db.v2/contribute
