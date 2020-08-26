---
title: Agnostic data API
---

The `db` package provides an **agnostic Go API** focused on working with
collections of items. This API is modelled after basic set theory concepts that
are applicable to relational and document-based database engines alike.

Using `db` you can [create a database
session](/v4/getting-started/connect-to-a-database) and use all of the
[`db.Session`
methods](https://pkg.go.dev/github.com/upper/db/v4?tab=doc#Session).

The `Collection()` method of `db.Session` takes a collection name and returns
an reference that you can use to do simple operations on that collection:

```go
// Reference to a table/collection named "people"
people := sess.Collection("people")
...

log.Printf("The name of the collection is: %s", people.Name())
```

> Collections are sets of items of a particular kind. In order to make it
> easier to work with concepts from both SQL and NoSQL databases, `upper/db`
> refers to both NoSQL collections and SQL tables as "collections".

The example below demonstrates how to explore all collections in the database
and create collection references:

$$
package main

import (
  "fmt"
	"log"

	"github.com/upper/db/v4/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: "booktown",
	Host:     "demo.upper.io",
	User:     "demouser",
	Password: "demop4ss",
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	// Retrieve the names of all the collections.
	collections, err := sess.Collections()
	if err != nil {
		log.Fatal("Collections: ", err)
	}

	// Iterate over the names of all the collections and get collection
	// references.
	for _, collection := range collections {
		fmt.Printf("Collection: %q\n", collection.Name())
	}
}
$$

## Working with collections (CRUD)

### Find

A result-set is a subset of items from a collection. If you have a collection
reference you can create a result set by using the `Find()` method:

```go
// Collection reference
col := sess.Collection("people")

// Requesting all items in the "people" collection
res := col.Find()
...

// String-like syntax is accepted.
res = col.Find("id", 25)

// Equality is the default operator but a different one can be used.
res = col.Find("id >", 29)

// The `?` placeholder maps arguments by order.
res = col.Find("id > ? AND id < ?", 20, 39)

// You can add more conditions to `Find()` with `And()`
res = col.Find("id >", 20).And("id <", 39)

// Primary keys can also be passed as arguments.
res = col.Find(20)
```

A result-set reference provides simple operations like `All()`, `One()`,
`Delete()` and `Update()` that allow you to work easily with all the items that
belong to the result set.

Use `All()` on result-sets to retrieve and map all the results into a slice:

```
var users []User

err := res.All(&users)
...
```

Or `One` to retrieve and map only one element:

```
var user User

err := res.One(&user)
...
```

Using `Find()` with no arguments creates a result set containing all items in
the collection.

```go
res = col.Find()
...
err = res.All(&items)
...

```

This other result set has a constraint, only items with `id = 11` will be part
of the result set.

```go
res = col.Find(db.Cond{"id": 11})
...
err = res.One(&item)
...
```

This `Find()` call does the same as above with a shorter syntax only supported by
SQL adapters.

```go
res = col.Find("id", 11)
...
```

If you're dealing with a relatively small number of items, you may want to dump
them all at once, use the `All()` method on a result-set to do so, like in the
following example:

$$
package main

import (
  "fmt"
	"log"

	"github.com/upper/db/v4/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: "booktown",
	Host:     "demo.upper.io",
	User:     "demouser",
	Password: "demop4ss",
}

type Book struct {
	ID    int64  `db:"id"`
	Title string `db:"title"`
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	booksCollection := sess.Collection("books")

	// Create a result-set containing all the books in the collection.
	res := booksCollection.Find()

	// Map all items in the result-set.
	var books []Book
	if err := res.All(&books); err != nil {
		log.Fatal("All: ", err)
	}

	// Print all mapped items.
	for i := range books {
		fmt.Printf("book[%d]: %#v\n", i, books[i])
	}
}
$$

#### Constraints on result-sets

The `db.Cond` map can be used to add constraints to result sets:

```go
cond = db.Cond{
  "id": 36, // id equals 36
}
```

> Note that `db.Cond` is a `map[interface{}]interface{}` type.

You can narrow down result-sets by passing `db.Cond` arguments to `Find()`.

```go
// Get items with id >= 36
cond = db.Cond{
  "id >=": 36,  // id >= 36
}
...
// Find where id >= 36
res = col.Find(cond)
...

// John Smi% is to be located.
cond = db.Cond{
  "name": "John",
  "last_name LIKE": "Smi%",
}
...
// Find where name = 'John' and last_name LIKE 'Smi%'
res = col.Find(cond)
...

// All rows that match name != "Joanna", only for SQL databases.
res = col.Find(db.Cond{"name != ?": "Joanna"})

// Same as above, but shorter.
res = col.Find(db.Cond{"name !=": "Joanna"})
```

`db.Cond` can also be used to express conditions that require special escaping
or custom operators:

```go
// "id" IN (1, 2, 3, 4)
res = col.Find(db.Cond{"id": []int{1, 2, 3, 4}})
// or...
res = col.Find(db.Cond{"id": db.In(1, 2, 3, 4)})

// "id" NOT IN (1, 2, 3, 4)
res = col.Find(db.Cond{"id NOT IN": []int{1, 2, 3, 4}})
// or...
res = col.Find(db.Cond{"id": db.NotIn(1, 2, 3, 4)})

// "last_name" IS NULL
res = col.Find(db.Cond{"last_name": nil})
// or...
res = col.Find(db.Cond{"id": db.IsNull()})

// "last_name" IS NOT NULL
res = col.Find(db.Cond{"last_name IS NOT": nil})
// or...
res = col.Find(db.Cond{"id": db.IsNotNull()})

// "last_name" LIKE "Smi%"
res = col.Find(db.Cond{"last_name LIKE": "Smi%"})
// or...
res = col.Find(db.Cond{"id": db.Like('Smi%')})
```

Constraints can also be composed using `db.Or()` or `db.And()`:

```go
// The item to be retrieved has a name with value "John" or "Jhon".
cond = db.Or(
  db.Cond{"name": "John"},
  db.Cond{"name": "Jhon"},
)
...

res = col.Find(cond)
...
```

```go
// The ages to be retrieved can range from 22 to 27.
cond db.And(
  db.Cond{"age >=": 22},
  db.Cond{"age <=": 27},
)
...

res = col.Find(cond)
...
```

Nesting values is another option:

```go
// (age > 21 AND age < 28) AND (name = "Joanna" OR name = "John" OR name = "Jhon")
cond = db.And(
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
...

res = col.Find(cond)
...
```

When using SQL adapters, conditions can also be expressed in string form, the
first argument to `Find()` is a string that is followed by a list of arguments:

```go
// These lines are equivalent.
res = col.Find("id = ?", 5)
res = col.Find("id", 5) // Means equality by default
res = col.Find("id", db.Eq(5))

// These as well.
res = col.Find("id > ?", 5)
res = col.Find("id >", 5) // Explicitly using the > comparison operator.
res = col.Find("id", db.Gt(5))

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
`$2` as `?` placeholders will be automatically transformed to the format the
database driver expects before building a query.

#### Results Limit and Order

You can determine the number of items you want to go through using `Offset()`
and `Limit()`:

```go
// Create a result-set
res = col.Find(...)
...

// Adjust the result-set so it will consist of 8 items and skip the first 2 rows.
res = res.Offset(2).Limit(8)
...

// Map all results into the accounts slice
err = res.All(&accounts)
...
```

Results can also be sorted according to a given value with `OrderBy()`:

```go
// Create a result-set
res := col.Find(...)
...

// Set descending order by `last_name` and map results into the accounts slice
err = res.OrderBy("-last_name").All(&accounts)
...
```

The total number of items in a result set can be calculated with `Count()`:

```go
res = col.Find(...)
...

count, err = res.Count()
...

fmt.Printf("There are %d items in the result set", count)
```

> `Limit()`, `Offset()`, and `OrderBy()` affect exclusively the `All()` and
> `One()` methods. See all [db.Result
> methods](https://pkg.go.dev/github.com/upper/db?tab=doc#Result).


#### Mapping large result sets

If your result-set is too large for being just dumped into an slice without
wasting a lot of memory, you can also fetch items one by one using `Next()` on
the result-set:

```go
res := res.Find()

var customer Customer
for res.Next(&customer) {
  log.Printf("%d: %s, %s\n", customer.ID, customer.LastName, customer.FirstName)
}
```

When using `Next()` you are the only one that knows when you're done reading
the result set (unlike with `All()` or `One()`), so you'll have to `Close()`
the result set manually after finishing using it.

```go
res := res.Find()
defer res.Close()
```

See the following example with `Find()` and `Next()`:

$$
package main

import (
  "fmt"
	"log"

	"github.com/upper/db/v4/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: "booktown",
	Host:     "demo.upper.io",
	User:     "demouser",
	Password: "demop4ss",
}

// Customer represents a customer.
type Customer struct {
	ID        uint   `db:"id"`
	FirstName string `db:"first_name"`
	LastName  string `db:"last_name"`
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close()

	res := sess.Collection("customers").Find().OrderBy("last_name")
	defer res.Close() // Make sure to close the result set.

	fmt.Println("Our customers:")
	var customer Customer
	// Use Next to iterate through all items on the result-set one by one.
	for res.Next(&customer) {
		fmt.Printf("%d:\t%q, %q\n", customer.ID, customer.LastName, customer.FirstName)
	}
}
$$

> There is no need to `Close()` the result set when using `All()` or `One` as
> it's closed automatically.

#### Counting elements on a result set

Use the `Count()` method on a result set to count the number of elements on it:

```go
res = col.Find(cond)
...

total, err := res.Count()
...
```

### Insert

Use the `Insert()` method on a collection reference to insert an new item, just
pass a struct value:

```go
account := Account{
  Name:     "Eliza",
  LastName: "Smith",
  ...
}

_, err := col.Insert(account)
...
```

You can also use maps to insert new items:

```go
_, err := col.Insert(map[string]interface{}{
  "name":      "Elizabeth",
  "last_name": "Smith",
  ...,
})
...
```

If the table or collection is set to generate a unique ID for every inserted
item, that ID will be returned by `Insert` as a
[`db.InsertResult`](https://pkg.go.dev/github.com/upper/db/v4?tab=doc#InsertResult)
value:

```go
res, err := col.Insert(account)
...

log.Printf("Created element with ID %v", res.ID())
```

Keep in mind that some databases won't work correctly if they're provided with
values for auto-generated fields, even if those fields have are zero values.
Use `omitempty` to skip those fields completely:

```go
type Account struct {
  ID uint64 `db:"id,omitempty"`
  ...
  CreatedAt *time.Time `db:"created_at,omitempty"`
  UpdatedAt *time.Time `db:"updated_at,omitempty"`
}
```

If your collection has an auto-generated ID and that ID is set as primary key,
then you may use `InsertReturning()`. The `InsertReturning()` method takes a
pointer to struct or map, inserts it into a collection and then fetches it from
the collection again, all on the same transaction. This makes it possible to
update the Go value with auto-generated fields, like timestamps or IDs:

```go
err := col.InsertReturning(&account)
...

log.Printf("Account: %#v", account)
```

#### Inserting elements with the SQL builder

Use `InsertInto` on a session to insert a new item using the SQL builder:

```go
// INSERT INTO people COLUMNS(name) VALUES('John')
q = sess.SQL().
  InsertInto("people").
  Columns("name").
  Values("John")

res, err := q.Exec() // res is a sql.Result
...
```

This SQLish syntax is only available on SQL adapters. See [INSERT
statement](https://pkg.go.dev/github.com/upper/db/sqlbuilder/#Inserter).

### Update

You can update all rows on a result-set with the `Update()` method.

```go
var account Account
res = col.Find("id", 5) // WHERE id = 5

// Populate account
err = res.One(&account)
...

// Change something
account.Name = "New name"
...

// Persist the change
err = res.Update(&account)
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

> Please note that all the struct fields without a value will be sent to the
> database as if they were empty. If you rather skip empty fields remember to
> use the `omitempty` option on them.

```go
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

that gives you total control on which values are going to be updated.

#### Updating with the SQL builder

This SQLish syntax is only available on SQL adapters. See [UPDATE
statement](https://pkg.go.dev/github.com/upper/db/v4/#Updater).

```go
q = sess.SQL().
  Update("people").Set("name", "John").Where("id = ?", 5)

res, err = q.Exec()
...
```

### Delete

Use `Delete()` on a result set to remove all the elements on the result-set.

```go
// Delete elements in `col` with id equals 4
res = col.Find("id", 4)
err = res.Delete()
...

// Delete elements in `col` with id greater than 8
res = col.Find("id >", 8)
err = res.Delete()
...

// Delete items in `col` with id 1 or 2 or 3 or 4
res = col.Find("id IN", []int{1, 2, 3, 4})
err = res.Delete()
...
```

#### Deleting with the SQL builder

This SQLish syntax is only available on SQL adapters. See [DELETE
statement](https://pkg.go.dev/github.com/upper/db/v4/#Deleter).

```go
q = sess.SQL().
  DeleteFrom("accounts").Where("id", 5)

res, err = q.Exec()
...
```

## SQL builder

The `Find()` method on a collection provides a compatibility layer between SQL
and NoSQL databases, but that might feel short in some situations. That's the
reason why SQL adapters also provide a powerful **SQL query builder**.

This is how you would create a query reference using the SQL builder on a
session:

```go
q := sess.SQL().
  SelectAllFrom("accounts")
...

q := sess.SQL().
  Select("id", "last_name").From("accounts")
...

q := sess.SQL().
  SelectAllFrom("accounts").Where("last_name LIKE ?", "Smi%")
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
q = sess.SQL().
  Select("id", "name").From("accounts").
  Where("last_name = ?", "Smith").
  OrderBy("name").Limit(10)
```

But even SQL-specific features, like joins, are supported (still depends on the
database, though):

```go
q = sess.SQL().
  Select("a.name").From("accounts AS a").
  Join("profiles AS p").
  On("p.account_id = a.id")

q = sess.SQL().
  Select("name").From("accounts").
  Join("owners").
  Using("employee_id")
```

Sometimes the builder won't be able to represent complex queries, if this
happens it may be more effective to use plain SQL:

```go
rows, err = sess.SQL().
  Query(`SELECT * FROM accounts WHERE id = ?`, 5)
...

row, err = sess.SQL().
  QueryRow(`SELECT * FROM accounts WHERE id = ? LIMIT ?`, 5, 1)
...

res, err = sess.SQL().
  Exec(`DELETE FROM accounts WHERE id = ?`, 5)
...
```

Mapping results from raw queries is also straightforward:

```go
rows, err = sess.SQL().
  Query(`SELECT * FROM accounts WHERE last_name = ?`, "Smith")
...

var accounts []Account
iter := sess.SQL().NewIterator(rows)
iter.All(&accounts)
...
```


## Take the `upper/db` tour

To get the full picture on how to perform all CRUD tasks (starting right from
the installation and setup steps), take the `upper/.db`
[tour](https://tour.upper.io/welcome/01).
