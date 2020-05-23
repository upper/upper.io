---
title: Transactions
---

Transactions are special operations that you can carry out with the guarantee
that if one fails the whole batch fails. The typical example on transactions is
a bank operation in which you want to move money from one account to another
without worrying about a power failure or a write error in the middle of a
transaction that would create an inconsistency.

You can create and use transaction blocks with the `Tx` method:

```go
import (
  "context"
  "log"

  "github.com/upper/db"
  "github.com/upper/db/sqlbuilder"
)

func main() {
  ...
  err := sess.Tx(func(tx sqlbuilder.Tx) error {
    // Use `tx` like you would normally use `sess`.
    ...
    id, err := tx.Collection("accounts").Insert(...)
    if err != nil {
      // Rollback the transaction by returning an error value.
      return err
    }
    ...

    err := tx.Collection("accounts").Update(...)
    if err != nil {
      // Rollback the transaction by returning an error value.
      return err
    }
    ...

    rows, err := tx.Query(...)
    ...

    ...
    // Commit the transaction by returning `nil`.
    return nil
  })
  if err != nil {
    log.Fatal("Transaction failed: ", err)
  }
}
```

### Manual transactions

Alternatively, you can also request a transaction context and manage it
yourself using the `NewTx` method:

```go
tx, err := sess.NewTx(ctx)
...
```

Use `tx` as you would normally use `sess`:

```go
id, err = tx.Collection("accounts").Insert(...)
...

res = tx.Collection("accounts").Find(...)

err = res.Update(...)
...

```

Remember that in order for your changes to be permanent, you'll have to use the
`Commit()` method:

```go
err = tx.Commit() // or tx.Rollback()
...
```

If you want to cancel the whole operation, use `Rollback()`.

There is no need to `Close()` the transaction, after commiting or rolling back
the transaction gets closed and it's no longer valid.
