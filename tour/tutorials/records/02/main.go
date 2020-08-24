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

type BooksStore struct {
	db.Collection
}

func (books *BooksStore) GetBookByTitle(title string) (*Book, error) {
	var book Book
	if err := books.Find(db.Cond{"title": title}).One(&book); err != nil {
		return nil, err
	}
	return &book, nil
}

func Books(sess db.Session) *BooksStore {
	return &BooksStore{sess.Collection("books")}
}

// Book represents a record from the "books" table.
type Book struct {
	ID        uint   `db:"id,omitempty"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id,omitempty"`
	SubjectID uint   `db:"subject_id,omitempty"`
}

func (book *Book) Store(sess db.Session) db.Store {
	return Books(sess)
}

func (book *Book) BeforeUpdate(sess db.Session) error {
	fmt.Println("**** BeforeUpdate was called ****")
	return nil
}

func (book *Book) AfterUpdate(sess db.Session) error {
	fmt.Println("**** AfterUpdate was called ****")
	return nil
}

// Interface checks
var _ = interface {
	db.Record
	db.BeforeUpdateHook
	db.AfterUpdateHook
}(&Book{})

var _ = interface {
	db.Store
}(&BooksStore{})

func main() {
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	// Get a book
	book, err := Books(sess).GetBookByTitle("The Shining")
	if err != nil {
		log.Fatal("Get: ", err)
	}

	fmt.Printf("book: %#v\n", book)

	// Change the title
	book.Title = "The Shining (novel)"

	// Persist changes
	err = sess.Save(book)
	if err != nil {
		// Allow this to fail in the sandbox
		log.Print("Save: ", err)
	}
}
