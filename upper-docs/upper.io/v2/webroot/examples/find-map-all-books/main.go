package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`, // Database name.
	Address:  db.ParseAddress(`demo.upper.io`),
	User:     `demouser`, // Database username.
	Password: `demop4ss`, // Database password.
}

// Book
type Book struct {
	ID        uint   `db:"id"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id"`
	SubjectID uint   `db:"subject_id"`
}

func main() {
	sess, err := db.Open("postgresql", settings)
	if err != nil {
		log.Fatal(err)
	}

	defer sess.Close()

	var books []Book
	if err := sess.C("books").Find().Sort("title").All(&books); err != nil {
		log.Fatal(err)
	}

	log.Println("Books:")
	for _, book := range books {
		log.Printf("%q (ID: %d)\n", book.Title, book.ID)
	}
}
