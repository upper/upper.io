---
title: Introduction to upper/db
---

`upper/db` provides a common inteface for developers to work with different SQL
and NoSQL database engines. Its main goal is to provide Go developers with the
right tools that enable them to focus on writing business logic with a
reasonable compromise between productivity, development speed and computing
resources.

Through the use of well-known database drivers, `upper/db` communicates with
the most popular database engines (PostgreSQL, MySQL, CockroachDB, Microsoft
SQLServer, SQLite and MongoDB).

## Packages

### `db`

The `db` package provides an **agnostic Go API** focused on working with
collections of items. This API is modelled after basic set theory concepts that
are applicable to relational and document-based database engines alike.

This API provides you with enough tools for most of the tasks you perform with
a database, such as:

* Basic CRUD (Create, Read, Update and Delete).
* Search and delimitation of result sets.
* Mapping between Go structs (or slices of structs) and query results.
* Limit-offset pagination (page numbers).
* Cursor-based pagination (_previous_ and _next_).
* Transactions.

$$
package main

import (
  "fmt"
  "log"

  "github.com/upper/db/v4/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
  Database: "booktown",
  Host:     "demo.upper.io",
  User:     "demouser",
  Password: "demop4ss",
}

func main() {
  sess, err := postgresql.Open(settings)
  if err != nil {
    log.Fatal("postgresql.Open: ", err)
  }
  defer sess.Close()

  // The `db` API is portable, you can expect code to work the same on
  // different databases
  howManyBooks, err := sess.Collection("books").Find().Count()
  if err != nil {
    log.Fatal("Find: ", err)
  }

  fmt.Printf("We have %d books in our database.\n", howManyBooks)
}
$$

There will be times when an agnostic API won't be enough, for those tasks
`upper/db` also provides a SQL builder interface, which provides a more direct
access to the database with the additional advantage of using a SQL-like Go API
or raw SQL sentences.

$$
package main

import (
  "fmt"
  "log"

  "github.com/upper/db/v4/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
  Database: "booktown",
  Host:     "demo.upper.io",
  User:     "demouser",
  Password: "demop4ss",
}

func main() {
  sess, err := postgresql.Open(settings)
  if err != nil {
    log.Fatal("postgresql.Open: ", err)
  }
  defer sess.Close()

  // Define a query
  row, err := sess.SQL().QueryRow("SELECT COUNT(1) FROM books")
  if err != nil {
    log.Fatal("Find: ", err)
  }

  // Do what you'd normally do with `database/sql`
  var howMany int
  if err = row.Scan(&howMany); err != nil {
    log.Fatal("Scan: ", err)
  }

  fmt.Printf("We have %d books in our database.\n", howMany)
}
$$

### An optional ORM-like interface

`db` provides an (optional) ORM-like layer for `upper/db` that allows
developers to represent data structures and relationships between them in a
more opinionated way.

$$
package main

import (
  "fmt"
  "log"

  "github.com/upper/db/v4/adapter/postgresql"
  "github.com/upper/db/v4"
)

var settings = postgresql.ConnectionURL{
  Database: "booktown",
  Host:     "demo.upper.io",
  User:     "demouser",
  Password: "demop4ss",
}

// Book represents a record from the "books" table.
type Book struct {
  ID        uint   `db:"id,omitempty"`
  Title     string `db:"title"`
  AuthorID  uint   `db:"author_id,omitempty"`
  SubjectID uint   `db:"subject_id,omitempty"`
}

func (*Book) Store(sess db.Session) db.Store {
  return sess.Collection("books")
}

func main() {
  sess, err := postgresql.Open(settings)
  if err != nil {
    log.Fatal("postgresql.Open: ", err)
  }
  defer sess.Close()

  var book Book
  err = sess.Get(&book, db.Cond{"id": 7808})
  if err != nil {
    log.Fatal("Find: ", err)
  }

  fmt.Printf("Book: %#v", book)
}
$$

## Getting started

* [Key concepts](/docs/getting-started/key-concepts)
* [Connect to a database](/docs/getting-started/connect-to-a-database)
* [Mapping database records to Go structs](/docs/getting-started/struct-mapping)
* [Using the agnostic `db` API](/docs/getting-started/agnostic-db-api)
* [Using the SQL builder API](/docs/getting-started/sql-builder-api)
* [Transactions](/docs/getting-started/transactions)
* [Logger](/docs/getting-started/logger)

## Tutorials

* [db.Record, db.Store and hooks](/docs/tutorial/record-store-and-hooks)
