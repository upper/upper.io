package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

// Stock
type Stock struct {
	ISBN  string
	Cost  float64
	Real  float64
	Stock int
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

	req := sess.C("stock").Find()

	log.Println("Stock:")

	for {
		var stock Stock
		err := req.Next(&stock)
		if err != nil {
			if err == db.ErrNoMoreRows {
				break
			}
			log.Fatal(err)
		}
		log.Println(stock)
	}
}
