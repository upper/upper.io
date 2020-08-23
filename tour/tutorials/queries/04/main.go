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

type Customer struct {
	ID        uint   `db:"id"`
	FirstName string `db:"first_name"`
	LastName  string `db:"last_name"`
}

func main() {
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal(err)
	}
	defer sess.Close()

	customersCol := sess.Collection("customers")

	// Create a paginator and sets 10 items by page.
	res := customersCol.Find().
		OrderBy("last_name", "first_name")

	p := res.Paginate(10)

	// Try changing the page number and running the example
	const pageNumber = 2

	// Copy all the items from the current page into the customers slice.
	var customers []Customer
	err = p.Page(pageNumber).All(&customers)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("List of costumers (page %d):\n", pageNumber)
	for i, customer := range customers {
		fmt.Printf("%d: %q, %q\n", i, customer.LastName, customer.FirstName)
	}

	totalNumberOfEntries, err := p.TotalEntries()
	if err != nil {
		log.Fatal("p.TotalEntries: ", err)
	}

	totalNumberOfPages, err := p.TotalPages()
	if err != nil {
		log.Fatal("p.TotalPages: ", err)
	}

	fmt.Println("")
	fmt.Printf("Total entries: %d. Total pages: %d", totalNumberOfEntries, totalNumberOfPages)
}
