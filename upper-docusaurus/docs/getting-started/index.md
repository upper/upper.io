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
* Transactions.
* Mapping between Go structs (or slices of structs) and query results.
* Limit-offset pagination (page numbers).
* Cursor-based pagination (_previous_ and _next_).

$$
package main

import (
	"log"

	"github.com/upper/db/adapter/postgresql"
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

	log.Printf("We have %d books in our database.\n", howManyBooks)
}
$$

There will be times when an agnostic API won't be enough, for those tasks
`upper/db` also provides the `sqlbuilder` which provides a more direct access
to SQL with the additional advantage of using a Go API or raw SQL sentences.

### `sqlbuilder`

The `sqlbuilder` package provides advanced tools that allow developers to generate and
execute SQL statements using a Go API or raw SQL sentences. This package is
only available for SQL databases.

$$
package main

import (
	"log"

	"github.com/upper/db/adapter/postgresql"
	"github.com/upper/db"
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
	q := sess.Select(db.Raw("COUNT(1)")).From("books")

	// Execute a query
	row, err := q.QueryRow()
	if err != nil {
		log.Fatal("Find: ", err)
	}

	// Do what you'd normally do with `database/sql`
	var howMany int
	if err = row.Scan(&howMany); err != nil {
		log.Fatal("Scan: ", err)
	}

	log.Printf("We have %d books in our database.\n", howMany)
}
$$

You can always resort to raw SQL sentences for things that are too complex to
represent with `db` or `sqlbuilder`:

$$
package main

import (
	"log"

	"github.com/upper/db/adapter/postgresql"
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

	// Use raw SQL when you feel like it
	row, err := sess.QueryRow("SELECT COUNT(1) FROM books")
	if err != nil {
		log.Fatal("Find: ", err)
	}

	var howMany int
	if err = row.Scan(&howMany); err != nil {
		log.Fatal("Scan: ", err)
	}

	log.Printf("We have %#v books in our database.\n", howMany)
}
$$

### `bond`

The `bond` package provides an (optional) ORM-like layer for `upper/db` that
allows developers to represent data structures and relationships between them
in a more formal way.

`bond` is ideal for developing with a team, and gives you features like:

* Before(Save|Update|Create|Delete) and After(Save|Update|Create|Delete) hooks.
* Validation hook.
* Primary key integration.
* Separation between the ideas of models and stores.
* All the features `upper/db` already provides.

$$
package main

import (
	"log"

	"github.com/upper/db/bond"
	"github.com/upper/db/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: "booktown",
	Host:     "demo.upper.io",
	User:     "demouser",
	Password: "demop4ss",
}

func main() {
	sess, err := bond.Open(postgresql.Adapter, settings)
	if err != nil {
		log.Fatal("postgresql.Open: ", err)
	}
	defer sess.Close()

	howMany, err := sess.Store("books").Find().Count()
	if err != nil {
		log.Fatal("Find: ", err)
	}

	log.Printf("We have %d books in our database.\n", howMany)
}
$$

## Getting started

* [Key concepts](/docs/getting-started/key-concepts)
* [Connect to a database](/docs/getting-started/connect-to-a-database)
* [Struct mapping](/docs/getting-started/struct-mapping)
* [Using `db`](/docs/getting-started/db-usage)
* Using `sqlbuilder`
* Map structs to columns
* Map structs to query results
* Transactions
* Query logger

## Tutorials

* Structing a `bond` application
* `bond` hooks
