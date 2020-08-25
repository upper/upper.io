package main

import (
	"log"

	"upper.io/db.v3/postgresql" // Imports the postgresql adapter.
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

	howManyBooks, err := sess.Collection("books").Find().Count()
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("We have %d books in our database.\n", howManyBooks)
}
