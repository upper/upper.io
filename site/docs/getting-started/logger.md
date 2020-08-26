---
title: Logging
---

`upper/db` can be set to print SQL statements and errors to standard output
through the `UPPER_DB_LOG` environment variable:

```console
UPPER_DB_LOG=DEBUG ./go-program
```

Use `UPPER_DB_LOG=$LOG_LEVEL ./program` to enable the built-in query logger at
the desired logging level, you'll see the generated SQL queries and the result
from their execution printed to `stdout`.

```
2020/08/26 00:05:44 upper/db: log_level=DEBUG file=/go/src/github.com/upper/db/v4/internal/sqladapter/session.go:648
  Session ID:     00001
  Query:          SELECT "pg_attribute"."attname" AS "pkey" FROM "pg_index", "pg_class", "pg_attribute" WHERE (pg_class.oid = '"books"'::regclass AND indrelid = pg_class.oid AND pg_attribute.attrelid = pg_class.oid AND pg_attribute.attnum = ANY(pg_index.indkey) AND indisprimary) ORDER BY "pkey" ASC
  Time taken:     0.02538s
  Context:        context.Background

2020/08/26 00:05:44 upper/db: log_level=DEBUG file=/go/src/github.com/upper/db/v4/internal/sqladapter/session.go:648
  Session ID:     00001
  Query:          SELECT * FROM "books" WHERE ("id" = $1)
  Arguments:      []interface {}{1}
  Time taken:     0.00317s
  Context:        context.Background
...
```

These are the logging levels `upper/db` comes with, ranging from the lowest
severity (trace) to the highest (panic).

* `db.LogLevelTrace` (`UPPER_DB_LOG=TRACE`)
* `db.LogLevelDebug` (`UPPER_DB_LOG=DEBUG`)
* `db.LogLevelInfo` (`UPPER_DB_LOG=INFO`)
* `db.LogLevelWarn` (`UPPER_DB_LOG=WARN`)
* `db.LogLevelError` (`UPPER_DB_LOG=ERROR`)
* `db.LogLevelFatal` (`UPPER_DB_LOG=FATAL`)
* `db.LogLevelPanic` (`UPPER_DB_LOG=PANIC`)

By default, `upper/db` is set to `db.LogLevelWarn`. Use `db.LC().SetLevel()` to
set a different logging level:

```go
db.LC().SetLevel(db.LogLevelDebug) // or UPPER_DB_LOG=DEBUG
```

Use `sess.SetLogger` to overwrite the built-in logger:

```go
sess.LC().SetLogger(&customLogger{})
```

for instance:

```go
import "github.com/sirupsen/logrus"
// ...

db.LC().SetLogger(logrus.New())
```

If you want to restore the built-in logger set the logger to `nil`:

```go
sess.LC().SetLogger(nil)
```


Make sure to set an appropriate logging level in production, as using levels
lower than `db.LogLevelWarn` could make things pretty slow and verbose.

```go
db.LC().SetLevel(db.LogLevelError)
```
