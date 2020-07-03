// List all collections on a database

package main

import (
	"log"

	"github.com/upper/db/adapter/postgresql"
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
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	log.Printf("Collections in database %q:", sess.Name())

	// The Collections method returns references to all the collections in the
	// database.
	collections, err := sess.Collections()
	if err != nil {
		log.Fatal("Collections: ", err)
	}

	for i := range collections {
		// Name returns the name of the collection.
		log.Printf("-> %s", collections[i].Name())
	}
}
