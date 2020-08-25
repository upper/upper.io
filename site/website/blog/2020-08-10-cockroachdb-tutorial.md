---
title: CockroachDB adapter
author: xiam
authorURL: https://github.com/xiam
---

The fantastic people at [Cockroach labs](https://www.cockroachlabs.com/) made
it possible for us to work on an adapter for
[CockroachDB](https://www.cockroachlabs.com/product/).

[CockroachDB](https://www.cockroachlabs.com/product/) is a distributed database
that can scale horizontally among different clouds without any special
configuration, if you haven't had the chance to work with it you should
definitelly give it a try!

In this example, we're going to setup a local 3-node cluster, load a sample
database into it and run some queries against these nodes.

In this example, we're going to setup an insecure CockroachDB cluster and
demonstrate how to connect to it.

<!--truncate-->

## Tutorial

### Requisites (insecure cluster)

1. [Install CockroachDB](https://www.cockroachlabs.com/docs/v20.1/install-cockroachdb).
1. Start up a
   [secure](https://www.cockroachlabs.com/docs/v20.1/secure-a-cluster) or
   [insecure](https://www.cockroachlabs.com/docs/v20.1/start-a-local-cluster)
   local cluster.
1. Choose the instructions that correspond to whether your cluster is secure or insecure.

#### Step 1. Install the cockroachdb adapter

To install the `cockroachdb` adapter for `upper/db` run the following command:

```
go get github.com/upper/db/v4/adapter/cockroachdb
```

Note: `upper/db/v4` is still in active development and hasn't been officially
released yet, use this command to preview `v4`:

```
mkdir -p $GOPATH/src/github.com/upper/db
cd $GOPATH/src/github.com/upper/db
git clone https://github.com/upper/db.git v4
cd v4
git checkout v4
```

#### Step 2. Create the `maxroach` user and `bank` database (insecure)

Start the built-in SQL shell:

```
cockroach sql --insecure --database bank
```

In the SQL shell, issue the following statements to create the `maxroach` user
and `bank` database:

```
CREATE USER IF NOT EXISTS maxroach;
CREATE DATABASE bank;
GRANT ALL ON DATABASE bank TO maxroach;
```

#### Step 2. Create the `maxroach` user and `bank` database (secure)

Start the built-in SQL shell:

```
cockroach sql --certs-dir=certs --database bank
```

In the SQL shell, issue the following statements to create the `maxroach` user
and `bank` database:

```
CREATE USER IF NOT EXISTS maxroach;
CREATE DATABASE bank;
GRANT ALL ON DATABASE bank TO maxroach;
```

Create a certificate and key for the maxroach user by running the following
command. The code samples will run as this user.

```
cockroach cert create-client maxroach --certs-dir=certs --ca-key=my-safe-directory/ca.key
```

#### Step 3. Create an `accounts` table

In the SQL shell, issue the following statements to create the `accounts` table
in the `bank` database:

```
CREATE TABLE accounts (ID SERIAL PRIMARY KEY, balance INT);
```

#### Step 4. Run the Go code

Create a minimal `cockroachdb-example.go` file with the following code:


```go
package main

import (
  "fmt"
  "log"

  "github.com/upper/db/v4"
  "github.com/upper/db/v4/adapter/cockroachdb"
)

// The settings variable stores connection details.
var settings = cockroachdb.ConnectionURL{
  Host:     "localhost",
  Database: "bank",
  User:     "maxroach",
  Options: map[string]string{
    // Insecure node.
    "sslmode": "disable",
    // Secure node.
    // "sslrootcert": "certs/ca.crt",
    // "sslkey":      "certs/client.maxroach.key",
    // "sslcert":     "certs/client.maxroach.crt",
  },
}

// Accounts is a handy way to represent a collection.
func Accounts(sess db.Session) db.Store {
  return sess.Collection("accounts")
}

// Account is used to represent a single record in the "accounts" table.
type Account struct {
  ID      uint64 `db:"id,omitempty"`
  Balance int64  `db:"balance"`
}

// Collection is required in order to create a relation between the Account
// struct and the "accounts" table.
func (a *Account) Store(sess db.Session) db.Store {
  return Accounts(sess)
}

// crdbForceRetry can be used to simulate a transaction error and
// demonstrate upper/db's ability to retry the transaction automatically.
//
// By default, upper/db will retry the transaction five times, if you want
// to modify this number use: sess.SetMaxTransactionRetries(n).
//
// This is only used for demonstration purposes.
func crdbForceRetry(sess db.Session) error {
  var err error

  _, err = sess.SQL().Exec(`SELECT NOW()`)
  if err != nil {
    return err
  }

  _, err = sess.SQL().Exec(`SELECT crdb_internal.force_retry('1ms'::INTERVAL)`)
  if err != nil {
    return err
  }

  return nil
}

func main() {
  // Connect to the local CockroachDB node.
  sess, err := cockroachdb.Open(settings)
  if err != nil {
    log.Fatal("cockroachdb.Open: ", err)
  }
  defer sess.Close()

  // Adjust this number to fit your specific needs (set to 5, by default)
  // sess.SetMaxTransactionRetries(10)

  // Delete all the previous items in the "accounts" table.
  err = Accounts(sess).Truncate()
  if err != nil {
    log.Fatal("Truncate: ", err)
  }

  // Create a new account with a balance of 1000.
  account1 := Account{Balance: 1000}
  err = Accounts(sess).InsertReturning(&account1)
  if err != nil {
    log.Fatal("sess.Save: ", err)
  }

  // Create a new account with a balance of 250.
  account2 := Account{Balance: 250}
  err = Accounts(sess).InsertReturning(&account2)
  if err != nil {
    log.Fatal("sess.Save: ", err)
  }

  // Printing records
  printRecords(sess)

  // Change the balance of the first account.
  account1.Balance = 500
  err = sess.Save(&account1)
  if err != nil {
    log.Fatal("sess.Save: ", err)
  }

  // Change the balance of the second account.
  account2.Balance = 999
  err = sess.Save(&account2)
  if err != nil {
    log.Fatal("sess.Save: ", err)
  }

  // Printing records
  printRecords(sess)

  // Delete the first record.
  err = sess.Delete(&account1)
  if err != nil {
    log.Fatal("Delete: ", err)
  }

  // Add a couple of new records within a transaction.
  err = sess.Tx(func(tx db.Session) error {
    var err error

    // Increases the possibility of transaction failure
    _ = crdbForceRetry(tx)

    err = tx.Save(&Account{Balance: 887})
    if err != nil {
      return err
    }

    err = tx.Save(&Account{Balance: 342})
    if err != nil {
      return err
    }

    return nil
  })
  if err != nil {
    log.Fatal("Could not commit transaction: ", err)
  }

  // Printing records
  printRecords(sess)
}

func printRecords(sess db.Session) {
  accounts := []Account{}
  err := Accounts(sess).Find().All(&accounts)
  if err != nil {
    log.Fatal("Find: ", err)
  }
  log.Printf("Balances:")
  for i := range accounts {
    fmt.Printf("\taccounts[%d]: %d\n", accounts[i].ID, accounts[i].Balance)
  }
}
```

And run it against the local CockroachDB node:

```
go run cockroachdb-example.go
```

At the end of the example, you should see something pretty similar to this:

```
Balances:
    accounts[582251161764986881]: 1000
    accounts[582251161912967169]: 250
Balances:
    accounts[582251161764986881]: 500
    accounts[582251161912967169]: 999
Balances:
    accounts[582251161912967169]: 999
    accounts[582251162215874561]: 887
    accounts[582251162262437889]: 342
```

Keep in mind that the example includes a simulation of a transaction failure,
`upper/db` will print a warning in case such failure happens:

```
2020/08/18 08:47:39 upper/db: log_level=WARNING file=/home/rev/go/src/github.com/upper/db/v4/internal/sqladapter/session.go:713
        Query:          INSERT INTO "accounts" ("balance") VALUES ($1) RETURNING "id"
        Arguments:      []interface {}{887}
        Error:          pq: current transaction is aborted, commands ignored until end of transaction block
        Time taken:     0.00047s
        Context:        context.Background
```

## What's next?

Want to know more about CockroachDB?

* See all the [CockroachDB features](https://www.cockroachlabs.com/docs/stable/demo-replication-and-rebalancing.html)
* Take the [upper/db tour](https://tour.upper.io)
