package main

import (
	"log"

	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

// Book represents a book.
type Book struct {
	ID        uint   `db:"id"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id"`
	SubjectID uint   `db:"subject_id"`
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close()

	var books []Book
	if err := sess.Collection("books").Find().OrderBy("title").All(&books); err != nil {
		log.Fatal(err)
	}

	log.Println("Books:")
	for _, book := range books {
		log.Printf("%q (ID: %d)\n", book.Title, book.ID)
	}
}
