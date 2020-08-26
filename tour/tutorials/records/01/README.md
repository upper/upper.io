# The `db.Record` interface

The `db.Record` interface provides a bare minimum support for you to operate
with Go structs in a more ORM-ish way:

```go
package db

type Record interface {
  Store(sess Session) Store
}
```

The `db.Store` interface is a container for `db.Collection` that is defined
like this:

```go
type Store interface {
  Collection
}
```

In the example below, `Book` is a struct that satisfies the `db.Record`
interface:

```go
package main

import (
  "github.com/upper/db/v4"
)

type Book struct {
  ID        uint   `db:"id,omitempty"`
  Title     string `db:"title"`
  AuthorID  uint   `db:"author_id,omitempty"`
  SubjectID uint   `db:"subject_id,omitempty"`
}

func (book *Book) Store(sess db.Session) db.Store {
  return sess.Collection("books")
}

// Compile-time check.
var _ = db.Record(&Book{})
```

You can use the `db.Record` interface with special `db.Session` methods suchs
as `Get`, `Save` or `Delete`:

```go
var book Book

// Get "The Shining" from the catalog
err = sess.Get(&book, db.Cond{"title": "The Shining"})
// ...

// Persist record to database
err = sess.Save(&book)
// ...

// Create a new record
book := Book{Title: "My new book"}
err = sess.Save(&book)

// Delete record
err = sess.Delete(&book)
```

## Hooks

`db.Record` objects can optionally satisfy hooks, which are special methods
called before or after specific events. For instace, if we'd like the `Book`
record to execute code right before inserting a new entry into the database
we'd add a `BeforeCreate` hook, like this:

```go
func (book *Book) BeforeCreate(sess db.Session) error {
  // ...
  return nil
}
```

`upper/db` records support the following hooks:

* `BeforeCreate(db.Session) error`
* `AfterCreate(db.Session) error`
* `BeforeUpdate(db.Session) error`
* `AfterUpdate(db.Session) error`
* `BeforeDelete(db.Session) error`
* `AfterDelete(db.Session) error`

Hooks in `upper/db` run within a database transaction, if any of the hooks
return an error, the whole transactions is cancelled and rolled back.

## Validation

Besides hooks, there's another optional interface defined as:

```
type Validator interface {
  Validate() error
}
```

The `Validator` interface could be used to run validations against the record's
own data.

> The `db.Record` interface is only available for databases that support
> transactions, such as CockroachDB, PostgreSQL, MySQL, MSSQL, SQLite and ql.
