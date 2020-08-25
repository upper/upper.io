# How to migrate from v1 to v2

`db.v2` is incompatible with `db.v1`. In order not to break non versioned
`db.v1` implementations, the old `upper.io/db` import path still points to the
latest stable `v1`, but this is a temporary measure.

If you want to stick with `v1`, please change your import paths to
`upper.io/db.v1` you won't need to do any other modification, we'll keep stable
versions without any breaking changes on `upper.io/db.v2` and `upper.io/db.v1`,
but we may use `upper.io/db` for bleeding edge development at some point in the
future.

`v1` will be deprecated, only security patches will be applied, so upgrading to
`v2` is recommended, this is not a trivial task and requires manual work.

In order to help you migrating, the key differences between `v1` and `v2` are
detailed here.

## Differences from db.v1

1. `v2` comes with a SQL query builder.
1. `db.And()`, `db.Or()`, `db.Func()` and `db.Raw()` are functions instead of
   structs.
1. `db.Session.Collection()` only accepts one table.
1. JOIN capabilities where removed from `Find()` (in favour of the built-in query builder).

## New import path

The import path was changed from `upper.io/db` into `upper.io/db.v2`.

```go
import (
  ...
  "upper.io/db.v2"
  ...
)
```

## Richer Find() syntax

The `Find()` method is now more flexible and can accept different arguments:

```go
// The following syntax only works for SQL databases:
res = Find("id = ?", 1)

// This is a shortcut for the case above:
res = Find("id", 1)

// If the table has an integer primary key.
res = col.Find(1)

// This is still compatible with all databases:
res = Find(db.Cond{"id": 1})
```

## Database.Collection()

The [Database](https://godoc.org/upper.io/db.v2#Database) interface used to
have a `C()` method, that method was replaced by `Collection()`, which does not
return error anymore when the collection does not exist:

```go
col := sess.Collection("users")
...

// Any possible error accessing this table will be returned only when actually
// working with it.
err := col.Find().All(&users)
...
```

## db.Func()

[db.Func](https://godoc.org/upper.io/db.v2#Func) is now a function that returns
a [db.Function](https://godoc.org/upper.io/db.v2#Function) interface:

```go
f := db.Func("MOD", 29, 9) // Before: db.Func{"MOD": []int{29, 9}}

f := db.Func("CONCAT", "abc", "def") // Before: db.Func{"CONCAT": []string{"abc", "def"}}
```

## db.And() and db.Or()

[db.And](https://godoc.org/upper.io/db.v2#And) is now a function that returns a
[db.Intersection](https://godoc.org/upper.io/db.v2#Intersection) interface:

```go
// db.And used to be a struct:
db.And{
  db.Cond{"a": 1},
  db.Cond{"b": 2},
  db.Cond{"c": 3},
}

// But now it's a function:
cond = db.And(
  db.Cond{"a": 1},
  db.Cond{"b": 2},
  db.Cond{"c": 3},
)

// This is equivalent to the declaration above:
cond = db.And(db.Cond{"a": 1}).
  And(db.Cond{"b": 2}).
  And(db.Cond{"c": 3})

// This is also equivalent:
cond = db.And(db.Cond{"a": 1})
cond.And(db.Cond{"b": 2})
cond.And(db.Cond{"c": 3})
```

[db.Or](https://godoc.org/upper.io/db.v2#Or) is now also a function that
returns a [db.Union](https://godoc.org/upper.io/db.v2#Union) interface:

```go
// db.Or used to be a struct:
cond = db.Or{
  db.Cond{"a": 1},
  db.Cond{"b": 2},
  db.Cond{"c": 3},
}

// But now it's a function:
cond = db.Or(
  db.Cond{"a": 1},
  db.Cond{"b": 2},
  db.Cond{"c": 3},
)

// This is equivalent to the declaration above:
cond = db.Or(db.Cond{"a": 1}).
  Or(db.Cond{"b": 2}).
  Or(db.Cond{"c": 3})

// This is also equivalent:
cond = db.Or(db.Cond{"a": 1})
cond.Or(db.Cond{"b": 2})
cond.Or(db.Cond{"c": 3})
```

Both `db.And` and `db.Or` can accept arguments that satisfy
[db.Compound](https://godoc.org/upper.io/db.v2#Compound), which can be
`db.Cond{}`, `db.Raw()` or the output from other `db.And()` or `db.Or()` calls.

## db.Raw()

[db.Raw](https://godoc.org/upper.io/db.v2#Raw) is now a function that
returns [db.RawValue](https://godoc.org/upper.io/db.v2#RawValue):

```go
db.Raw("SOUNDEX('Hello')") // Old: db.Raw{"SOUNDEX('Hello')"}
```

## Result.Limit(int)

The `Limit` method from the
[db.Result](https://godoc.org/upper.io/db.v2#Result) interface now accepts int:

```go
res = Find().Limit(3) // Old: Find().Limit(uint(3))
```

## Result.Offset(int)

The `Skip` method was renamed into `Offset`, it's still part of the
[db.Result](https://godoc.org/upper.io/db.v2#Result) interface and it now
accepts int:

```go
res = Find().Limit(3).Offset(5) // Old: Find().Limit(uint(3)).Skip(uint(5))
```

## Collection.Insert(item)

The [Collection](https://godoc.org/upper.io/db.v2#Collection) interface used to
have an `Append(item)` method, that method was renamed into `Insert(item)`.

```go
id, err = col.Insert(foo) // Old: col.Append(foo)
```

## Collection.InsertReturning(item)

The [Collection](https://godoc.org/upper.io/db.v2#Collection) interface has a
new method `InsertReturning(item)` which inserts the passed item and updates it with
the actual value from the database. It is useful for auto values, like ID or
automatic creation/modification dates.

```go
err = col.InsertReturning(foo)
// foo is now updated
```

## Collection.Delete()

The [Collection](https://godoc.org/upper.io/db.v2#Collection) interface used
to have a `Remove()` method, that method was renamed into `Delete()`:

```go
err = res.Delete() // Old: res.Remove()
```

## SQL Builder

The `sqlutil` package provided `FetchRow()` and `FetchRows()` functions which
were used to map `*sql.Rows` into Go values, those functions do not exist
anymore.

This functionality is now provided by the
[sqlbuilder](https://godoc.org/upper.io/db.v2/lib/sqlbuilder) package which
provides the [Builder](https://godoc.org/upper.io/db.v2/lib/sqlbuilder#Builder)
interface which is already integrated into regular SQL sessions:

```go
// Create
rows, err = sess.Query("SELECT * FROM myTable")
err = sqlbuilder.NewIterator(rows).All(&myItems)

// This is a shortcut for the above instructions:
err = sess.Iterator("SELECT * FROM myTable").All(&myItems)
```

You can also use
[NewIterator](https://godoc.org/upper.io/db.v2/lib/sqlbuilder#NewIterator) on
`*sql.Rows` generated outside `db`:

```go
import (
  "upper.io/db.v2/lib/sqlbuilder"
)

...
rows, err = sqlDB.Query("SELECT * FROM myTable")

err = sqlbuilder.NewIterator(rows).All(&myRows)
```

The sqlbuilder offers powerful tools and more flexibility when working with
advanced SQL commands, see more examples at
[upper.io/db.v2/lib/sqlbuilder](https://upper.io/db.v2/lib/sqlbuilder).

## Result.OrderBy()

The [db.Result](https://godoc.org/upper.io/db.v2#Result) interface used
to have a `Sort()` method, that method was renamed into `OrderBy()`:

## Transactions

The [db.Database](https://godoc.org/upper.io/db.v2#Database) interface used to
have a `Transaction()` method, this functionality was removed from here and
moved to
[sqlbuilder.Database](https://godoc.org/upper.io/db.v2/lib/sqlbuilder#Database)
as the `NewTx()` method.

```go
tx, err = sess.NewTx()

_, err = tx.Insert(...)

err = tx.Find(...).Update(...)

tx.Commit()
```

Also, a new `Tx()` method was added, you can provide a special
`func(sqlbuilder.Tx) error` function to it and make all operations within that
function run within a transaction:

```go
import (
  "upper.io/db.v2/lib/sqlbuilder"
)

err = sess.Tx(func(tx sqlbuilder.Tx) error {
  _, err = tx.Insert()
  if err != nil {
    return err
  }

  err = tx.Find(...).Update(...)
  if err != nil {
    return err
  }

  return nil
})
```

In this case, you do not need to call Commit or Rollback, the transaction will
be commited automatically if `func(sqlbuilder.Tx) error` returns `nil`,
otherwise the transaction will be rolled back.
