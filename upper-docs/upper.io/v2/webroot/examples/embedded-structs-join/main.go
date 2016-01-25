package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

// Book
type Book struct {
	ID        int    `db:"id"`
	Title     string `db:"title"`
	AuthorID  int    `db:"author_id"`
	SubjectID int    `db:"subject_id"`
}

// Author
type Author struct {
	ID        int    `db:"id"`
	LastName  string `db:"last_name"`
	FirstName string `db:"first_name"`
}

// BookAuthor
type BookAuthor struct {
	// Both Author and Book have and ID column, we need this to tell the ID of
	// the book from that of the author.
	BookID int `db:"book_id"`

	Author `db:",inline"`
	Book   `db:",inline"`
}

var settings = postgresql.ConnectionURL{
	Database: `booktown`, // Database name.
	Address:  db.ParseAddress(`demo.upper.io`),
	User:     `demouser`, // Database username.
	Password: `demop4ss`, // Database password.
}

func main() {
	sess, err := db.Open("postgresql", settings)
	if err != nil {
		log.Fatal(err)
	}

	defer sess.Close()

	b := sess.Builder()

	req := b.Select(
		"b.id AS book_id",
		db.Raw("b.*"),
		db.Raw("a.*"),
	).From("books b").
		Join("authors a").On("b.author_id = a.id").
		OrderBy("b.title")

	iter := req.Iterator()

	var books []BookAuthor

	if err := iter.All(&books); err != nil {
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
