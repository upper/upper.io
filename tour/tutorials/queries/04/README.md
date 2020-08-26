# Paginate results

The pagination API lets you split the results of a query into chunks containing
a maximum number of records.

### Number-based pagination

Number-based pagination splits the results into a fixed number of pages:

```go
// Create a result-set
res = sess.Collection("posts")

// Set the amount of records by chunk
p := res.Paginate(20)

// Get first chunk of results (page 1)
err = p.All(&posts)

// Get second chunk of results (limit 20, offset 40)
err = p.Page(2).All(&posts)
```

If you're working with the SQL builder, use `SelectFrom` instead of
`Collection`:

```go
q = sess.SQL().SelectFrom("posts").Paginate(20)
```

### Cursor-based pagination

If number-based pagination does not fit your case, you can also set the record
where you want to begin and the results you want to fetch thereon:

```go
res = sess.Collection("posts").
  Paginate(20).
  Cursor("id")

err = res.All(&posts)

// Get the results that follow the last record of the previous
// query in groups of 20.
res = res.NextPage(posts[len(posts)-1].ID)

// Get the first 20 results (limit 20, offset 20)
err = res.All(&posts)
```

### Pagination API tools

To know the total number of entries and pages into which the result set was
divided, you can use:

```go
res = res.Paginate(23)

totalNumberOfEntries, err = res.TotalEntries()
...

totalNumberOfPages, err = res.TotalPages()
...
```
