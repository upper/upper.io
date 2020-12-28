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

// Book represents a record from the "books" table.
type Book struct {
	ID        uint   `db:"id,omitempty"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id,omitempty"`
	SubjectID uint   `db:"subject_id,omitempty"`
}

// Author represents a record from the "authors" table.
type Author struct {
	ID        uint   `db:"id,omitempty"`
	LastName  string `db:"last_name"`
	FirstName string `db:"first_name"`
}

// Subject represents a record from the "subjects" table.
type Subject struct {
	ID       uint   `db:"id,omitempty"`
	Subject  string `db:"subject"`
	Location string `db:"location"`
}

func main() {
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	var eaPoe Author

	// Query, QueryRow, and Exec are raw SQL methods you can use when db.SQL is
	// not enough for the complexity of your query.
	rows, err := sess.SQL().
		Query(`SELECT id, first_name, last_name FROM authors WHERE last_name = ?`, "Poe")
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

	fmt.Printf("%#v", eaPoe)

	// Make sure to use Exec or Query, as the case may be.
	_, err = sess.SQL().
		Exec(`UPDATE authors SET first_name = ? WHERE id = ?`, "Edgar Allan", eaPoe.ID)
	if err != nil {
		fmt.Printf("Query: %v. This is expected on the read-only sandbox\n", err)
	}

	// The sqlbuilder package provides tools for working with raw sql.Rows, such
	// as the NewIterator function.
	rows, err = sess.SQL().
		Query(`SELECT * FROM books LIMIT 5`)
	if err != nil {
		log.Fatal("Query: ", err)
	}

	// The NewIterator function takes a *sql.Rows value and returns an Iterator.
	iter := sess.SQL().NewIterator(rows)

	// This iterator provides methods for going through data, such as All, One,
	// Next, and the like. If you use Next, remember to use Err and Close too.
	var books []Book
	if err := iter.All(&books); err != nil {
		log.Fatal("Query: ", err)
	}

	fmt.Printf("Books: %#v", books)
}
