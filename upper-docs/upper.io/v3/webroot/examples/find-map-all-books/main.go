package main

import (
	"log"

	"upper.io/db.v3/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

// Book represents an element from the "books" table, column names are mapped
// to Go values.
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

	// Set this to true to enable the query logger which will print all SQL
	// statements to stdout.
	sess.SetLogging(false)

	// Define a result set without passing a condition to Find(), this means we
	// want to match all the elements on the books table.
	res := sess.Collection("books").Find()

	// We can use this res object later in different queries, here we'll use it
	// to fetch all the books on our catalog in descending order.
	var books []Book
	if err := res.OrderBy("title DESC").All(&books); err != nil {
		log.Fatal(err)
	}

	// The books slice has been populated!
	log.Println("Books:")
	for _, book := range books {
		log.Printf("%q (ID: %d)\n", book.Title, book.ID)
	}
}
