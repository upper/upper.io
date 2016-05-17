package main

import (
	"log"

	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close()

	tx, err := sess.Transaction()
	if err != nil {
		log.Fatal(err)
	}

	// You can simply exchange sess by tx.
	var total uint64

	if total, err = tx.Collection("books").Find().Count(); err != nil {
		log.Fatal(err)
	}
	log.Printf("total: %d", total)

	// This won't work in our testing sandbox, you'll have to try it out by yourself.
	// if err = tx.Collection("books").Find().Delete(); err != nil {
	//   log.Fatal(err)
	// }

	// Use Commit() to make your changes permanent and Rollback() to discard them.
	if err := tx.Rollback(); err != nil {
		log.Fatal(err)
	}

	if total, err = sess.Collection("books").Find().Count(); err != nil {
		log.Fatal(err)
	}
	log.Printf("total after rolling back: %d", total)
}
