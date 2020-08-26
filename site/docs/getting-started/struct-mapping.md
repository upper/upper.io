---
title: Struct mapping
---

The typical starting point with `upper/db` is writing Go structs that define a
mapping between your Go application and the database it uses.

## Basic field-to-column mapping

Fields in Go structs can be mapped to table records by using a special `db`
struct tag:

```go
type User struct {
  Name `db:"name"`
}
```

add the `omitempty` tag option to struct fields that you don't want to send to
the database if they don't have a value, like IDs that are set to
auto-increment (or auto-generate) themselves:

```go
// Person represents an item from the "people" collection.
type Person struct {
  ID       uint64 `db:"id,omitempty"` // Use `omitempty` for fields
                                      // that are not to be sent by
                                      // the adapter when empty.
  Name     string `db:"name"`
  LastName string `db:"last_name"`
}

// Employee represents an item from the "employees" collection.
type Employee struct {
  ID         uint64         `db:"id,omitempty"` // Skip `id` column when zero.
  FirstName  sql.NullString `db:"first_name"`
  LastName   string         `db:"last_name"`
}
```

You can provide different values in struct tags, including those used to map
JSON values to fields:

```go
type Person struct {
  ID        uint64 `db:"id,omitempty" json:"id"`
  Name      string `db:"name" json:"name"`
  ...
  Password  string `db:"password,omitempty" json:"-"`
}
```

Fields that don't have a `db` struct tag will be omitted from queries:

```go
type Person struct {
  ...
  Token    string
}
```

## Complex cases for mapping

### Embedding structs

Using the `inline` option you can embed structs into other structs. See this
`Person` struct, for instance:

```go
type Person struct {
  FirstName string `db:"first_name"`
  LastName  string `db:"last_name"`
}
```

This is a common struct that can be shared with other structs which also need
`FirstName` and `LastName`:

```go
type Author struct {
  ID     int  `db:"id,omitempty"`

  Person      `db:",inline"` // Embedded Person
}

type Employee struct {
  ID     int  `db:"id,omitempty"`

  Person      `db:",inline"` // Embedded Person
}
```

See the following example: embedding `Person` struct into `Author` and `Employee`

$$
package main

import (
  "fmt"
  "log"

  "github.com/upper/db/v4"
  "github.com/upper/db/v4/adapter/postgresql"
)

// Person represents a person with a name.
type Person struct {
  FirstName string `db:"first_name"`
  LastName  string `db:"last_name"`
}

// Author represents a person that is an author.
type Author struct {
  ID     int `db:"id"`
  Person `db:",inline"`
}

// Employee represents a person that is an employee.
type Employee struct {
  ID     int `db:"id"`
  Person `db:",inline"`
}

func Authors(sess db.Session) db.Collection {
  return sess.Collection("authors")
}

func Employees(sess db.Session) db.Collection {
  return sess.Collection("employees")
}

var settings = postgresql.ConnectionURL{
  Database: `booktown`,
  Host:     `demo.upper.io`,
  User:     `demouser`,
  Password: `demop4ss`,
}

func main() {
  sess, err := postgresql.Open(settings)
  if err != nil {
    log.Fatal("Open: ", err)
  }
  defer sess.Close()

  // Get and print the first 5 authors ordered by last name
  res := Authors(sess).Find().
    OrderBy("last_name").
    Limit(5)

  var authors []Author
  if err := res.All(&authors); err != nil {
    log.Fatal("All: ", err)
  }

  fmt.Println("Authors (5):")
  for _, author := range authors {
    fmt.Printf(
      "Last Name: %s\tID: %d\n",
      author.LastName,
      author.ID,
    )
  }

  fmt.Println("")

  // Get and print the first 5 employees ordered by last name
  res = Employees(sess).Find().
    OrderBy("last_name").
    Limit(5)

  var employees []Author
  if err := res.All(&employees); err != nil {
    log.Fatal("All: ", err)
  }

  fmt.Println("Employees (5):")
  for _, employee := range employees {
    fmt.Printf(
      "Last Name: %s\tID: %d\n",
      employee.LastName,
      employee.ID,
    )
  }
}
$$

### Solving mapping ambiguities on JOINs

The previous example will work as long as you use the `db:",inline"` tag. You
can even embed more than one struct into another, but you should be careful
with column ambiguities:

```go
// Book that has ID.
type Book struct {
  ID        int    `db:"id"` // Has an ID column.
  Title     string `db:"title"`
  AuthorID  int    `db:"author_id"`
  SubjectID int    `db:"subject_id"`
}

// Author that has ID.
type Author struct {
  ID        int    `db:"id"` // Also has an ID column.
  LastName  string `db:"last_name"`
  FirstName string `db:"first_name"`
}
```

Embedding these two structs into a third one will cause a conflict of IDs, to
solve this conflict you can add an extra `book_id` column mapping and use a
`book_id` alias when querying for the book ID.

```go
// BookAuthor
type BookAuthor struct {
  // Both Author and Book have and ID column, we need this extra field to tell
  // the difference between the ID of the book and the ID of the author.
  BookID int `db:"book_id"`

  Author `db:",inline"`
  Book   `db:",inline"`
}
```

$$
package main

import (
  "fmt"
  "log"

  "github.com/upper/db/v4"
  "github.com/upper/db/v4/adapter/postgresql"
)

// Book represents a book.
type Book struct {
  ID        int    `db:"id"`
  Title     string `db:"title"`
  AuthorID  int    `db:"author_id"`
  SubjectID int    `db:"subject_id"`
}

// Author represents the author of a book.
type Author struct {
  ID        int    `db:"id"`
  LastName  string `db:"last_name"`
  FirstName string `db:"first_name"`
}

// BookAuthor represents join data from books and authors.
type BookAuthor struct {
  // Both Author and Book have and ID column, we need this to tell the ID of
  // the book from the ID of the author.
  BookID int `db:"book_id"`

  Author `db:",inline"`
  Book   `db:",inline"`
}

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

  req := sess.SQL().
    Select(
    "b.id AS book_id",
    db.Raw("b.*"),
    db.Raw("a.*"),
  ).From("books b").
    Join("authors a").On("b.author_id = a.id").
    OrderBy("b.title")

  var books []BookAuthor
  if err := req.All(&books); err != nil {
    log.Fatal(err)
  }

  for _, book := range books {
    fmt.Printf(
      "ID: %d\tAuthor: %s\t\tBook: %q\n",
      book.BookID,
      book.Author.LastName,
      book.Book.Title,
    )
  }
}
$$
