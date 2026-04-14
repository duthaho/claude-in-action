# Library queries — by MCP tool

## Tools

The SQLite MCP server we wired advertises five tools:

- `list_tables` — returns the list of tables in the database.
- `describe_table(name)` — returns a table's column names and types.
- `read_query(sql)` — runs a `SELECT` and returns rows.
- `write_query(sql)` — runs an `INSERT`/`UPDATE`/`DELETE`. (Available in some packages; omit if your chosen server doesn't expose it.)
- `create_table(sql)` — runs a `CREATE TABLE`. (Same caveat.)

For this lab I will only use `list_tables`, `describe_table`, and `read_query`. The write-capable tools are a foothold I don't want in a session that only needs to answer questions.

## Queries

### Q1: "What tables exist in this library?"

Tool: `list_tables`
SQL: (none — tool is dedicated, Claude just reports what the MCP server returns)

This is a *discovery* question. Claude can't guess the schema; it has to ask the server. `list_tables` exists exactly for this — picking `read_query` with a `sqlite_master` query would also work, but dedicated tools are preferred when they exist because they require fewer SQL injection concerns and return structured results.

### Q2: "What columns does the books table have?"

Tool: `describe_table`
SQL: (none — dedicated tool)

Also discovery. `describe_table` returns the schema for one table. I'd ask this before writing any join query so I don't hallucinate column names.

### Q3: "How many books did each author write?"

Tool: `read_query`
SQL:
```sql
SELECT a.name, COUNT(*) AS book_count
FROM authors a
JOIN books b ON b.author_id = a.id
GROUP BY a.id
ORDER BY book_count DESC;
```

Exercises a join and an aggregate. The expected result on the seed data is Le Guin: 2, Chiang: 2, Jemisin: 2, Robinson: 2 — four authors, two books each.

### Q4: "Which books are currently checked out (not returned)?"

Tool: `read_query`
SQL:
```sql
SELECT b.title, c.borrower, c.checked_out_on
FROM checkouts c
JOIN books b ON b.id = c.book_id
WHERE c.returned_on IS NULL
ORDER BY c.checked_out_on;
```

Exercises a filter on `NULL`. On the seed data, three rows should come back: `Exhalation` / alice, `The Dispossessed` / dina, `The Fifth Season` / alice.

### Q5: "Who borrowed the same book twice?"

Tool: `read_query`
SQL:
```sql
SELECT c.borrower, b.title, COUNT(*) AS times
FROM checkouts c
JOIN books b ON b.id = c.book_id
GROUP BY c.borrower, b.id
HAVING times > 1;
```

Exercises `HAVING`. On the seed data this should return one row: alice borrowed *The Fifth Season* twice.

## Why plan queries before asking

Writing this file before running Claude is the whole point. When you just ask Claude "what can you tell me about this database", Claude will often pick an inefficient path — issuing five `read_query` calls to discover the schema instead of a single `list_tables`. Pre-planning the tool you want makes you a better MCP user because you start to see the server's tool list as an API surface, not as a black box.
