---
title: Bond hooks
---

## Validate

The `Validate() error` hook is called before creating or updating an item. If
`Validate()` returns a non-nil error, then the operation is aborted.

The purpose of this method is for models to run preliminary checks on
themselves before executing a query.

Make sure your model satisfies the `bond.Validator` interface at compile time:

```
var _ = bond.Validator(&Model{})
```

## BeforeCreate

The `BeforeCreate(bond.Session) error` hook is called before inserting an item
into a collection. If `BeforeCreate()` returns a non-nil error, then the whole
operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks before changing
the state of a collection.

```go
func (m *Model) BeforeCreate(sess bond.Session) error {
  //
  c, err := sess.Store("users").
    Find(db.Email{"email": m.Email}).
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

Make sure your model satisfies the `bond.BeforeCreateHook` interface at compile
time:

```
var _ = bond.BeforeCreateHook(&Model{})
```

## AfterCreate

The `AfterCreate(bond.Session) error` hook is called after having inserted an
item into a collection. If `AfterCreate()` returns a non-nil error, then the
whole operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks after changing
the state of a collection.

```go
func (m *Model) AfterCreate(sess bond.Session) error {
  // Send log to somewhere
  _ = events.Send("Item has been inserted.")
  return nil
}
```

Make sure your model satisfies the `bond.AfterCreateHook` interface at compile
time:

```
var _ = bond.AfterCreateHook(&Model{})
```

## BeforeUpdate

The `BeforeUpdate(bond.Session) error` hook is called before updating an item
from a collection. If `BeforeUpdate()` returns a non-nil error, then the whole
operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks before changing
the state of a collection.

```go
func (m *Model) BeforeUpdate(sess bond.Session) error {
  // Check if an e-mail
}
```

Make sure your model satisfies the `bond.BeforeUpdateHook` interface at compile
time:

```
var _ = bond.BeforeUpdateHook(&Model{})
```

## AfterUpdate

The `AfterUpdate(bond.Session) error` hook is called after having updated an
item from a collection. If `AfterUpdate()` returns a non-nil error, then the
whole operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks after changing
the state of a collection.

```go
func (m *Model) AfterUpdate(sess bond.Session) error {
  // Send log to somewhere
  return nil
}
```

Make sure your model satisfies the `bond.AfterUpdate` interface at compile time:

```
var _ = bond.AfterUpdate(&Model{})
```

## BeforeDelete

The `BeforeDelete(bond.Session) error` hook is called before removing an item
from a collection. If `BeforeDelete()` returns a non-nil error, then the whole
operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks before changing
the state of a collection.

```go
func (m *Model) BeforeDelete(sess bond.Session) error {
  // Check if an e-mail
}
```

Make sure your model satisfies the `bond.BeforeDeleteHook` interface at compile time:

```
var _ = bond.BeforeDeleteHook(&Model{})
```

## AfterDelete

The `AfterDelete(bond.Session) error` hook is called after having deleted an
item from a collection. If `AfterDelete()` returns a non-nil error, then the
whole operation is cancelled and rolled back.

The purpose of this method is for models to run specific tasks after changing
the state of a collection.

```go
func (m *Model) AfterDelete(sess bond.Session) error {
  // Send log to somewhere
  return nil
}
```

Make sure your model satisfies the `bond.AfterDeleteHook` interface at compile time:

```
var _ = bond.AfterDeleteHook(&Model{})
```
