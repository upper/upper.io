package main

import (
	"fmt"
	"log"

	// "github.com/upper/db/v4"
	"github.com/upper/db/v4/adapter/cockroachdb"
)

var settings = cockroachdb.ConnectionURL{
	Database: `booktown`,
	Host:     `cockroachdb.demo.upper.io`,
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

	SkippedField string
}

func main() {
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal("cockroachdb.Open: ", err)
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
	fmt.Printf("Items in the %q collection:\n", booksCol.Name())
	for i := range books {
		fmt.Printf("item #%d: %#v\n", i, books[i])
	}
}
