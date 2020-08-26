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
  "log"

  "github.com/upper/db/v4"
)

func main() {
  ...
  err := sess.Tx(func(tx db.Session) error {
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

    rows, err := tx.SQL().Query(...)
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

See the tour example on [how to use transactions](//tour.upper.io/transactions/01).
