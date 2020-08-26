# Update, insert, or delete records in a result set

The records in result sets can not only be queried, but also modified and
removed.

If you want to modify the properties of a whole result set, use `Update`:

```go
var book Book
res := booksCol.Find(4267)

err = res.One(&book)
...

book.Title = "New title"

err = res.Update(book)
...
```

Note that the result above set consists of only one element, whereas the next
result set consists of all the records in the collection:

```go
res := booksCol.Find()

// Updating all records in the result-set.
err := res.Update(map[string]int{
  "author_id": 23,
})
```

If you want to remove all the records in a result set, use `Delete`:

```go
res := booksCol.Find(4267)

err := res.Delete()
// ...
```

As with the `Update` examples, in the previous case only one record will be
affected and in the following scenario all records will be deleted:

```go
res := booksCol.Find()

//  Deleting all records in the result-set.
err := res.Delete()
...
```

In the particular case of SQL databases, you can also choose to use a builder
or raw SQL query to execute update, insert, and delete operations.

Given that the example in this tour is based on a SQL database, we'll elaborate
hereunder on the use of both a) SQL builder methods and b) raw SQL statements.