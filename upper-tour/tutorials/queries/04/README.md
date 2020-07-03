# Paginate Results

The pagination API lets you split the results of a query into chunks containing
a maximum number of items.

### Number-based Pagination

You can use numbered pages, for example:

```go
// Create a result-set
res = sess.Collection("posts")

// Set the amount of items by chunk
p := res.Paginate(20)

// Get first chunk of results (page 1)
err = p.All(&posts)

// Get second chunk of results (limit 20, offset 40)
err = p.Page(2).All(&posts)
```

If you're working with the SQL builder, use `SelectFrom` instead of
`Collection`:

```go
q = sess.SelectFrom("posts").Paginate(20)
```

### Cursor-based Pagination

If number-based pagination does not fit your case, you can also set the item
where you want to begin and the results you want to fetch thereon:

```go
res = sess.Collection("posts").
  Paginate(20).
  Cursor("id")

err = res.All(&posts)

// Get the results that follow the last item of the previous
// query in groups of 20.
res = res.NextPage(posts[len(posts)-1].ID)

// Get the first 20 results (limit 20, offset 20)
err = res.All(&posts)
```

### Pagination API Tools

To know the total number of entries and pages into which the result set was
divided, you can use:

```go
res = res.Paginate(23)

totalNumberOfEntries, err = res.TotalEntries()
...

totalNumberOfPages, err = res.TotalPages()
...
```
