package main

import (
	"log"

	"upper.io/db.v2/lib/sqlbuilder"
	"upper.io/db.v2/postgresql" // Imports the postgresql adapter.
)

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

	err = sess.Tx(func(tx sqlbuilder.Tx) error {
		// Use tx like you would normally use sess:
		total, err := tx.Collection("books").Find().Count()
		if err != nil {
			return err
		}
		log.Printf("total within tx: %d", total)

		// This won't work on our testing sandbox, you'll have to try it out on a local env.
		// if err = tx.Collection("books").Find().Delete(); err != nil {
		//   return err
		// }
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}

	total, err := sess.Collection("books").Find().Count()
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("total outside tx: %d", total)
}
