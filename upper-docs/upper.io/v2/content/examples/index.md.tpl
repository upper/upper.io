# Examples and patterns

## Mapping structs to tables

The typical starting point with `db` is writing structs that define a mapping
between your Go application and the database it uses.

Struct fields can be mapped to table columns by using the `db` tag.

```go
type Whatever struct {
  FieldName `db:"column_name"`
}
```

Add the `omitempty` option to columns that are set to auto-increment themselves
on INSERT if no value was set, like IDs.

```go
type Employee struct {
  ID         uint64         `db:"id,omitempty"` // `omitempty` skips ID when zero
  FirstName  sql.NullString `db:"first_name"`
  LastName   string         `db:"last_name"`
}
```

This will make `db` skip the ID field on insertion if its value is zero.

<div>
<textarea class="go-playground-snippet" data-title="Example: A list of employees">{{ include "webroot/examples/mapping-employees/main.go" }}</textarea>
</div>

<div>
<textarea class="go-playground-snippet" data-title="Example: Get the employee with a NULL name.">{{ include "webroot/examples/mapping-employees-null-field/main.go" }}</textarea>
</div>

`db` converts from database format to the expected Go type when possible:

```go
type Shipment struct {
  ID         int       `db:"id,omitempty"`
  CustomerID int       `db:"customer_id"`
  ISBN       string    `db:"isbn"`
  ShipDate   time.Time `db:"ship_date"` // Using a time value.
}
```

<div>
<textarea class="go-playground-snippet" data-title="Example: List all shipments from September 2001.">{{ include "webroot/examples/list-shipments/main.go" }}</textarea>
</div>

## Embedding structs

With the `inline` option you can embed a common struct, like this one:

```go
type Person struct {
  FirstName string `db:"first_name"`
  LastName  string `db:"last_name"`
}
```

Into different structs that share the same column names, like these:

```go
type Author struct {
  ID     int `db:"id"`
  Person `db:",inline"` // Embedded Person
}

type Employee struct {
  ID     int `db:"id"`
  Person `db:",inline"` // Embedded Person
}
```

<div>
<textarea class="go-playground-snippet" data-title="Example: Embedding Person into Author and Employee.">{{ include "webroot/examples/embedded-structs/main.go" }}</textarea>
</div>

You can embed more than one struct into the same parent struct, but you should
be careful with ambiguities:

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

Embedding these two structs will cause a conflict of IDs, to solve this
conflict you can add an extra `book_id` column name and use a `book_id` alias
when querying for the book ID.

```go
// BookAuthor
type BookAuthor struct {
  // Both Author and Book have and ID column, we need this extra field to tell
  // the ID of the book from that of the author.
  BookID int `db:"book_id"`

  Author `db:",inline"`
  Book   `db:",inline"`
}
```

<div>
<textarea class="go-playground-snippet" data-title="Example: Embedding many structs and solving ambiguities.">{{ include "webroot/examples/embedded-structs-join/main.go" }}</textarea>
</div>

## Connecting to a database

### Using the `ConnectionURL` struct that comes with every adapter

```go
import (
  ...
  "upper.io/db.v2"            // Imports the main db package.
  "upper.io/db.v2/postgresql" // Imports the postgresql adapter.
  ...
)

// This ConnectionURL defines how to connect to this database.
var settings = postgresql.ConnectionURL{
  Database: `booktown`, // Database name.
  Address:  db.ParseAddress(`demo.upper.io`),
  User:     `demouser`, // Database username.
  Password: `demop4ss`, // Database password.
}

...
sess, err := db.Open("postgresql", settings)
...

log.Println("Now you're connected to the database!")
```

<div>
<textarea class="go-playground-snippet" data-title="Example: Connecting to a database.">{{ include "webroot/examples/open/main.go" }}</textarea>
</div>

### Using a DSN string

It is also possible to convert from a DSN
(`[adapter]://[user]:[password]@[host]/[database]`) into a settings struct and
use it to connect to a database:

```go
import (
  ...
  "upper.io/db.v2"            // Imports the main db package.
  "upper.io/db.v2/postgresql" // Imports the postgresql adapter.
  ...
)

const connectDSN = `postgres://demouser:demop4ss@demo.upper.io/booktown`

settings, err := postgresql.ParseURL(connectDSN)
...

sess, err := db.Open("postgresql", settings)
...

log.Println("Now you're connected to the database!")
```

<div>
<textarea class="go-playground-snippet" data-title="Example: Connecting to a database using a DSN.">{{ include "webroot/examples/open-with-dsn/main.go" }}</textarea>
</div>

Different databases may have different ways of connecting to or openning a
database, some databases like SQLite do not have a server concept. Please
refect to the adapter page to see such particularities.

## What are collections?

Collections are sets of items of a particular kind, if we are talking on a SQL
context any table can be seen as a collection.

### Using the `Collection()` method

The `db.Session.Collection()` method takes a collection (or SQL table) name and
returns an object that you can use at any point after to refer to that
collection.

```go
col, err := sess.Collection("accounts")
...
res = col.Find(...)
...
```

`Collection()` returns an error if the collection does not exist or if it can
not be read from some reason.

### Using the `C()` method

The `db.Session.C()` method is like `db.Session.Collection()` except that it caches
the table reference and panics if the collection does not exist. Use with care.

```go
res = sess.C("accounts").Find(...)
...
```

## Creating a result set

Use the `db.Collection.Find()` method on a collection reference to create a
result set:

```go
col, err = sess.C("accounts")
...

// All rows on "accounts"
res = col.Find()

// Rows on "accounts" that match "id = 11"
res = col.Find(db.Cond{"id": 11})

// Same as above, but shorter and only for SQL databases.
res = col.Find("id = ?", 11)
```

## Conditions

The `db.Cond{}` map can be used to express simple conditions to add constraints
to result sets:

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
res = col.Find(db.Cond{"last_name IS": nil})

// SQL: "last_name" IS NOT NULL
res = col.Find(db.Cond{"last_name IS NOT": nil})

// SQL: "last_name" LIKE "Smi%"
res = col.Find(db.Cond{"last_name LIKE": "Smi%"})
```

When using SQL adapters, conditions can also be expressed in
string-plus-arguments form: use a SQL string as first argument and the list of
arguments follows.

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
properly escaped before being placed.

## Counting elements on a result set

Use the `Count()` method on a result set to count the number of elements on it:

```go
var cond db.Cond = ...
res = col.Find(cond)
...

total, err := res.Count()
...
```

<div>
<textarea class="go-playground-snippet" data-title="Example: Counting books">{{ include "webroot/examples/count-books/main.go" }}</textarea>
</div>

## Inserting an element into the collection

Use the `Append()` method on a collection reference to insert an new row:

```go
account := Account{
  // Make sure you're using the omitempty option on IDs.
  ID          uint64 `db:"id,omitempty"`
  Department  string `db:"department"`
  ...
}

newID, err = col.Append(account)
...

log.Printf("Created element with ID %d", newID.(uint64))
```

In some cases using a map could be more convenient:

```go
newID, err = col.Append(map[string]interface{}{
  "name":      "Elizabeth",
  "last_name": "Smith",
  ...,
})
...
```

However, it is recommended to stick to using structs as much as possible.

## Mapping result sets to Go values

### Mapping all results at once

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

You can use `Limit()` and `Skip()` to adjust the number of results to be
passed:

```
// LIMIT 5 OFFSET 2
err = res.Limit(5).Skip(2).All(&customers)
```

And `Sort()` to define ordering:

```
err = res.Limit(5).Skip(2).Sort("name").All(&customers)
```

Note that there is no need to `Close()` the result set when using `All()` as it
is closed automatically.

<div>
<textarea class="go-playground-snippet" data-title="Example: Dump all books into a slice.">{{ include "webroot/examples/find-map-all-books/main.go" }}</textarea>
</div>

### Mapping one result

If you expect or need only one element from the result set use `One()` instead:

```go
var account Customer
err = res.One(&account)
```

All the other options for `All()` work with `One()`:

```
err = res.Skip(2).Sort("-name").One(&account)
```

As with `All()` there is also no need to `Close()` the result set when using
`One()`.

<div>
<textarea class="go-playground-snippet" data-title="Example: Search for one book.">{{ include "webroot/examples/find-map-one-book/main.go" }}</textarea>
</div>

### Mapping results one by one, for large result sets

If your result set is too large for being just dumped into an slice without
wasting a lot of memory you can also fetch one by one using `Next()` on a
result set:

```go
res := sess.C("customers").Find().Sort("last_name")
defer res.Close()

for {
  var customer Customer
  if err := res.Next(&customer); err != nil {
    if err != db.ErrNoMoreRows {
      log.Fatal(err)
    }
    // Loop until db.ErrNoMoreRows is returned.
    break
  }
  log.Printf("%d: %s, %s\n", customer.ID, customer.LastName, customer.FirstName)
}
```

All the other options for `All()` work with `Next()`:

When using `Next()` you are the only one that knows when to stop, so you'll
have to `Close()` the result set after finishing using it.

<div>
<textarea class="go-playground-snippet" data-title="Example: Search for one book.">{{ include "webroot/examples/find-map-one-by-one/main.go" }}</textarea>
</div>

## Updating a result set

Update rows by using the `db.Result.Update()` method.

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
whether it is one element or many.


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

If you only want to update a column and nothing else, you can also use a map:

```go
res = col.Find("id", 5)
...

err = res.Update(map[string]interface{}{
  "last_login": time.Now(),
})
...
```

## Deleting a result set

Use `Remove()` on a result set to remove all the elements that match the
conditions given to `Find()`.

```go
res = col.Find("id", 4)
err = res.Remove()
...

res = col.Find("id >", 8)
err = res.Remove()
...

res = col.Find("id IN", []int{1, 2, 3, 4})
err = res.Remove()
...
```

## Transactions

Request a transaction session with the `Transaction()` method on a normal
database session:

```go
tx, err := sess.Transaction()
...
```

Use `tx` as you would normally use `sess`:

```go
_, err = tx.C("accounts").Append(...)
...

res = tx.C("accounts").Find(...)

err = res.Update(...)
...

```

The difference from `sess` is that at the end you'll have to either commit or
roll back the operations:

```go
err = tx.Commit() // or tx.Rollback()
...
```

There is no need to `Close()` the transaction, after commiting or rolling back
the transaction gets closed and it's no longer valid.

<div>
<textarea class="go-playground-snippet" data-title="Example: A simple transaction.">{{ include "webroot/examples/simple-transaction/main.go" }}</textarea>
</div>

## The SQL builder

`db` comes with a very powerful query builder, use the `Builder()` on a
database session to get a builder reference:

```go
b := sess.Builder()
```

Builder provides a new set of methods that work on SQL databases:

```go
q := b.SelectAllFrom("accounts")
...

q := b.Select("id", "last_name").From("accounts")
...

q := b.SelectAllFrom("accounts").Where("last_name LIKE ?", "Smi%")
...
```

And some of the convenient methods we expect from `db`:

```go
var accounts []Account
err = q.All(&accounts)
...
```

Using the query builder you can express complex queries:

```go
q = b.Select("id", "name").From("accounts").
  Where("last_name = ?", "Smith").
  OrderBy("name").Limit(10)
```

Even SQL-specific features, like joins, are supported (still depends on the database, though):

```go
q = b.Select("a.name").From("accounts AS a").
  Join("profiles AS p").
  On("p.account_id = a.id")

q = b.Select("name").From("accounts").
  Join("owners").
  Using("employee_id")
```

Sometimes the builder won't be able to represent complex queries, if this
happens it may be more effective to use plain SQL:

```go
rows, err = b.Query(`SELECT * FROM accounts WHERE id = ?`, 5)
...

row, err = b.QueryRow(`SELECT * FROM accounts WHERE id = ? LIMIT ?`, 5, 1)
...

res, err = b.Exec(`DELETE FROM accounts WHERE id = ?`, 5)
...
```

Mapping results from raw queries is also really easy:

```go
rows, err = b.Query(`SELECT * FROM accounts WHERE last_name = ?`, "Smith")
...
var accounts []Account
iter := sqlbuilder.NewIterator(rows)
iter.All(&accounts)
...
```

See [builder examples][2] to learn how to master the query builder.

## Add or request an example

It would be awesome if you want to fix an error or add a new example, please
refer to the [contributions][3] to learn how to do so.

[1]: /db.v2/getting-started
[2]: /db.v2/builder
[3]: /db.v2/contribute
