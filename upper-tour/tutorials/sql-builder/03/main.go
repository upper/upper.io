package main

import (
	"log"

	"github.com/upper/db/v4"
	"github.com/upper/db/v4/adapter/postgresql"
)

var settings = postgresql.ConnectionURL{
	Database: `booktown`,
	Host:     `demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

// Book represents an item from the "books" table.
type Book struct {
	ID        uint   `db:"id,omitempty"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id,omitempty"`
	SubjectID uint   `db:"subject_id,omitempty"`
}

// Author represents an item from the "authors" table.
type Author struct {
	ID        uint   `db:"id,omitempty"`
	LastName  string `db:"last_name"`
	FirstName string `db:"first_name"`
}

// Subject represents an item from the "subjects" table.
type Subject struct {
	ID       uint   `db:"id,omitempty"`
	Subject  string `db:"subject"`
	Location string `db:"location"`
}

func main() {
	sess, err := postgresql.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	db.Log().SetLevel(db.LogLevelDebug)

	var eaPoe Author

	// We use sqlbuilder.Selector to retrieve the last name "Poe" from the
	// "authors" table.
	err = sess.SelectFrom("authors").
		Where("last_name", "Poe"). // Or Where("last_name = ?", "Poe")
		One(&eaPoe)
	if err != nil {
		log.Fatal("Query: ", err)
	}
	log.Printf("eaPoe: %#v", eaPoe)

	// We use sqlbuilder.Updater to correct the typo in the name "Edgar Allen".
	res, err := sess.Update("authors").
		Set("first_name = ?", "Edgar Allan"). // Or Set("first_name", "Edgar Allan").
		Where("id = ?", eaPoe.ID).            // Or Where("id", eaPoe.ID)
		Exec()
	if err != nil {
		log.Printf("Query: %v. This is expected on the read-only sandbox", err)
	}

	// We use sqlbuilder.Inserter to add a new book under "Edgar Allan Poe".
	book := Book{
		Title:    "The Crow",
		AuthorID: eaPoe.ID,
	}
	res, err = sess.InsertInto("books").
		Values(book). // Or Columns(c1, c2, c2, ...).Values(v1, v2, v2, ...).
		Exec()
	if err != nil {
		log.Printf("Query: %v. This is expected on the read-only sandbox", err)
	}
	if res != nil {
		id, _ := res.LastInsertId()
		log.Printf("New book id: %d", id)
	}

	// We use sqlbuilder.Deleter to erase the book we've just created (and any
	// other book with the same name).
	q := sess.DeleteFrom("books").
		Where("title", "The Crow")
	log.Printf("Compiled query: %v", q)

	_, err = q.Exec()
	if err != nil {
		log.Printf("Query: %v. This is expected on the read-only sandbox", err)
	}
}
