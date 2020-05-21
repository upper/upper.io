# Examples and patterns

# Tips and tricks

## Logging

`upper/db` can be set to print SQL statements and errors to standard output
through the `UPPERIO_DB_DEBUG` environment variable:

```console
UPPERIO_DB_DEBUG=1 ./go-program
// TODO: add example
```

## Underlying driver

In case you require methods that are only available from the underlying driver,
you can use the `db.Database.Driver()` method, which returns an `interface{}`.
For instance, if you need the
[mgo.Session.Ping](http://godoc.org/labix.org/v2/mgo#Session.Ping) method, you
can retrieve the underlying `*mgo.Session` as an `interface{}`, cast it into
the appropriate type, and use `Ping()`, as shown below:

```go
drv = sess.Driver().(*mgo.Session) // The driver is cast into the
                                   // the appropriate type.
err = drv.Ping()
```

You can do the same when working with an SQL adapter by changing the casting:

```go
drv = sess.Driver().(*sql.DB)
rows, err = drv.Query("SELECT name FROM users WHERE age = ?", age)
```

# License (MIT)

> Copyright (c) 2013-today The upper/db authors.
>
> Permission is hereby granted, free of charge, to any person obtaining
> a copy of this software and associated documentation files (the
> "Software"), to deal in the Software without restriction, including
> without limitation the rights to use, copy, modify, merge, publish,
> distribute, sublicense, and/or sell copies of the Software, and to
> permit persons to whom the Software is furnished to do so, subject to
> the following conditions:
>
> The above copyright notice and this permission notice shall be
> included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
> LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
> OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
> WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[1]: https://golang.org
[2]: https://golang.org/doc/install
[3]: /db/mysql
[4]: /db/postgresql
[5]: /db/sqlite
[6]: /db/ql
[7]: /db/mongo
[8]: /db/mssql

### Example: Show all employees

<div>
<textarea class="go-playground-snippet" data-title="Live example: A list of employees">
</textarea>
</div>

## Collections and tables

<div>
<textarea class="go-playground-snippet" data-title="Live example: Dump all books into a slice.">{{ include "webroot/examples/find-map-all-books/main.go" }}</textarea>
</div>

### Mapping only one result

<div>
<textarea class="go-playground-snippet" data-title="Live example: Search for one book.">{{ include "webroot/examples/find-map-one-book/main.go" }}</textarea>
</div>

## Query logger

Use `UPPERIO_DB_DEBUG=1 ./program` to enable the built-in query logger, you'll
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

Besides the `UPPERIO_DB_DEBUG` env, you can enable or disable the built-in
query logger during runtime using `sess.SetLogging`:

```go
sess.SetLogging(true)
```

If you want to do something different with this log, such as reporting query
errors to a different system, you can also provide a custom logger:

```go
type customLogger struct {
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
sess.SetLogging(true)
sess.SetLogger(&customLogger{})
```

If you want to restore the built-in logger set the logger to `nil`:

```go
sess.SetLogger(nil)
```

## SQL builder

The `Find()` method on a collection provides a compatibility layer between SQL
and NoSQL databases, but that might feel short in some situations. That's the
reason why SQL adapters also provide a powerful **SQL query builder**.

This is how you would create a query reference using the SQL builder on a
session:

```go
q := sess.SelectAllFrom("accounts")
...

q := sess.Select("id", "last_name").From("accounts")
...

q := sess.SelectAllFrom("accounts").Where("last_name LIKE ?", "Smi%")
...
```

A query reference also provides the `All()` and `One()` methods from `Result`:

```go
var accounts []Account
err = q.All(&accounts)
...
```

Using the query builder you can express simple queries:

```go
q = sess.Select("id", "name").From("accounts").
  Where("last_name = ?", "Smith").
  OrderBy("name").Limit(10)
```

But even SQL-specific features, like joins, are supported (still depends on the
database, though):

```go
q = sess.Select("a.name").From("accounts AS a").
  Join("profiles AS p").
  On("p.account_id = a.id")

q = sess.Select("name").From("accounts").
  Join("owners").
  Using("employee_id")
```

Sometimes the builder won't be able to represent complex queries, if this
happens it may be more effective to use plain SQL:

```go
rows, err = sess.Query(`SELECT * FROM accounts WHERE id = ?`, 5)
...

row, err = sess.QueryRow(`SELECT * FROM accounts WHERE id = ? LIMIT ?`, 5, 1)
...

res, err = sess.Exec(`DELETE FROM accounts WHERE id = ?`, 5)
...
```

Mapping results from raw queries is also straightforward:

```go
rows, err = sess.Query(`SELECT * FROM accounts WHERE last_name = ?`, "Smith")
...

var accounts []Account
iter := sqlbuilder.NewIterator(rows)
iter.All(&accounts)
...
```

See [builder examples][2] to learn how to master the SQL query builder.

[1]: /db.v3/getting-started
[2]: /db.v3/lib/sqlbuilder
[3]: /db.v3/contribute
