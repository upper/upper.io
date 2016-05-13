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

	log.Println("Connection established!")
}
