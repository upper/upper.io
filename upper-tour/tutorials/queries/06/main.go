package main

import (
	"log"

	"github.com/upper/db"
	"github.com/upper/db/adapter/postgresql"
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
}

func main() {
	db.Log().SetLevel(db.LogLevelDebug)

	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	booksTable := sess.Collection("books")

	// This result set includes a single item.
	res := booksTable.Find(4267)

	// The item is retrieved with the given ID.
	var book Book
	err = res.One(&book)
	if err != nil {
		log.Fatal("Find: ", err)
	}

	log.Printf("Book: %#v", book)

	// A change is made to a property.
	book.Title = "New title"

	log.Printf("Book (modified): %#v", book)
	log.Println("")

	// The result set is updated.
	if err := res.Update(book); err != nil {
		log.Printf("Update: %v\n", err)
		log.Printf("This is OK, we're running on a sandbox with a read-only database.")
		log.Println("")
	}

	// The result set is deleted.
	if err := res.Delete(); err != nil {
		log.Printf("Delete: %v\n", err)
		log.Printf("This is OK, we're running on a sandbox with a read-only database.")
		log.Println("")
	}
}
