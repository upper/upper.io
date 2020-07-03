package main

import (
	"log"

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
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close()

	// "books" is a table that already exists in our database.
	booksTable := sess.Collection("books")

	// Use Find to create a result set (db.Result).
	res := booksTable.Find()

	// The result set can be modified by chaining different db.Result methods
	// (like Where, And, OrderBy, Select Limit, and Group). Keep in mind that
	// db.Result is immutable so you'll probably have to reassign the variable
	// that is holding that object.
	res = res.OrderBy("-title") // ORDER BY title DESC

	// Result sets are lazy, meaning that the query will be built or sent to the
	// database until one of the methods that require database interaction is
	// used (for example, One or All).
	var books []Book
	if err := res.All(&books); err != nil {
		log.Fatal("res.All: ", err)
	}

	// The All method copies every single item in the result set into a Go slice.
	log.Printf("Items in %q table:\n", booksTable.Name())
	for _, book := range books {
		log.Printf("Item %d:\t%q\n", book.ID, book.Title)
	}
	log.Println("")

	// Find out how many elements the result set has with Count.
	total, err := res.Count()
	if err != nil {
		log.Fatal("Count: ", err)
	}
	log.Printf("There are %d items on %q", total, booksTable.Name())
	log.Println("")

	// Since result sets are stateless and immutable, they can be reused many
	// times on different queries.
	itemsThatBeginWithP := res.And("title LIKE", "P%") // WHERE ... AND title LIKE 'P%'

	// The original `res` result set is not altered.
	total1, err := res.Count()
	if err != nil {
		log.Fatal("Count: ", err)
	}

	// ... while the new result set is modified.
	total2, err := itemsThatBeginWithP.Count()
	if err != nil {
		log.Fatal("Count: ", err)
	}

	log.Printf("There are still %d items on %q", total1, booksTable.Name())
	log.Printf("And there are %d items on %q that begin with \"P\"", total2, booksTable.Name())
}
