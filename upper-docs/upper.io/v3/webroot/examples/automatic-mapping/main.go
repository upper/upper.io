package main

import (
	"log"

	"upper.io/db.v3/postgresql" // Imports the postgresql adapter.
)

// Stock represents items in stock.
type Stock struct {
	ISBN   string  `db:"isbn"`
	Cost   float64 `db:"cost"`
	Retail float64 `db:"retail"`
	Stock  int     `db:"stock"`
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

	req := sess.Collection("stock").Find()

	log.Println("Items in stock:")
	var item Stock
	for req.Next(&item) {
		log.Printf("%#v", item)
	}
}
