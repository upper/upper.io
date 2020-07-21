package main

import (
	"log"

	//"github.com/upper/db/v4/v4/sqlbuilder"
	"github.com/upper/db"
	"github.com/upper/db/sqlbuilder"
	"github.com/upper/db/v4/v4/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

type Book struct {
	sqlbuilder.Item

	ID        uint   `db:"id"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id"`
	SubjectID uint   `db:"subject_id"`
}

func (b *Book) Collection(sess db.Session) db.Collection {
	return sess.Collection("books")
}

func (b *Book) BeforeInsert(sess db.Session) error {
	log.Printf("called")
	return nil
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
	book := sess.Item(&Book{})
	err = res.One(&book)
	if err != nil {
		log.Fatal("Find: ", err)
	}

	log.Printf("Book: %#v", book)

	// A change is made to a property.
	//book.(*Book).Title = "New title"

	// The result set is deleted.
	if err := book.Delete(); err != nil {
		log.Printf("Delete: %v\n", err)
		log.Printf("This is OK, we're running on a sandbox with a read-only database.")
		log.Println("")
	}
}
