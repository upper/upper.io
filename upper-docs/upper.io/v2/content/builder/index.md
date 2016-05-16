# The SQL builder

The SQL builder provided by SQL adapters is the perfect tool when you need more
than a simple compatibility later.

## SELECT

Use the `Select()` method on a session to begin a SELECT statement:

```go
q = sess.Select("id", "name") // select from where?
```

If you compiled the select statement at this point it would look like `SELECT
"id", "name";` which is kind of incomplete, you still need to specify which
table to select from:

```go
q = sess.Select("id", "name").From("accounts")
```

Now have a complete query that can be compiled and executed into valid SQL:

```
var accounts []Account
q = sess.Select("id", "name").From("accounts")

// All() executes the query, maps the rows into an slice or
// struct or map and returns an error.
err = q.All(&accounts)
...
```

You can also `One()` instead of `All()` to map only one result:

```go
var account Account

err = q.One(&account)
...
```

You can also use the `Iterator()` method instead of `All()` or `One()` to get a
`builder.Iterator` and iterate over large sets of results:

```go
iter := q.Iterator()

var account Account

for iter.Next(&account) {
  ...
}
err = iter.Err() // in case of errors
...
```

To select all the columns instead of specific ones, you can use the
`SelectAllFrom()` method:

```go
q = sess.SelectAllFrom("accounts")

err = q.All(&accounts)
...
```

which is equivalent to `q.Select().From("accounts")`.

## INSERT

The `InsertInto()` method begins an INSERT statement.

```go
q = sess.InsertInto("people").Columns("name").Values("John")

err = q.Exec()
...
```

You can omit the `Columns()` method pass a map or a struct to `Values()`
directly:

```go
account := Account{
  ...
}

q = sess.InsertInto("people").Values(account)

err = q.Exec()
...
```

## UPDATE

The `Update()` method takes a table name and begins an UPDATE statement:

```go
q = sess.Update("people").Set("name", "John").Where("id = ?", 5)

err = q.Exec()
...
```

You can update many columns at once by providing column-value pairs to `Set()`:


```go
q = sess.Update("people").Set(
  "name", "John",
  "last_name", "Smith",
).Where("id = ?", 5)

err = q.Exec()
...
```

You don't always have to provide column-value pairs, `Set()` also accepts maps
or structs:

```go
q = sess.Update("people").Set(map[string]interface{}{
  "name": "John",
  "last_name": "Smith",
}).Where("id = ?", 5)

err = q.Exec()
...
```

## DELETE

You can begin a DELETE statement with the `DeleteFrom()` method:

```go
q = sess.DeleteFrom("accounts").Where("id", 5)

err = q.Exec()
...
```

## Joins

The `Join()` method is part of `builder.Selector`, it extends the functionalty
of `builder.Selector` to express SELECT statements that use JOINs.

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

```
var results map[string]interface{}
err = q.All(&results)
```

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

`Query` returns a `*sql.Rows` object that you can use to map the results into a
variable:

```go
rows, err = sess.Query(`SELECT * FROM accounts WHERE last_name = ?`, "Smith")
...

var accounts []Account
iter := sqlbuilder.NewIterator(rows)
err = iter.All(&accounts)
...
```

## Conditions

The `Where()` method can be used to define conditions on a statement and it can
be chained easily to the `Selector`, `Deleter` and `Updater` interfaces:

Let's suppose we have a `Selector`:

```go
q = sess.SelectAllFrom("accounts")
```

We can use the `Where()` method to add conditions to the above query. How about
constraining the results to the rows that match `id = 5`?:

```go
q.Where("id = ?", 5)
```

We use a `?` as a placeholder for the argument, this is required in order to
sanitize arguments and prevent SQL injections. You can use as many arguments as
you need as long as you provide a value for each one of them:

```go
q.Where("id = ? OR id = ?", 5, 4)
```

The above condition could be rewritten into:


```go
q.Where("id IN ?", []int{5,4})
```

And in fact, we can drop the `?` at the end if we only want to test an
equalility:

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
would with `db` when using `Find()`:

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


[1]: https://golang.org
[2]: https://upper.io/db.v2
