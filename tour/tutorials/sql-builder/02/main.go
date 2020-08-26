package main

import (
	"fmt"
	"log"

	"github.com/upper/db/v4/adapter/cockroachdb"
)

var settings = cockroachdb.ConnectionURL{
	Database: `booktown`,
	Host:     `cockroachdb.demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

// Book represents a record from the "books" table.
// booktown=> \d books
//       Table "public.books"
//    Column   |  Type   | Modifiers
// ------------+---------+-----------
//  id         | integer | not null
//  title      | varchar | not null
//  author_id  | integer |
//  subject_id | integer |
// Indexes:
//     "books_id_pkey" PRIMARY KEY, btree (id)
//     "books_title_idx" btree (title)
type Book struct {
	ID        uint   `db:"id,omitempty"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id,omitempty"`
	SubjectID uint   `db:"subject_id,omitempty"`
}

// Author represents a record from the "authors" table.
// booktown=> \d authors
//       Table "public.authors"
//    Column   |  Type   | Modifiers
// ------------+---------+-----------
//  id         | integer | not null
//  last_name  | text    |
//  first_name | text    |
// Indexes:
//     "authors_pkey" PRIMARY KEY, btree (id)
type Author struct {
	ID        uint   `db:"id,omitempty"`
	LastName  string `db:"last_name"`
	FirstName string `db:"first_name"`
}

// Subject represents a record from the "subjects" table.
// booktown=> \d subjects
//     Table "public.subjects"
//   Column  |  Type   | Modifiers
// ----------+---------+-----------
//  id       | integer | not null
//  subject  | text    |
//  location | text    |
// Indexes:
//     "subjects_pkey" PRIMARY KEY, btree (id)
type Subject struct {
	ID       uint   `db:"id,omitempty"`
	Subject  string `db:"subject"`
	Location string `db:"location"`
}

func main() {
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	// The BookAuthorSubject type represents an element that has columns from
	// different tables.
	type BookAuthorSubject struct {
		// The book_id column was added to prevent collisions with the other "id"
		// columns from Author and Subject.
		BookID uint `db:"book_id"`

		Book    `db:",inline"`
		Author  `db:",inline"`
		Subject `db:",inline"`
	}

	// This is a query with a JOIN clause that was built using the SQL builder.
	q := sess.SQL().
		Select("b.id AS book_id", "*"). // Note the alias set for book.id.
		From("books AS b").
		Join("subjects AS s").On("b.subject_id = s.id").
		Join("authors AS a").On("b.author_id = a.id").
		OrderBy("a.last_name", "b.title")

	// The JOIN query above returns data from three different tables.
	var books []BookAuthorSubject
	if err := q.All(&books); err != nil {
		log.Fatal("q.All: ", err)
	}

	for _, book := range books {
		fmt.Printf("Book %d:\t%s. %q on %s\n", book.BookID, book.Author.LastName, book.Book.Title, book.Subject.Subject)
	}
}
