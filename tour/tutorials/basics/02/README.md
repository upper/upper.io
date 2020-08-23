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

The `db.Session` interface provides methods that work on both SQL and NoSQL
databases. In light of this, sets of records or rows in a database are simply
referred to as 'collections' and no particular distinction is made between 'SQL
tables' and 'NoSQL collections'.


[2]: https://godoc.org/github.com/upper/db#Session
