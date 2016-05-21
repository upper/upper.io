package main

import (
	"log"

	"database/sql"
	"upper.io/db.v2/postgresql"
)

// Employee defines the mapping between the "employees" table and Go.
type Employee struct {
	ID        int            `db:"id,omitempty"`
	LastName  string         `db:"last_name"`
	FirstName sql.NullString `db:"first_name"` // This field can be nil.
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

	// Check if we have any employee with a NULL name.
	req := sess.Collection("employees").Find().Where("first_name IS NULL")

	var employee Employee
	if err := req.One(&employee); err != nil {
		log.Printf("All employees have a first name!")
		return
	}

	log.Printf("The employee #%d %q has no name (%#v).", employee.ID, employee.LastName, employee)
}
