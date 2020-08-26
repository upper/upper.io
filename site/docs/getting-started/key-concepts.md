---
title: Key concepts
---

Through this documentation you'll find a few special concepts, the most
important are the ones defined below:

**session**: a representation of an established connection with a database.

**collection**: a set of items that belong to a concrete SQL _table_ or a
NoSQL _collection_.

> The term 'collection' is used indistinctively by methods that work on both
> SQL and NoSQL databases.

**result set**: a subset of items in a collection that match specific
conditions. It is retrieved with `Find()`. The whole result set can be
delimited or modified through different methods, like `Update()`, `Delete()`,
`Insert()`, `All()`, or `One()`.

The figure below ilustrates the session, collection, and result-set concepts:

<center>
![session collections and results](/img/session-collection-result.png)
</center>

## General considerations

In order to use `upper/db` efficiently, it is advisable that you:

1. Understand the database you're working with (relational or
   document-oriented)
1. Use Go structs to describe data models. One struct per collection is a good
   practice.
1. Try to use `db.Collection` methods applicable to both SQL and NoSQL first.
1. Use the SQL builder or raw SQL only when needed.
