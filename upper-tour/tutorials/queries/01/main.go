package main

import (
	"log"

	// "github.com/upper/db"
	"github.com/upper/db/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

// Book represents an item from the "books" table. The fields accompanying the
// item represent the columns in the table and are mapped to Go values below.
type Book struct {
	ID        uint   `db:"id,omitempty"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id"`
	SubjectID uint   `db:"subject_id"`

	SkippedField string `db:"-"`
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal("postgresql.Open: ", err)
	}
	defer sess.Close()

	booksCol := sess.Collection("books")

	// Uncomment the following line (and the github.com/upper/db import path) to
	// write SQL statements to os.Stdout:
	// db.Log().SetLevel(db.LogLevelDebug)

	// Find().All() maps all the items from the books collection.
	books := []Book{}
	err = booksCol.Find().All(&books)
	if err != nil {
		log.Fatal("booksCol.Find: ", err)
	}

	// Print the queried information.
	log.Printf("Items in the %q collection:", booksCol.Name())
	for i := range books {
		log.Printf("item #%d: %#v", i, books[i])
	}
}
