package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

const connectDSN = `postgres://demouser:demop4ss@demo.upper.io/booktown`

func main() {
	settings, err := postgresql.ParseURL(connectDSN)
	if err != nil {
		log.Fatal(err)
	}

	sess, err := db.Open("postgresql", settings)
	if err != nil {
		log.Fatal(err)
	}

	defer sess.Close()

	log.Println("Now you're connected to the database!")
}
