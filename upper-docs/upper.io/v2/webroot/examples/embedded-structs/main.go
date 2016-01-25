package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

// Person
type Person struct {
	FirstName string `db:"first_name"`
	LastName  string `db:"last_name"`
}

// Author
type Author struct {
	ID     int `db:"id"`
	Person `db:",inline"`
}

// Employee
type Employee struct {
	ID     int `db:"id"`
	Person `db:",inline"`
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

	var res db.Result

	res = sess.C("authors").Find().Sort("last_name").Limit(5)

	var authors []Author
	if err := res.All(&authors); err != nil {
		log.Fatal(err)
	}

	log.Println("Authors (5):")
	for _, author := range authors {
		log.Printf(
			"Last Name: %s\tID: %d\n",
			author.LastName,
			author.ID,
		)
	}

	res = sess.C("employees").Find().Sort("last_name").Limit(5)

	var employees []Author
	if err := res.All(&employees); err != nil {
		log.Fatal(err)
	}

	log.Println("Employees (5):")
	for _, employee := range employees {
		log.Printf(
			"Last Name: %s\tID: %d\n",
			employee.LastName,
			employee.ID,
		)
	}
}
