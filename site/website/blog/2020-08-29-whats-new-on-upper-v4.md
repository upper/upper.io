---
title: What's new in v4
author: xiam
authorURL: https://github.com/xiam
---

We're happy to announce the release of `upper/db` v4. This release is the
culmination of several years of experience (and emotional breakdowns 😜 and
breakthroughs 😎) using Go, SQL databases and APIs of different kinds in
production. We hope you enjoy using `upper/db` as we also enjoy using it,
developing it, and improving it over time.

## New documentation site

You're seeing it! We'll be using [docusaurus](https://docusaurus.io/) for all
documentation-related tasks. Hoping that this change might help us providing
more quality around documentation as well as pull requests with documentation
improvements from the community. [We need your
help](https://github.com/upper/upper.io)!

## The import path changed to `github.com/upper/db/v4`

Now that we have a [clear and widely accepted solution around versioning in
Go](https://blog.golang.org/using-go-modules) we can leave the vanity import
paths behind (e.g.: `upper.io/db.v3`). We moved to a a more familiar
`github.com/upper/db/v4` path, by doing that we also removed the dependency we
had on the `upper.io` domain.

Besides changing the import path, we also made a lot of backwards incompatible
changes to the API. Most of these changes were around `db.Session` (before
`db.Database`). Most changes should be relatively easy to implement, if you're
unsure about how to upgrade a particular method feel free to join our [slack
community](http://upper-io.slack.com/).

## The `sqlbuilder` package is now part of `upper/db`'s core

In v3, we added a special `sqlbuilder` package in an attempt to provide tools
for raw SQL queries.

In v4, that functionality is fully integrated into the `db.Session` interface,
meaning that you won't have to import any extra package in order to get access
to SQL tools.

```go
q, err := sess.SQL().Query("SELECT * FROM ...")
```

See the [SQL](https://pkg.go.dev/github.com/upper/db/v4?tab=doc#SQL) interface.

## Transactions enclosed by functions

In v4, we're fully embracing transaction functions:

```go
err := sess.Tx(func(tx db.Session) error {
  if err := tx.Collection(...); err != nil {
    return err // rollback
  }

  if _, err := tx.SQL().Query(...); err != nil {
    return err // rollback
  }

  return nil // commit
})
```

Transaction functions make it easier for developers to see the whole extent of
all the operations within the transaction as well as controlling when the
transaction is commited (when no error happens) or rolled back (when any error
happens).

We hope this improvement makes it easier to design your application with
database transactions in mind.

## An ORM-like layer

The `bond` package written by [Peter Kieltyka](https://github.com/pkieltyka)
added ORM-like functionality on top of `upper/db` v3. The idea behind `bond` is
now part of `upper/db`'s core. You'll be able to model your application with
some of the most common ORM concepts, like before/after hooks, custom stores,
explicit relations between records and stores, etc.

This feature is completely optional, you'll be able to continue using
`upper/db` with your own patterns as before, if you want to.

See an example of the [db.Record](https://tour.upper.io/records/01) and
[db.Store](https://tour.upper.io/records/02) interfaces.

## A new adapter for CockroachDB (beta)

We've been working closely with the
[CockroachLabs](https://www.cockroachlabs.com/) team to bring you a new adapter
for [CockroachDB](https://www.cockroachlabs.com/product/). The adapter is now
live and we're announcing it as part of the `v4` release. Keep in mind that
this adapter is still in testing phase, we're still working the
[CockroachLabs](https://www.cockroachlabs.com/) team to make sure we're
shipping a quality adapter with great documentation. We'll keep you posted on
this!

## Support and community channels

See our available [community channels](/v4/community)

## Tour

You can get a tease of `upper/db` from your browser, see the
[tour](https://tour.upper.io/welcome/01).

## Special thanks

To [Peter Kieltyka](https://github.com/pkieltyka) Co-Founder of [Horizon
Blockchain Games](https://horizon.io/), for his continuous feedback and support
along all the way. Thank you! It's worth mentioning that Peter's company,
Horizon Games, is also sponsoring the development of the new documentation
site.

To the [CockroachLabs](https://www.cockroachlabs.com/) team for their
sponsorship and feedback on `upper/db`'s development around the CockroachDB
adapter. We're going to have more news on this pretty soon, thank you!

Software development requires love, time and effort, if you'd like to help keep
me more focused on developing software please consider sponsoring [me
(xiam)](https://github.com/sponsors/xiam) on GitHub. Thank you!
