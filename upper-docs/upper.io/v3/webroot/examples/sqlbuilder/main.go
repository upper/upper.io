package main

import (
	"log"

	"upper.io/db.v3/postgresql" // Imports the postgresql adapter.
)

// Book represents a book.
type Book struct {
	ID        int    `db:"id"`
	Title     string `db:"title"`
	AuthorID  int    `db:"author_id"`
	SubjectID int    `db:"subject_id"`
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

	req := sess.SelectFrom("books").OrderBy("id")

	var books []Book
	iter := req.Iterator()
	if err := iter.All(&books); err != nil {
		log.Fatal(err)
	}

	log.Printf("A list of books:")
	for _, book := range books {
		log.Printf("%#v\n", book)
	}
}
