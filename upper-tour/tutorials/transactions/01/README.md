# Transactions

To create a transaction block, use the `TxContext` method on the SQL database
session.  This method expects a `context.Context` value and a
`func(sqlbuilder.Tx) error` function (which takes a single `sqlbuilder.Tx`
argument and returns an error).

```go
ctx := context.Background()

err := sess.TxContext(ctx, func(tx sqlbuilder.Tx) error {
  ...
})
```

The `ctx` value can be used to cancel and rollback a transaction before it
ends.

The transaction function defines what you want to do within a transaction
context and receives a ready-to-be-used transaction session `tx`. This `tx`
value can be used like a regular `sess`, except that any write operation that
happens on it needs to be either committed or rolled back.

If the passed function returns an error, the transaction gets rolled back:

```go
err := sess.TxContext(ctx, func(tx sqlbuilder.Tx) error {
  ...
  return errors.New("Transaction failed")
})
```

If the passed function returns `nil`, the transaction gets commited:

```go
err := sess.TxContext(ctx, func(tx sqlbuilder.Tx) error {
  ...
  return nil
})
```
