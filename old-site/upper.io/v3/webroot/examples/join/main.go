package main

import (
	"log"

	"upper.io/db.v3"            // Imports the main db package.
	"upper.io/db.v3/postgresql" // Imports the postgresql adapter.
)

// Book represents a book.
type Book struct {
	ID        int    `db:"id"`
	Title     string `db:"title"`
	AuthorID  int    `db:"author_id"`
	SubjectID int    `db:"subject_id"`
}

// Author represents an author.
type Author struct {
	ID        int    `db:"id"`
	LastName  string `db:"last_name"`
	FirstName string `db:"first_name"`
}

// Subject represents a subject.
type Subject struct {
	ID       int    `db:"id"`
	Subject  string `db:"subject"`
	Location string `db:"location"`
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

	type joinResult struct {
		// Note that the ID field is ambiguous, that's why we need this field.
		ID      int `db:"book_id"`
		Book    `db:",inline"`
		Author  `db:",inline"`
		Subject `db:",inline"`
	}

	req := sess.Select(
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
