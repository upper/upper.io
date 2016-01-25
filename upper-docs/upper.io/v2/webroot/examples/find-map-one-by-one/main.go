package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`, // Database name.
	Address:  db.ParseAddress(`demo.upper.io`),
	User:     `demouser`, // Database username.
	Password: `demop4ss`, // Database password.
}

// Customer
type Customer struct {
	ID        uint   `db:"id"`
	FirstName string `db:"first_name"`
	LastName  string `db:"last_name"`
}

func main() {
	sess, err := db.Open("postgresql", settings)
	if err != nil {
		log.Fatal(err)
	}

	defer sess.Close()

	res := sess.C("customers").Find().Sort("last_name")
	defer res.Close()

	log.Println("Our customers:")

	for {
		var customer Customer
		if err := res.Next(&customer); err != nil {
			if err != db.ErrNoMoreRows {
				log.Fatal(err)
			}
			break
		}
		log.Printf("%d: %s, %s\n", customer.ID, customer.LastName, customer.FirstName)
	}

}
