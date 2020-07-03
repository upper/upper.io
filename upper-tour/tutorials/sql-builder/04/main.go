package main

import (
	"log"

	"github.com/upper/db/adapter/postgresql"
	"github.com/upper/db/sqlbuilder"
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

// Book represents an item from the "books" table.
type Book struct {
	ID        uint   `db:"id,omitempty"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id,omitempty"`
	SubjectID uint   `db:"subject_id,omitempty"`
}

// Author represents an item from the "authors" table.
type Author struct {
	ID        uint   `db:"id,omitempty"`
	LastName  string `db:"last_name"`
	FirstName string `db:"first_name"`
}

// Subject represents an item from the "subjects" table.
type Subject struct {
	ID       uint   `db:"id,omitempty"`
	Subject  string `db:"subject"`
	Location string `db:"location"`
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	var eaPoe Author

	// Query, QueryRow, and Exec are raw SQL methods you can use when SQLBuilder
	// is not enough for the complexity of your query.
	rows, err := sess.Query(`SELECT id, first_name, last_name FROM authors WHERE last_name = ?`, "Poe")
	if err != nil {
		log.Fatal("Query: ", err)
	}

	// This is a standard query that mimics the API from database/sql.
	if !rows.Next() {
		log.Fatal("Expecting one row")
	}
	if err := rows.Scan(&eaPoe.ID, &eaPoe.FirstName, &eaPoe.LastName); err != nil {
		log.Fatal("Scan: ", err)
	}
	if err := rows.Close(); err != nil {
		log.Fatal("Close: ", err)
	}

	log.Printf("%#v", eaPoe)

	// Make sure to use Exec or Query, as the case may be.
	_, err = sess.Exec(`UPDATE authors SET first_name = ? WHERE id = ?`, "Edgar Allan", eaPoe.ID)
	if err != nil {
		log.Printf("Query: %v. This is expected on the read-only sandbox", err)
	}

	// The sqlbuilder package provides tools for working with raw sql.Rows, such
	// as the NewIterator function.
	rows, err = sess.Query(`SELECT * FROM books LIMIT 5`)
	if err != nil {
		log.Fatal("Query: ", err)
	}

	// The NewIterator function takes a *sql.Rows value and returns an iterator.
	iter := sqlbuilder.NewIterator(rows)

	// This iterator provides methods for going through data, such as All, One,
	// Next, and the like. If you use Next, remember to use Err and Close too.
	var books []Book
	if err := iter.All(&books); err != nil {
		log.Fatal("Query: ", err)
	}

	log.Printf("Books: %#v", books)
}
