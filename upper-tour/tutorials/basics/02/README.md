# List all collections in a database

Use the `Collections` method on a `db.Session` to get all the collections in
the database:

```go
collections, err := sess.Collections()
...

for i := range collections {
  log.Printf("-> %s", collections[i].Name())
}
```

> The `db.Session` interface provides methods that work on both SQL and NoSQL
> databases. In light of this, sets of rows are simply referred to as
> 'collections' and no particular distinction is made between 'SQL tables' and
> 'NoSQL collections'.

> You can call different `db.Session` methods depending on the database type.
> For example, if you're working with a SQL database, `sess` will also satisfy
> [sqlbuilder.Session][3].


[2]: https://godoc.org/github.com/upper/db#Session
[3]: https://godoc.org/github.com/upper/db/sqlbuilder#Session
