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
}

func main() {
	sess, err := cockroachdb.Open(settings)
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

	// The All method copies every single record in the result set into a Go slice.
	fmt.Printf("Records in the %q table:\n", booksTable.Name())
	for _, book := range books {
		fmt.Printf("%d:\t%q\n", book.ID, book.Title)
	}
	fmt.Println("")

	// Find out how many elements the result set has with Count.
	total, err := res.Count()
	if err != nil {
		log.Fatal("Count: ", err)
	}
	fmt.Printf("There are %d records on %q", total, booksTable.Name())
	fmt.Println("")

	// Since result sets are stateless and immutable, they can be reused many
	// times on different queries.
	recordsThatBeginWithP := res.And("title LIKE", "P%") // WHERE ... AND title LIKE 'P%'

	// The original `res` result set is not altered.
	total1, err := res.Count()
	if err != nil {
		log.Fatal("Count: ", err)
	}

	// ... while the new result set is modified.
	total2, err := recordsThatBeginWithP.Count()
	if err != nil {
		log.Fatal("Count: ", err)
	}

	fmt.Printf("There are still %d records on %q\n", total1, booksTable.Name())
	fmt.Printf("And there are %d records on %q that begin with \"P\"\n", total2, booksTable.Name())
}
