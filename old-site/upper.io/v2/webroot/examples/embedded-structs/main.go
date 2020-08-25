package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

// Person represents a person with a name.
type Person struct {
	FirstName string `db:"first_name"`
	LastName  string `db:"last_name"`
}

// Author represents a person that is an author.
type Author struct {
	ID     int `db:"id"`
	Person `db:",inline"`
}

// Employee represents a person that is an employee.
type Employee struct {
	ID     int `db:"id"`
	Person `db:",inline"`
}

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

	var res db.Result

	res = sess.Collection("authors").Find().OrderBy("last_name").Limit(5)

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

	res = sess.Collection("employees").Find().OrderBy("last_name").Limit(5)

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
