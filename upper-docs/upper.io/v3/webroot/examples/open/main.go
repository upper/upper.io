package main

import (
	"log"

	"upper.io/db.v2/postgresql" // Import the postgresql adapter.
)

// Describe the database you want to connect to.
var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

func main() {
	// Establish a connection.
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close() // Close the connection at the end of the program.

	log.Println("Connection established!")
}
