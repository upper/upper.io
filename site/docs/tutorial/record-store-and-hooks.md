---
title: ORM-like behaviour with `db.Record`, `db.Store` and hooks
---

`upper/db` provides two complementary interfaces that can help you modelling
apps in a more ORM-ish way, `db.Record` and `db.Store`.

## `db.Record` for single records

`db.Record` is a interface that can be satisfied by structs that are meant to
represent single records from a collection:

```go
type Record interface {
  Store(sess Session) Store
}
```

For instace, if you have a `Book` struct that looks like this:

```go
type Book struct {
  Title string `db:"title"`
}
```

you can make that struct compatible with `db.Record` by adding a `Store`
method:

```go
type Book struct {
  // ...
}

func (b *Book) Store(sess db.Session) Store {
  return sess.Collection("books")
}

var _ = db.Record(&Book{})
```

Records can be used with `db.Session` methods:

```go
// Retrieving a record
sess.Get(&book, 123)

// Creating or updating a record
sess.Save(&book)

// Delete a record
sess.Delete(&book)
```

See the [tour example](//tour.upper.io/records/01) on `db.Record`.

## `db.Store` for collections

The `db.Store` is an interface that can be satisfied by collections:

```go
type Store interface {
  Collection
}
```

Let's suppose we want to create a `db.Store` for `Book` records, we'd name it
`BookStore`:

```go
type BooksStore struct {
  db.Collection
}

var _ = db.Store(&BooksStore{})
```

A `db.Store` struct can be extended with custom methods. The following method
returns a book that matches a given title:

```go
func (books *BooksStore) FindByTitle(title string) (*Book, error) {
  var book Book
  if err := books.Find(db.Cond{"title": title}).One(&book); err != nil {
    return nil, err
  }
  return &book, nil
}
```

A recommended pattern for stores is creating a function to enclose the store's
initialization:

```go
func Books(sess db.Session) *BooksStore {
  return &BooksStore{sess.Collection("books")}
}
```

this function can be used later on instead of `sess.Collection`:

```go

err := Books(sess).Find(...).All(...)
```

See the [tour example](//tour.upper.io/records/01) on `db.Store`.

## `db.Record` and `db.Store`

The `db.Record` and `db.Store` interfaces do not depend on each other but can
be mixed together. See the following example:

```go
type BooksStore struct {
  Collection db.Collection
}

func (books *BooksStore) FindByTitle(title string) (*Book, error) {
  // ...
}

// Books initializes a BooksStore
func Books(sess db.Session) *BooksStore {
  return &BooksStore{sess.Collection("books")}
}

type Book struct {
  Title string `db:"title"`
}

func (b *Book) Store(sess db.Session) Store {
  // Note that we're using the Books function defined above instead
  // of sess.Collection.
  return Books(sess)
}

var _ = db.Store(&BooksStore{})
var _ = db.Record(&Book{})
```

## `db.Record` hooks

Hooks are tasks to be performed before or after a specific action happens on a
record. You can add hooks to models by defining special methods like
`BeforeCreate`, `AfterUpdate`, or `Validate` that satisfy specific signatures:

```go
type User struct {
  // ...
}

func (u *User) Store(sess db.Session) db.Store {
  // ...
}

// BeforeCreate hook
func (u *User) BeforeCreate(sess db.Session) error {
  // ...
}

// Validate hook
func (u *User) Validate() error {
  // ...
}

// Interface checks
var _ = interface{
  db.Record
  db.BeforeCreateHook
  db.Validator
}(&User{})
```

Hooks are only executed when using methods that explicitly require `db.Record`,
such a `sess.Get`, `sess.Save` or `sess.Delete`:

```go
// Hooks will be executed
sess.Save(&user)

// Hooks won't be executed
sess.Collection(...).Find().Update(&user)
```

### Validate

The `Validate() error` hook is called before creating or updating a record. If
`Validate()` returns a non-nil error, then the operation is aborted.

The purpose of this method is for models to run preliminary checks on their own
data before executing a query.

Make sure your model satisfies the `db.Validator` interface at compile time:

```
var _ = db.Validator(&User{})
```

### BeforeCreate

The `BeforeCreate(db.Session) error` hook is called before inserting a record
into a collection. If `BeforeCreate()` returns a non-nil error, then the whole
operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks before changing
the state of a collection.

```go
func (user *User) BeforeCreate(sess db.Session) error {
  // Check if the e-mail was already registered by another user.
  c, err := user.Store(sess).
    Find(db.Cond{"email": user.Email}).
    Count()
  if err != nil {
    return err
  }
  if c > 0 {
    return errors.New("e-mail already exists")
  }

  return nil
}
```

Make sure your model satisfies the `db.BeforeCreateHook` interface at compile
time:

```
var _ = db.BeforeCreateHook(&User{})
```

### AfterCreate

The `AfterCreate(db.Session) error` hook is called after having inserted a
record into a collection. If `AfterCreate()` returns a non-nil error, then the
whole operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks after changing
the state of a collection.

```go
func (user *User) AfterCreate(sess db.Session) error {
  // Send log to somewhere else.
  events.Log("Item has been inserted.")
  return nil
}
```

Make sure your model satisfies the `db.AfterCreateHook` interface at compile
time:

```
var _ = db.AfterCreateHook(&User{})
```

### BeforeUpdate

The `BeforeUpdate(db.Session) error` hook is called before updating a record
from a collection. If `BeforeUpdate()` returns a non-nil error, then the whole
operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks before changing
the state of a collection.

```go
func (user *User) BeforeUpdate(sess db.Session) error {
  // Check if the e-mail is already in use.
  c, err := user.Store(sess).
    Find(db.Cond{
      "email": user.Email,
      "id": db.NotEq(user.ID),
    }).
    Count()
  if err != nil {
    return err
  }
  if c > 0 {
    return errors.New("e-mail is already in use")
  }

  return nil
}
```

Make sure your model satisfies the `db.BeforeUpdateHook` interface at compile
time:

```
var _ = db.BeforeUpdateHook(&User{})
```

### AfterUpdate

The `AfterUpdate(db.Session) error` hook is called after having updated a
record from a collection. If `AfterUpdate()` returns a non-nil error, then the
whole operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks after changing
the state of a collection.

```go
func (user *User) AfterUpdate(sess db.Session) error {
  // Send log to somewhere
  events.Log("Item has been updated.")
  return nil
}
```

Make sure your model satisfies the `db.AfterUpdate` interface at compile time:

```
var _ = db.AfterUpdate(&User{})
```

### BeforeDelete

The `BeforeDelete(db.Session) error` hook is called before removing a record
from a collection. If `BeforeDelete()` returns a non-nil error, then the whole
operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks before changing
the state of a collection.

```go
func (post *Post) BeforeDelete(sess db.Session) error {
  // Check if the post is unpublished before deletion
  if post.Published {
    return errors.New("post must be unpublished before deletion")
  }
  return nil
}
```

Make sure your model satisfies the `db.BeforeDeleteHook` interface at compile time:

```
var _ = db.BeforeDeleteHook(&Post{})
```

### AfterDelete

The `AfterDelete(db.Session) error` hook is called after having deleted a
record from a collection. If `AfterDelete()` returns a non-nil error, then the
whole operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks after changing
the state of a collection.

```go
func (post *Post) AfterDelete(sess db.Session) error {
  // Update post counter
  Stats(sess).Update(...)
  return nil
}
```

Make sure your model satisfies the `db.AfterDeleteHook` interface at compile time:

```
var _ = db.AfterDeleteHook(&Post{})
```
