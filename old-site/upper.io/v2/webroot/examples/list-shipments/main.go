package main

import (
	"log"
	"time"

	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

// Shipment represents a shipment registry.
type Shipment struct {
	ID         int       `db:"id,omitempty"`
	CustomerID int       `db:"customer_id"`
	ISBN       string    `db:"isbn"`
	ShipDate   time.Time `db:"ship_date"`
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

	since := time.Date(2001, time.September, 1, 0, 0, 0, 0, time.Local)
	until := time.Date(2001, time.October, 1, 0, 0, 0, 0, time.Local).Add(time.Second * -1)

	req := sess.Collection("shipments").Find().
		Where("ship_date > ? AND ship_date < ?", since, until).
		OrderBy("ship_date")

	log.Printf("Shipments between %v and %v:\n", since, until)

	var shipment Shipment
	for req.Next(&shipment) {
		log.Printf("When: %v, ISBN: %s\n", shipment.ShipDate, shipment.ISBN)
	}
}
