## a) SQL Builder: Update, Insert and Delete

The `Update` method creates and returns an [Updater][2] that can be used to
build an UPDATE query:

```go
q := sess.SQL().
  Update("authors").
  Set("first_name = ?", "Edgar Allan").
  Where("id = ?", eaPoe.ID)

res, err := q.Exec()
```

The `InsertInto` method creates and returns an [Inserter][3] that can be used
to build an INSERT query:

```go
res, err = sess.SQL().
  InsertInto("books").
  Columns(
    "title",
    "author_id",
    "subject_id",
  ).
  Values(
    "Brave New World",
    45,
    11,
  ).
  Exec()
```

In this case, using `Columns` is not mandatory. A struct can be passed to the
`Values` method so it is mapped to columns and values, as shown below:

```go
book := Book{
  Title:    "The Crow",
  AuthorID: eaPoe.ID,
}

res, err = sess.SQL().
  InsertInto("books").
  Values(book).
  Exec()
```

The `DeleteFrom` method creates and returns a [Deleter][4] that can be used to
build a DELETE query:

```go
q := sess.SQL().
  DeleteFrom("books").
  Where("title", "The Crow")

res, err := q.Exec()
```

Take a look at the
[db.SQL](https://pkg.go.dev/github.com/upper/db/v4#SQL)
interface to learn about all available methods for building and executing SQL
statements.

## b) Raw SQL

```go
res, err := sess.SQL().Exec(`UPDATE authors SET first_name = ? WHERE id = ?`, "Edgar
Allan", eaPoe.ID)
...

res, err := sess.SQL().Exec(`INSERT INTO authors VALUES`)
...

res, err := sess.SQL().Exec(`DELETE authors WHERE id = ?`, "Edgar Allan", eaPoe.ID)
```

[1]: https://pkg.go.dev/github.com/upper/db/v4#Selector
[2]: https://pkg.go.dev/github.com/upper/db/v4#Updater
[3]: https://pkg.go.dev/github.com/upper/db/v4#Inserter
[4]: https://pkg.go.dev/github.com/upper/db/v4#Deleter

