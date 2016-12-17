package main

import (
	"log"

	"upper.io/db.v3/postgresql" // Imports the postgresql adapter.
)

const connectDSN = `postgres://demouser:demop4ss@demo.upper.io/booktown`

func main() {
	settings, err := postgresql.ParseURL(connectDSN)
	if err != nil {
		log.Fatal(err)
	}

	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close()

	log.Println("Connection established!")
}
