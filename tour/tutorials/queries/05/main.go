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
	Password: `demopass`,
}

// Book represents a record from the "books" table. This table has an integer
// primary key ("id"):
//
// booktown=> \d books
//        Table "public.books"
//    Column   |  Type   | Modifiers
// ------------+---------+-----------
//  id         | integer | not null
//  title      | varchar | not null
//  author_id  | integer |
//  subject_id | integer |
// Indexes:
//     "books_id_pkey" PRIMARY KEY, btree (id)
//     "books_title_idx" btree (title)
type Book struct {
	ID        uint   `db:"id"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id"`
	SubjectID uint   `db:"subject_id"`
}

func main() {
	// Set logging level to DEBUG
	db.LC().SetLevel(db.LogLevelDebug)

	sess, err := cockroachdb.Open(settings)
	if err != nil {
		fmt.Println("ERROR: Could not establish a connection with database: %v.", err)
		log.Fatalf(`SUGGESTION: Set password to "demop4ss" and try again.`)
	}
	defer sess.Close()

	fmt.Printf("Connected to %q using %q\n", sess.Name(), sess.ConnectionURL())

	booksTable := sess.Collection("books")

	// Find looks for a record that matches the integer primary key of the
	// "books" table.
	var book Book
	err = booksTable.Find(1).One(&book)
	if err != nil {
		if err == db.ErrNoMoreRows {
			fmt.Printf("ERROR: %v\n", err)
			log.Fatalf("SUGGESTION: Change Find(1) into Find(4267).")
		} else {
			fmt.Printf("ERROR: %v", err)
		}
		log.Fatal("An error ocurred, cannot continue.")
	}

	fmt.Printf("Book: %#v", book)
}
