# The `db.Store` interface

The `db.Store` provides a foundation for creating data stores and custom
methods around regular collections.

The following example:

```go
book, err := Books(sess).GetBookByTitle("The Shining")
if err != nil {
  // ...
}
```

Could be implemented with a struct, a method and a function:


```go
package main

import (
  "github.com/upper/db/v4"
)

// BooksStore represents a store for books
type BooksStore struct {
  db.Collection
}

func (books *BooksStore) GetBookByTitle(title string) (*Book, error) {
  var book Book
  if err := books.Find(db.Cond{"title": title}).One(&book); err != nil {
    return nil, err
  }
  return &book, nil
}

// Books initializes a BookStore
func Books(sess db.Session) *BooksStore {
  return &BooksStore{sess.Collection("books")}
}

// Interface check
var _ = interface{db.Store}(&BooksStore{})
```

The `Books` function depicted above can be used to create new instances of
`BooksStore`, a common use case for this is the `Store()` method of a
`db.Record`:

```go
// Book represents a record from the "books" table.
type Book struct {
  // ...
}

func (book *Book) Store(sess db.Session) db.Store {
  return Books(sess)
}
```

Keep in mind that using `db.Record` and/or `db.Store` interfaces is completely
optional, the ultimate decision should be based on the needs of your project.

> The `db.Store` interface is only available for databases that support
> transactions, such as CockroachDB, PostgreSQL, MySQL, MSSQL, SQLite and ql.
