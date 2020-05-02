# Introduction to `upper/db`

`upper/db` provides a common inteface for developers to work with different SQL
and NoSQL database engines. Its main goal is to provide Go developers with the
right tools that enable them to focus on writing business logic with a
reasonable compromise between productivity, development speed and computing
resources.

Through the use of well-known database drivers, `upper/db` communicates with
the most popular database engines (PostgreSQL, MySQL, Microsoft SQLServer,
SQLite and MongoDB) in the particual dialect of each one.

## `upper/db` components

### `db`

The `db` package provides an **agnostic Go API** focused on working with
collections of items. This API is modelled after basic set theory concepts that
are applicable to relational and document-based database engines alike.

This API provides you with enough tools for most of the tasks you perform
with a database, such as:

* Basic CRUD (Create, Read, Update and Delete).
* Search and delimitation of result sets.
* Mapping between Go structs (or slices of structs) and query results.
* Limit-offset pagination (page numbers).
* Cursor-based pagination (_previous_ and _next_).

There will be times when you'll need more than just the basics, for those tasks
we also have the `sqlbuilder`.

`db` is portable, meaning that you can move from one database engine to another
just by changing the adapter.

### `sqlbuilder`

The `sqlbuilder` provides advanced tools that allow developers to generate and
execute SQL statements using a Go API or raw SQL sentences. This package is
only available for SQL databases.

See a few examples:

```
TODO: Add example
```

You can always use raw SQL sentences for things that are too complex to
represent with `sqlbuilder`:

```
TODO: add example
```

### `bond`

`upper/db/bond` provides an (optional) ORM-like layer for `upper/db` that
allows developers to represent data structures and relationships between them
in a more formal way.

`bond` is opinionated and heavily relies on Go structs and interfaces.

* Before and After hooks. // TODO: add examples
* Save()
* Models

Use cases for `bond` are:

* Working with a team.
* Creating a large application.

## Getting started

* Connect to a database
* Struct mapping
* Using `db`
* Using `sqlbuilder`
* Map structs to columns
* Map structs to query results
* Transactions
* Query logger

## Tutorials

* Structing a `bond` application
* `bond` hooks

### Example: List all shipments

$$
package main

import (
	"log"

	"upper.io/db.v3/postgresql" // Imports the postgresql adapter.
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close()

	howManyBooks, err := sess.Collection("books").Find().Count()
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("We have %d books in our database.\n", howManyBooks)
}
$$
