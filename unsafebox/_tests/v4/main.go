package main

import (
	_ "github.com/upper/db/v4"
	_ "github.com/upper/db/v4/adapter/cockroachdb"
	_ "github.com/upper/db/v4/adapter/mongo"
	_ "github.com/upper/db/v4/adapter/mssql"
	_ "github.com/upper/db/v4/adapter/mysql"
	_ "github.com/upper/db/v4/adapter/postgresql"
	_ "github.com/upper/db/v4/adapter/ql"
	_ "github.com/upper/db/v4/adapter/sqlite"
)

func main() {

}
