## a) SQL Builder: Update, Insert and Delete

The `Update` method creates and returns an [Updater][2] that can be used to
build an UPDATE query:

```go
q := sess.Update("authors").
  Set("first_name = ?", "Edgar Allan").
  Where("id = ?", eaPoe.ID)

res, err := q.Exec()
```

The `InsertInto` method creates and returns an [Inserter][3] that can be used
to build an INSERT query:

```go
res, err = sess.InsertInto("books").
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

res, err = sess.InsertInto("books").
  Values(book).
  Exec()
```

The `DeleteFrom` method creates and returns a [Deleter][4] that can be used to
build a DELETE query:

```go
q := sess.DeleteFrom("books").
  Where("title", "The Crow")

res, err := q.Exec()
```

Take a look at the
[sqlbuilder.SQLBuilder](https://godoc.org/upper.io/db.v3/lib/sqlbuilder#SQLBuilder)
interface to learn about all available methods for building and executing SQL
statements.


## b) Raw SQL

```go
res, err := sess.Exec(`UPDATE authors SET first_name = ? WHERE id = ?`, "Edgar
Allan", eaPoe.ID)
...

res, err := sess.Exec(`INSERT INTO authors VALUES`)
...

res, err := sess.Exec(`DELETE authors WHERE id = ?`, "Edgar Allan", eaPoe.ID)
```

[1]: https://godoc.org/upper.io/db.v3/lib/sqlbuilder#Selector
[2]: https://godoc.org/upper.io/db.v3/lib/sqlbuilder#Updater
[3]: https://godoc.org/upper.io/db.v3/lib/sqlbuilder#Inserter
[4]: https://godoc.org/upper.io/db.v3/lib/sqlbuilder#Deleter

