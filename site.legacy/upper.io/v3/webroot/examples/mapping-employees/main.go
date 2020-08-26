package main

import (
	"log"

	"github.com/upper/db/postgresql"
)

// Employee defines the mapping between the "employees" table and Go.
type Employee struct {
	ID       int    `db:"id,omitempty"` // Skip `id` column when zero.
	LastName string `db:"last_name"`
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

	req := sess.Collection("employees").Find().OrderBy("last_name")

	log.Println("A list of employees:")

	var employee Employee
	for req.Next(&employee) {
		log.Printf("#%d: %s\n", employee.ID, employee.LastName)
	}
}
