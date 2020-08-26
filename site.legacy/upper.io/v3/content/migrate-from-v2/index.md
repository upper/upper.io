# How to migrate from v2 to v3

## Differences from db.v2

### Go1.7+

`db.v3` will compile under go1.7 but requires go1.8+ to provide support for
query cancelation and timeout (via `context.Context`).

### Support for context.Context

Go1.8+ comes with new `database/sql` features, the ability to pass
`context.Context` is one of them:

```
res, err = sess.QueryContext(ctx, "SELECT * FROM authors")
```

### New import path

The import path was changed from `upper.io/db.v2` into `upper.io/db.v3`.

```go
import (
  ...
  "upper.io/db.v3"
  ...
)
```

### Immutable queries

Queries like:

```go
q := sess.SelectFrom("users")

q.Where(...) // This method modified q's internal state.
```

Used to be valid on `db.v2`. This is not longer the case, starting with `db.v3`
queries are immutable, if you'd like to use variables to compose a query you'll
have to reassign them, like:

```go
q := sess.SelectFrom("users")

q = q.Where(...)

q.And(...) // Nothing happens, the Where() method does not affect q.
```

This is also true for `db.Or`, `db.And` and `db.Result`:

```
q = sess.Collection("peole").Find()

q = q.Where(...)

q.Where() // Nothing happens
```

```go
cond := db.Or(...)

cond = cond.Or(...)
```

In order to help you finding queries that need to be fixed we wrote an special
command line tool:

```
# Install dbcheck
go get -u github.com/upper/cmd/dbcheck

# Use "..." at the end to check all github.com/my/package's subpackages.
dbcheck github.com/my/package/...
```

If you want to see more details, check out our [release
notes](https://github.com/upper/db/releases/tag/v3.0.0).
