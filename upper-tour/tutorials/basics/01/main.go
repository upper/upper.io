// How to connect to a database

package main

import (
	"log"

	// Import an adapter
	"github.com/upper/db/adapter/postgresql"
)

// Set the database credentials using the ConnectionURL type provided by the
// adapter.
var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

func main() {
	// Use Open to access the database.
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	// The settings variable has a String method that builds and returns a valid
	// DSN. This DSN may be different depending on the database you're connecting
	// to.
	log.Printf("Connected to %q with DSN: %q", sess.Name(), settings)
}
