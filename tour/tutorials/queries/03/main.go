package main

import (
	"fmt"
	"log"

	"github.com/upper/db/v4/adapter/cockroachdb"
)

var settings = cockroachdb.ConnectionURL{
	Database: `booktown`,
	Host:     `cockroachdb.demo.upper.io`,
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
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close()

	booksTable := sess.Collection("books")

	// Order by "id" (descending)
	res := booksTable.Find().OrderBy("-ID")
	defer res.Close() // Remember to close the result set.

	// Next goes over all items one by one. It proves useful when copying large
	// data sets into a slice is impractical.
	var book Book
	for res.Next(&book) {
		fmt.Printf("%d:\t%q\n", book.ID, book.Title)
	}

	// In the event of a problem Next returns false, that will break the loop and
	// generate an error (which can be retrieved by calling Err). On the other
	// hand, when the loop is successfully completed (even if the data set had no
	// items), Err will be nil.
	if err := res.Err(); err != nil {
		log.Printf("ERROR: %v", err)
		log.Fatalf(`SUGGESTION: change OrderBy("-ID") into OrderBy("id") and try again.`)
	}
}
