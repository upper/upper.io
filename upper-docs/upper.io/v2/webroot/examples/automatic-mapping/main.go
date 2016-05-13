package main

import (
	"log"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
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
	for {
		var item Stock
		err := req.Next(&item)
		if err != nil {
			if err == db.ErrNoMoreRows {
				break // This error means that we read all rows from the cursor.
			}
			// Other errors are not expected.
			log.Fatal(err)
		}
		log.Printf("%#v", item)
	}
}
