package main

import (
	"log"
	"time"

	"upper.io/db.v2"            // Imports the main db package.
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

// Shipment
type Shipment struct {
	ID         int       `db:"id,omitempty"`
	CustomerID int       `db:"customer_id"`
	ISBN       string    `db:"isbn"`
	ShipDate   time.Time `db:"ship_date"`
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

	since := time.Date(2001, time.September, 1, 0, 0, 0, 0, time.Local)
	until := time.Date(2001, time.October, 1, 0, 0, 0, 0, time.Local).Add(time.Second * -1)

	req := sess.C("shipments").Find().
		Where("ship_date > ? AND ship_date < ?", since, until).
		Sort("ship_date")

	log.Printf("Shipments between %v and %v:\n", since, until)

	for {
		var shipment Shipment
		err := req.Next(&shipment)
		if err != nil {
			if err == db.ErrNoMoreRows {
				break
			}
			log.Fatal(err)
		}
		log.Printf("When: %v, ISBN: %s\n", shipment.ShipDate, shipment.ISBN)
	}
}
