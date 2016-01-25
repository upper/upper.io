package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

// Employee
type Employee struct {
	ID       int    `db:"id,omitempty"`
	LastName string `db:"last_name"`
}

var settings = postgresql.ConnectionURL{
	Database: `booktown`, // Database name.
	Address:  db.ParseAddress(`demo.upper.io`),
	User:     `demouser`, // Database username.
	Password: `demop4ss`, // Database password.
}

func main() {
	sess, err := db.Open("postgresql", settings)
	if err != nil {
		log.Fatal(err)
	}

	defer sess.Close()

	req := sess.C("employees").Find().Sort("last_name")

	log.Println("A list of employees:")

	for {
		var employee Employee
		err := req.Next(&employee)
		if err != nil {
			if err == db.ErrNoMoreRows {
				break
			}
			log.Fatal(err)
		}
		log.Printf("#%d: %s\n", employee.ID, employee.LastName)
	}
}
