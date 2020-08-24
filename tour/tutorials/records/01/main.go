package main

import (
	"fmt"
	"log"

	"github.com/upper/db/v4"
	"github.com/upper/db/v4/adapter/cockroachdb"
)

var settings = cockroachdb.ConnectionURL{
	Database: `booktown`,
	Host:     `cockroachdb.demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

// Book represents a record from the "books" table.
type Book struct {
	ID        uint   `db:"id,omitempty"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id,omitempty"`
	SubjectID uint   `db:"subject_id,omitempty"`
}

func (book *Book) Store(sess db.Session) db.Store {
	return sess.Collection("books")
}

func (book *Book) BeforeUpdate(sess db.Session) error {
	fmt.Printf("BeforeUpdate was called")
	return nil
}

// Book struct satisfies db.Model
var _ = db.Record(&Book{})

func main() {
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	var book Book

	// Get a book
	err = sess.Get(&book, db.Cond{"title": "The Shining"})
	if err != nil {
		log.Fatal("Get: ", err)
	}

	fmt.Printf("book: %#v\n", book)

	// Change the title
	book.Title = "The Shining (novel)"

	// Persist changes
	err = sess.Save(&book)
	if err != nil {
		// Allow this to fail in the sandbox
		log.Print("Save: ", err)
	}
}
