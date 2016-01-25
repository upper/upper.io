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

// Subject
type Subject struct {
	ID       int    `db:"id"`
	Subject  string `db:"subject"`
	Location string `db:"location"`
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

	type joinResult struct {
		// Note that the ID field is ambiguous, that's why we need this field.
		ID      int `db:"book_id"`
		Book    `db:",inline"`
		Author  `db:",inline"`
		Subject `db:",inline"`
	}

	req := b.Select(
		"b.id AS book_id", // See ID field on joinResult type.
		db.Raw("b.*"),
		db.Raw("a.*"),
		db.Raw("s.*"),
	).From("books b").
		Join("authors a").On("b.author_id = a.id").
		Join("subjects s").On("b.subject_id = s.id").
		OrderBy("b.title")

	iter := req.Iterator()

	var books []joinResult

	if err := iter.All(&books); err != nil {
		log.Fatal(err)
	}

	for _, book := range books {
		log.Printf(
			"Book: %q. ID: %d, Author: %s, %s. Subject: %s. Location: %s\n",
			book.Book.Title,
			book.ID,
			book.Author.LastName,
			book.Author.FirstName,
			book.Subject.Subject,
			book.Subject.Location,
		)
	}
}
