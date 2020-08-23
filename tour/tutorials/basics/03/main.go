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

func main() {
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	// The Collection method returns a reference to a specific collection in the
	// database. In this case, the collection is a table named "books".
	col := sess.Collection("books")

	// Get the name of the collection.
	fmt.Printf("The name of the collection is %q.\n", col.Name())

	// You can create references to collections that don't exist (yet). That
	// might be useful when working with document-based databases.
	nonExistentCollection := sess.Collection("fake")
	ok, err := nonExistentCollection.Exists()
	fmt.Printf("Q: Does collection %q exists?\n", nonExistentCollection.Name())
	fmt.Printf("R: %v (%v)", ok, err)
}
