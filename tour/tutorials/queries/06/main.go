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

type Book struct {
	ID        uint   `db:"id"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id"`
	SubjectID uint   `db:"subject_id"`
}

func main() {
	db.Log().SetLevel(db.LogLevelDebug)

	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	booksTable := sess.Collection("books")

	// This result set includes a single record.
	res := booksTable.Find(4267)

	// The record is retrieved with the given ID.
	var book Book
	err = res.One(&book)
	if err != nil {
		log.Fatal("Find: ", err)
	}

	fmt.Printf("Book: %#v", book)

	// A change is made to a property.
	book.Title = "New title"

	fmt.Printf("Book (modified): %#v", book)
	fmt.Println("")

	// The result set is updated.
	if err := res.Update(book); err != nil {
		fmt.Printf("Update: %v\n", err)
		fmt.Printf("This is OK, we're running on a sandbox with a read-only database.\n")
		fmt.Println("")
	}

	// The result set is deleted.
	if err := res.Delete(); err != nil {
		fmt.Printf("Delete: %v\n", err)
		fmt.Printf("This is OK, we're running on a sandbox with a read-only database.\n")
		fmt.Println("")
	}
}
