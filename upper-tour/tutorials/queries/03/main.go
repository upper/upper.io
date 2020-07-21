package main

import (
	"log"

	"github.com/upper/db/v4/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

type Book struct {
	ID        uint   `db:"id"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id"`
	SubjectID uint   `db:"subject_id"`

	IgnoredField string `db:"-"`
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close()

	booksTable := sess.Collection("books")

	// Order by "id" (descending)
	res := booksTable.Find().OrderBy("-ud")

	// Next goes over all items one by one. It proves useful when copying large
	// data sets into a slice is impractical.
	var book Book
	for res.Next(&book) {
		log.Printf("Book %d:\t%#v", book.ID, book)
	}

	// In the event of a problem Next returns false, that will break the loop and
	// generate an error (which can be retrieved by calling Err). On the other
	// hand, when the loop is successfully completed (even if the data set had no
	// items), Err will be nil.
	if err := res.Err(); err != nil {
		log.Printf("ERROR: %v", err)
		log.Fatalf(`SUGGESTION: change OrderBy("-ud") into OrderBy("id") and try again.`)
	}

	// Remember to close the database and free any locked resources.
	if err := res.Close(); err != nil {
		log.Fatal("Close: ", err)
	}
}
