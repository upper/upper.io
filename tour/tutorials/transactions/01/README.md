# Transactions

To create a transaction block, use the `Tx` method provided by `Session`.

```go
import (
  db "github.com/upper/db/v4"
)

err := sess.Tx(func(tx db.Session) error {
  ...
})
```

The passed function defines what you want to do within the transaction, it
receives a ready-to-be-used transactional session. This `tx` value can be used
like a regular `db.Session`, except that any write operation that happens on it
will be either fully committed or discarded (rolled back).

If the passed function returns an error, the transaction gets rolled back:

```go
err := sess.Tx(func(sess db.Session) error {
  ...
  return errors.New("Transaction failed")
})
```

If the passed function returns `nil`, the transaction will be commited:

```go
err := sess.Tx(func(tx db.Session) error {
  ...
  return nil
})
```
