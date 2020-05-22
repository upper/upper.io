---
title: Logging
---

`upper/db` can be set to print SQL statements and errors to standard output
through the `UPPER_DB_DEBUG` environment variable:

```console
UPPER_DB_DEBUG=1 ./go-program
// TODO: add example
```

Use `UPPER_DB_DEBUG=1 ./program` to enable the built-in query logger, you'll
see the generated SQL queries and the result from their execution printed to
`stdout`.

```
2016/10/04 19:14:28
	Session ID:     00003
	Query:          SELECT "pg_attribute"."attname" AS "pkey" FROM "pg_index", "pg_class", "pg_attribute" WHERE ( pg_class.oid = '"option_types"'::regclass AND indrelid = pg_class.oid AND pg_attribute.attrelid = pg_class.oid AND pg_attribute.attnum = ANY(pg_index.indkey) AND indisprimary ) ORDER BY "pkey" ASC
	Time taken:     0.00314s

2016/10/04 19:14:28
	Session ID:     00003
	Query:          TRUNCATE TABLE "option_types" RESTART IDENTITY
	Rows affected:  0
	Time taken:     0.01813s

...
```

Besides the `UPPER_DB_DEBUG` env, you can enable or disable the built-in
query logger during runtime using `sess.SetLogging`:

```go
sess.SetLogging(true)
```

If you want to do something different with this log, such as reporting query
errors to a different system, you can also provide a custom logger:

```go
type customLogger struct {
  ...
}

func (*customLogger) Log(q *db.QueryStatus) {
  switch q.Err {
  case nil, db.ErrNoMoreRows:
    return // Don't log successful queries.
  }
  // Alert of any other error.
  loggingsystem.ReportError("Unexpected database error: %v\n%s", q.Err, q.String())
}
```

Use `sess.SetLogger` to overwrite the built-in logger:

```go
sess.SetLogger(&customLogger{})
```

If you want to restore the built-in logger set the logger to `nil`:

```go
sess.SetLogger(nil)
```

