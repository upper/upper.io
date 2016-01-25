package main

import (
	"log"

	"database/sql"
	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

// Employee
type Employee struct {
	ID        int            `db:"id,omitempty"`
	LastName  string         `db:"last_name"`
	FirstName sql.NullString `db:"first_name"` // This field can be nil.
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

	// We have one employee with a NULL name.
	req := sess.C("employees").Find().Where("first_name IS NULL")

	var employee Employee
	if err := req.One(&employee); err != nil {
		log.Fatal(err)
	}

	log.Printf("Employee #%d %q has no name (%#v).", employee.ID, employee.LastName, employee)
}
