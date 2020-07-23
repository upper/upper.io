# The `db.Model` interface

The `db.Model` interface provides a bare minimum support for you to operate
with Go structs in a more ORM-ish way:

```go
package db

type Model interface {
  Collection(sess Session) Collection
}
```

> The `upper/db` models functionality is only available for databases that
> support transactions, such as CockroachDB, PostgreSQL, MySQL, MSSQL, SQLite and
> ql.

In the example below, `Book` is a struct that satisfies the `db.Model`
interface:

```go
package main

import (
  "github.com/upper/db/v4"
  "github.com/upper/db/v4/sqlbuilder"
)

type Book struct {
  sqlbuilder.Item // Provides addional methods for Book

  ID        uint   `db:"id,omitempty"`
  Title     string `db:"title"`
  AuthorID  uint   `db:"author_id,omitempty"`
  SubjectID uint   `db:"subject_id,omitempty"`
}

func (book *Book) Collection(sess db.Session) db.Collection {
  return sess.Collection("books")
}
```

You can pass `db.Model` objects to special `db.Session` methods, such as
`sess.Get` and `sess.Save`:

```go
var book Book

// Get "The Shining" from the catalog
err = sess.Get(&book, db.Cond{"title": "The Shining"})
// ...

// Persist object to database
err = sess.Save(&book)
// ...
```

Note that besides defining `Collection()` we're also including the
`sqlbuilder.Item` struct, which extends our `Book` example with a few extra
methods that satisfy the `db.Item` interface:

```go
type Item interface {
  Save(Session) error
  Delete(Session) error
  Update(Session, M) error
  Changes() M
}
```

and provide you with extra functionality to persist, delete or update the item
you're working with:

```
err = book.Save(sess) // Equivalent to sess.Save(&book)
// ...

err = book.Delete(sess)
// ...

err = book.Update(sess, db.M{"title": "my title"})
// ...

changes = book.Changes()
// ...
```

## Hooks

`db.Model` objects can optionally satisfy hooks, which are special methods
called before or after specific events. For instace, if we'd like the `Account`
model to execute code right before inserting a new entry into the database we'd
add a `BeforeCreate` hook, like this:

```go
func (account *Account) BeforeCreate(sess db.Session) error {
  // ...
  return nil
}
```

`upper/db` models support the following hooks:

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

The `Validator` interface could be used to run validations against the model's
own data.
