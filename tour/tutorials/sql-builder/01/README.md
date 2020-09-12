## a) SQL Builder: Select

All the adapters for SQL databases come with a handy SQL builder that you can
use to compose queries.

You can access the SQL builder on SQL adapters using the `SQL()` method:

```go
builder := sess.SQL()
```

There are different methods you can use to begin your query,
for instance `SelectFrom`:

```go
q := sess.SQL().
  SelectFrom("books")
```

`SelectFrom` returns a [Selector][2] and some `Selector` methods return
`Selector` too, so you can chain method calls like this:

```go
q := sess.SQL().
  SelectFrom("books").
  Where("title LIKE ?", "P%")
```

or

```go
q := sess.SQL().
  SelectFrom("books")

q = q.Where("title LIKE ?", "P%")
```

Note that we're reassigning `q` in the last example. This is because queries
are immutable and methods do not affect the caller, like in the next case
(where `q` is not affected by `Where`):

```go
q := sess.SelectFrom("books")

p := q.Where("title LIKE ?", "P%").
  OrderBy("title")
```

You can use `All` or `One` to compile, execute, and map results into a Go type:

```go
var books []Book
err := q.All(&books)
```

or

```go
var book Book
err := q.One(&book)
```

The `Selector` interface also features a special `Iterator` method to create an
iterator and go through results one by one:

```go
iter := q.Iterator()
defer iter.Close()

for iter.Next(&book) {
  // ...
}

if err := iter.Err(); err != nil {
  // ...
}
```

[1]: https://godoc.org/upper.io/db.v3/lib/sqlbuilder#SQLBuilder
[2]: https://godoc.org/upper.io/db.v3/lib/sqlbuilder#Selector
