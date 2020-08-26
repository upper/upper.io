package main

import (
	"log"

	"upper.io/db.v3" // We need this to use db.Raw
	"upper.io/db.v3/postgresql"
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

	req := sess.Select(
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
		log.Printf(
			"Book: %q. ID: %d, Author: %s\n",
			book.Book.Title,
			book.BookID,
			book.Author.LastName,
		)
	}
}
