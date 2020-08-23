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

// Book represents an record from the "books" table.
type Book struct {
	ID        uint   `db:"id,omrecordpty"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id,omrecordpty"`
	SubjectID uint   `db:"subject_id,omrecordpty"`
}

// Author represents an record from the "authors" table.
type Author struct {
	ID        uint   `db:"id,omrecordpty"`
	LastName  string `db:"last_name"`
	FirstName string `db:"first_name"`
}

// Subject represents an record from the "subjects" table.
type Subject struct {
	ID       uint   `db:"id,omrecordpty"`
	Subject  string `db:"subject"`
	Location string `db:"location"`
}

func main() {
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	db.Log().SetLevel(db.LogLevelDebug)

	// The `tx` value in the function required by `sess.Tx` is just like `sess`, except
	// it lives within a transaction. This means that if the function returns an
	// error, the transaction will be rolled back.
	err = sess.Tx(func(tx db.Session) error {
		// Anything you set the `tx` variable to execute will be part of the
		// transaction.
		cols, err := tx.Collections()
		if err != nil {
			return err
		}
		fmt.Printf("Cols: %#v\n", cols)

		// The booksTable value is valid only within the transaction.
		booksTable := tx.Collection("books")
		total, err := booksTable.Find().Count()
		if err != nil {
			return err
		}
		fmt.Printf("There are %d records in %s\n", total, booksTable.Name())

		var books []Book
		err = tx.SQL().
			SelectFrom("books").Limit(3).OrderBy(db.Raw("RANDOM()")).All(&books)
		if err != nil {
			return err
		}
		fmt.Printf("Books: %#v\n", books)

		res, err := tx.SQL().
			Query("SELECT * FROM books ORDER BY RANDOM() LIMIT 1")
		if err != nil {
			return err
		}

		var book Book
		err = tx.SQL().NewIterator(res).One(&book)
		if err != nil {
			return err
		}
		fmt.Printf("Random book: %#v\n", book)

		// If the function returns no error the transaction is committed.
		return nil
	})

	if err != nil {
		fmt.Printf("sess.Tx: ", err)
	}
}
