package main

import (
	"log"

	"github.com/upper/db/v4/adapter/cockroachdb"
)

var settings = cockroachdb.ConnectionURL{
	Database: `booktown`,
	Host:     `cockroachdb.demo.upper.io`,
	User:     `demouser`,
	Password: `demop4ss`,
}

type Book struct {
	ID        uint   `db:"id,omitempty"`
	Title     string `db:"title"`
	AuthorID  uint   `db:"author_id,omitempty"`
	SubjectID uint   `db:"subject_id,omitempty"`
}

func main() {
	sess, err := cockroachdb.Open(settings)
	if err != nil {
		log.Fatal("Open: ", err)
	}
	defer sess.Close()

	// The Collection / Find / Result syntax was created with compatibility
	// across all supported databases in mind. However, sometimes it might not be
	// enough for all your needs, especially when working with complex queries.

	// In such a case, you can also use SQLBuilder.
	q := sess.SelectFrom("books")

	// `q` is a `sqlbuilder.Selector`, you can chain any of its other methods
	// that also return `Selector`.
	q = q.OrderBy("title")

	// Note that queries are immutable, here `p` is a completely independent
	// query.
	p := q.Where("title LIKE ?", "P%")

	// Queries are not compiled nor executed until you use methods like `One` or
	// `All`.
	var booksQ, booksP []Book
	if err := q.All(&booksQ); err != nil {
		log.Fatal("q.All: ", err)
	}

	// The `Iterator` method is a way to go through large result sets from top to
	// bottom.
	booksP = make([]Book, 0, len(booksQ))
	iter := p.Iterator()
	var book Book
	for iter.Next(&book) {
		booksP = append(booksP, book)
	}

	// Remember to check for error values at the end of the loop.
	if err := iter.Err(); err != nil {
		log.Fatal("iter.Err: ", err)
	}
	// ... and to free up any locked resources.
	if err := iter.Close(); err != nil {
		log.Fatal("iter.Close: ", err)
	}

	// Listing all books
	log.Printf("All books:")
	for _, book := range booksQ {
		log.Printf("Book %d:\t:%s", book.ID, book.Title)
	}
	log.Println("")

	// Listing books that begin with P
	log.Printf("Books that begin with P:")
	for _, book := range booksP {
		log.Printf("Book %d:\t:%s", book.ID, book.Title)
	}
	log.Println("")
}
