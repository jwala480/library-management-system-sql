# Library Management System — SQL Project

A beginner SQL project built to practice core database concepts: schema design, constraints, joins, aggregation, and referential integrity rules — using a simple library scenario (members borrowing books).

## What it does

Tracks three things:
- **Members** who can borrow books
- **Books** available in the library
- **Issues** — records of who borrowed which book and when

It supports adding members and books, issuing and returning books, and answering questions like "which books are currently not returned?" or "how many books has each member borrowed?"

## Why I built it

This was built as a hands-on project while learning DBMS, to move beyond syntax and actually understand *why* each design choice is made — not just how to write the commands. It was built with guidance (asking "why" at every step rather than copying code), not solved independently from scratch, and that's reflected honestly here.

## Schema

**members**

| Column | Type | Constraint |
|---|---|---|
| member_id | INT | PRIMARY KEY, AUTO_INCREMENT |
| name | VARCHAR(50) | NOT NULL |
| email | VARCHAR(80) | NOT NULL, UNIQUE |
| join_date | DATE | NOT NULL |

**books**

| Column | Type | Constraint |
|---|---|---|
| book_id | INT | PRIMARY KEY, AUTO_INCREMENT |
| title | VARCHAR(100) | NOT NULL |
| author | VARCHAR(50) | NOT NULL |
| copies_available | INT | NOT NULL, CHECK (>= 0) |

**issues**

| Column | Type | Constraint |
|---|---|---|
| issue_id | INT | PRIMARY KEY, AUTO_INCREMENT |
| member_id | INT | FOREIGN KEY → members(member_id), ON DELETE CASCADE, ON UPDATE CASCADE |
| book_id | INT | FOREIGN KEY → books(book_id), ON DELETE RESTRICT, ON UPDATE CASCADE |
| issue_date | DATE | NOT NULL |
| return_date | DATE | nullable — NULL means not yet returned |

### Entity relationship

```
members (1) ──────< (many) issues (many) >────── (1) books
```

## Design decisions

- **`ON DELETE CASCADE` on `members`**: if a member is removed, their borrow history is removed with them — there's no case where an orphaned issue row (pointing to a deleted member) is useful.
- **`ON DELETE RESTRICT` on `books`**: a book with existing issue history can't be deleted, so borrow records never point to a book that no longer exists. The book would need to be handled (e.g. marked unavailable) rather than deleted outright.
- **`CHECK (copies_available >= 0)`**: prevents the available-copy count from ever going negative, which would be a meaningless state.
- **`UNIQUE` on `email`**: keeps one member record per email address.

## Example queries

```sql
-- Books currently not returned by anyone
SELECT m.name, b.title, i.issue_date
FROM issues i
JOIN members m ON i.member_id = m.member_id
JOIN books   b ON i.book_id   = b.book_id
WHERE i.return_date IS NULL;

-- Number of books borrowed per member
SELECT m.name, COUNT(*) AS books_borrowed
FROM members m
LEFT JOIN issues i ON m.member_id = i.member_id
GROUP BY m.member_id, m.name;
```

See [`library_project.sql`](./library_project.sql) for the full script — schema, sample data, and all queries, in order.

## How to run

1. Install MySQL (8.0+) and open MySQL Workbench or the command-line client.
2. Open `library_project.sql`.
3. Run it top to bottom. It creates the `library` database, builds the tables, inserts sample data, and runs example queries.

## What I'd add next

- Wrap the issue/return steps in a transaction (`COMMIT` / `ROLLBACK`), so a partial failure can't leave the data inconsistent
- An audit log via a trigger
- A small Java (JDBC) front end for issuing and returning books through a menu instead of raw SQL

## Status

Learning project — second-year B.Tech (CSM) student, self-studying DBMS for interview and job readiness.
