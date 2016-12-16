# The SQL builder

SQL adapters  such as `postgresql`, `mysql`, `ql` and `sqlite` provide special
methods for building queries that require more control than what `Find()`
provides.

## Select statement

Use the `Select()` method on a session to begin a SELECT statement (a
`Selector`):

```go
q = sess.Select("id", "name")
```

If you compiled the select statement at this point it would look like `SELECT
"id", "name";` which is an incomplete SQL query, you still need to specify
which table to select from, chain the `From()` method to do that:

```go
q = sess.Select("id", "name").From("accounts")
```

Now you have a complete query that can be compiled into valid SQL:

```
var accounts []Account
q = sess.Select("id", "name").From("accounts")

fmt.Println(q) // SELECT id, name FROM accounts
```

This query is wired to the database session, but it's not compiled nor executed
unless you require data from it, use the `All()` method on a query to execute
it and map all the resulting rows into a slice of structs or maps:

```go
// All() executes the query and maps the resulting rows into an slice of
// structs or maps.
err = q.All(&accounts)
...
```

If you're only interested in one result, use `One()` instead of `All()` and
provide a single pointer to struct or map:

```go
var account Account
err = q.One(&account)
...
```

To select all the columns instead of specific ones, you can use the
`SelectFrom()` method:

```go
q = sess.SelectFrom("accounts") // SELECT * FROM accounts

err = q.All(&accounts)
...

// Which is basically equivalent to
// q = sess.Select().From("accounts")
```


Using `All()` comes with a cost: it requires to allocate a slice to dump all
the queried results. If you're working with large datasets that could be
expensive, it's probably more efficient to get results one by one using an
iterator:

```go
iter := q.Iterator()

var account Account
for q.Next(&account) {
  ...
}

err = iter.Err()
...
```

Iterators are automatically closed at the end of the `Next()`-based loop, but
in case you need to exit the iterator before the loop is completed use
`iter.Close()`:

```
for iter.Next() {
  if somethingHappened() {
    iter.Close()
    break
  }
}
```

You have to decide whether you want to use `All()`, `One()` or an `Iterator`
depending on your specific needs.

## INSERT statement

The `InsertInto()` method begins an INSERT statement (an `Inserter`).

```go
q = sess.InsertInto("people").Columns("name").Values("John")

res, err = q.Exec()
...
```

You don't have to use the `Columns()` method, if you pass a map or a struct,
you can omit it completely:

```go
account := Account{
  ...
}

q = sess.InsertInto("people").Values(account)

res, err = q.Exec() // res is a sql.Result
...
```

## UPDATE statement

The `Update()` method takes a table name and begins an UPDATE statement (an
`Updater`):

```go
q = sess.Update("people").Set("name", "John").Where("id = ?", 5)

res, err = q.Exec()
...
```

You can update many columns at once by providing column-value pairs to `Set()`:


```go
q = sess.Update("people").Set(
  "name", "John",
  "last_name", "Smith",
).Where("id = ?", 5)

res, err = q.Exec()
...
```

You don't always have to provide column-value pairs, `Set()` also accepts maps
or structs:

```go
q = sess.Update("people").Set(map[string]interface{}{
  "name": "John",
  "last_name": "Smith",
}).Where("id = ?", 5)

res, err = q.Exec()
...
```

## DELETE statement

You can begin a DELETE statement with the `DeleteFrom()` method (a `Deleter`):

```go
q = sess.DeleteFrom("accounts").Where("id", 5)

res, err = q.Exec()
...
```

## SELECT statement and joins

The `Join()` method is part of a `Selector`, you can use it to represent SELECT
statements that use JOINs.

```go
q = sess.Select("a.name").From("accounts AS a").
  Join("profiles AS p").
  On("p.account_id = a.id")
...

q = sess.Select("name").From("accounts").
  Join("owners").
  Using("employee_id")
...
```

In addition to `Join()` you can also use `FullJoin()`, `CrossJoin()`,
`RightJoin()` and `LeftJoin()`.

## Raw SQL

If the builder does not provide you with enough flexibility to create complex
SQL queries, you can always use plain SQL:

```go
rows, err = sess.Query(`SELECT * FROM accounts WHERE id = ?`, 5)
...

row, err = sess.QueryRow(`SELECT * FROM accounts WHERE id = ? LIMIT ?`, 5, 1)
...

res, err = sess.Exec(`DELETE FROM accounts WHERE id = ?`, 5)
...
```

The `Query` method returns a `*sql.Rows` object and of course you can do
whatever you would normally do with it:

```
err = rows.Scan(&id, &name)
...
```

If you don't want to use `Scan` directly, you could always create an iterator
using any `*sql.Rows` value:

```go
import "upper.io/db.v2/lib/sqlbuilder"
...

rows, err = sess.Query(`SELECT * FROM accounts WHERE last_name = ?`, "Smith")
...

var accounts []Account
iter := sqlbuilder.NewIterator(rows)
err = iter.All(&accounts)
...
```

## More on conditions

The `Where()` method can be used to define conditions on a `Selector`,
`Deleter` or `Updater` interfaces.

For instance, let's suppose we have a `Selector`:

```go
q = sess.SelectFrom("accounts")
```

We can use the `Where()` method to add conditions to the above query. How about
constraining the results only to rows that match `id = 5`?:

```go
q.Where("id = ?", 5)
```

We use a `?` as a placeholder for the argument, this is required in order to
sanitize arguments and prevent SQL injections. You can use as many arguments as
you need as long as you provide a value for each one of them:

```go
q.Where("id = ? OR id = ?", 5, 4) // Two place holders and two values.
```

The above condition is a list of ORs and sometimes things like that can be
rewritten into things like this:

```go
q.Where("id IN ?", []int{5,4}) // id IN (5, 4)
```

Placeholders are not always necessary, if you're looking for the equality and
you're only going to provide one argument, you could drop the `?` at the end:

```go
q.Where("id", 5)
...
q.Where("id IN", []int{5,4})
...
```

It is also possible to use other operators besides the equality, but you have
to be explicit about them:

```go
q.Where("id >", 5)
...
q.Where("id > ? AND id < ?", 5, 10)
...
```

You can also use `db.Cond` to define conditions for `Where()` just like you
would normally do when using `Find()`:

```go
// ...WHERE "id" > 5
q.Where(db.Cond{
  "id >": 5,
})
...
// ...WHERE "id" > 5 AND "id" < 10
q.Where(db.Cond{"id >": 5, "id <": 10})
...

// ...WHERE ("id" = 5 OR "id" = 9 OR "id" = 12)
q.Where(db.Or(
  db.Cond{"id": 5},
  db.Cond{"id": 9},
  db.Cond{"id": 12},
))
```

Remember that if you want to use `db.Cond` you'll need to import
`upper.io/db.v2` into your app:

```go
import "upper.io/db.v2"
```

[1]: https://golang.org
[2]: https://upper.io/db.v2
