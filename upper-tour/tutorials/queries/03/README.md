# Query Large Data Sets

If you're working with significantly large data sets, copying all matching
items into a slice might be impractical for memory and performance reasons.

In this case, you might want to use `Next` to map all the items in the
result-set one by one:

```go
res := booksTable.Find().OrderBy("-id")

var book Book
for res.Next(&book) {
  // ...
}
```

`Next` will return `true` until there are no more items left to be read in the
result set.

When handling results one by one, you'll also need to check for errors (with
`Err`) and free locked resources manually (with `Close`).

```go
if err := res.Err(); err != nil {
  ...
}

if err := res.Close(); err != nil {
  ...
}
```

> Calling `Close` is not required when using `One` or `All`.
