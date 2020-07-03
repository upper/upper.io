## b) Raw SQL

If none of the previous methods described are enough to express your query, you
can use Raw SQL - specifically `Query`, `QueryRow`, and `Exec`, which are
provided by the [SQLBuilder][1] interface and mimic their counterparts in the
`database/sql` API:

```go
rows, err := sess.Query(`
  SELECT id, first_name, last_name FROM authors WHERE last_name = ?
`, "Poe")
...

row, err := sess.QueryRow(`SELECT * FROM authors WHERE id = ?`, 23)
...
```

Using raw SQL does not mean you'll have to map Go fields manually. You can
import the `github.com/uppper/db/sqlbuilder` package and use the
`sqlbuilder.NewIterator` function so mapping is easier:

```go
iter := sqlbuilder.NewIterator(rows)

var books []Book
err := iter.All(&books)
```

This iterator provides well-known `upper/db` methods like `One`, `All`, and
`Next`.

[1]: https://godoc.org/upper.io/db.v3/lib/sqlbuilder#SQLBuilder
