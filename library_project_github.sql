-- =====================================================
-- LIBRARY MANAGEMENT SYSTEM (MySQL 8.0+)
-- A beginner SQL project: schema design, constraints,
-- joins, aggregation, and referential integrity.
-- =====================================================


-- ---------------------------------------------------
-- 1. DATABASE SETUP
-- ---------------------------------------------------
DROP DATABASE IF EXISTS library;
CREATE DATABASE library;
USE library;


-- ---------------------------------------------------
-- 2. SCHEMA
-- ---------------------------------------------------

-- Members who can borrow books
CREATE TABLE members (
    member_id  INT PRIMARY KEY AUTO_INCREMENT,
    name       VARCHAR(50)  NOT NULL,
    email      VARCHAR(80)  NOT NULL UNIQUE,
    join_date  DATE         NOT NULL
);

-- Books available in the library
CREATE TABLE books (
    book_id           INT PRIMARY KEY AUTO_INCREMENT,
    title             VARCHAR(100) NOT NULL,
    author            VARCHAR(50)  NOT NULL,
    copies_available  INT NOT NULL CHECK (copies_available >= 0)
);

-- Borrow/return records, linking members and books
CREATE TABLE issues (
    issue_id     INT PRIMARY KEY AUTO_INCREMENT,
    member_id    INT  NOT NULL,
    book_id      INT  NOT NULL,
    issue_date   DATE NOT NULL,
    return_date  DATE,                  -- NULL = not yet returned

    -- Deleting/renaming a member cleans up their issue history too
    FOREIGN KEY (member_id) REFERENCES members(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    -- A book with existing issue history cannot be deleted outright
    FOREIGN KEY (book_id) REFERENCES books(book_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- ---------------------------------------------------
-- 3. SAMPLE DATA
-- ---------------------------------------------------
INSERT INTO members (name, email, join_date) VALUES
('Ravi',  'ravi@mail.com',  '2026-01-10'),
('Sita',  'sita@mail.com',  '2026-02-15'),
('Anil',  'anil@mail.com',  '2026-03-20'),
('Meena', 'meena@mail.com', '2026-04-05'),
('Kiran', 'kiran@mail.com', '2026-05-12');

INSERT INTO books (title, author, copies_available) VALUES
('DBMS Basics',          'A. Rao',    3),
('Java Fundamentals',    'S. Kumar',  2),
('DSA Made Easy',        'P. Reddy',  1),
('Python for Beginners', 'L. Sharma', 4),
('ML Starter Guide',     'K. Varma',  2);

INSERT INTO issues (member_id, book_id, issue_date, return_date) VALUES
(1, 1, '2026-09-01', NULL),
(1, 2, '2026-09-03', '2026-09-10'),
(2, 1, '2026-09-05', NULL),
(3, 3, '2026-09-07', NULL),
(4, 4, '2026-09-08', '2026-09-15');


-- ---------------------------------------------------
-- 4. EXAMPLE QUERIES
-- ---------------------------------------------------

-- All books with more than 2 copies available
SELECT title, author
FROM books
WHERE copies_available > 2;

-- Every issue record with member name and book title
SELECT m.name, b.title, i.issue_date
FROM issues i
JOIN members m ON i.member_id = m.member_id
JOIN books   b ON i.book_id   = b.book_id;

-- Books currently not returned by anyone
SELECT m.name, b.title, i.issue_date
FROM issues i
JOIN members m ON i.member_id = m.member_id
JOIN books   b ON i.book_id   = b.book_id
WHERE i.return_date IS NULL;

-- Members who have never borrowed a book
SELECT m.name
FROM members m
LEFT JOIN issues i ON m.member_id = i.member_id
WHERE i.issue_id IS NULL;

-- Number of books borrowed per member (0 included)
SELECT m.name, COUNT(*) AS books_borrowed
FROM members m
LEFT JOIN issues i ON m.member_id = i.member_id
GROUP BY m.member_id, m.name;

-- Members who borrowed 2 or more books
SELECT m.name, COUNT(*) AS books_borrowed
FROM members m
JOIN issues i ON m.member_id = i.member_id
GROUP BY m.member_id, m.name
HAVING COUNT(*) >= 2;

-- Number of times each book has been borrowed
SELECT b.title, COUNT(*) AS times_borrowed
FROM issues i
JOIN books b ON i.book_id = b.book_id
GROUP BY b.title;


-- ---------------------------------------------------
-- 5. ISSUING AND RETURNING A BOOK
-- ---------------------------------------------------

-- Issue: add the record, then decrease available copies
INSERT INTO issues (member_id, book_id, issue_date)
VALUES (5, 2, '2026-09-20');

UPDATE books
SET copies_available = copies_available - 1
WHERE book_id = 2;

-- Return: set the return date, then increase available copies
UPDATE issues
SET return_date = '2026-09-22'
WHERE member_id = 2 AND book_id = 1 AND return_date IS NULL;

UPDATE books
SET copies_available = copies_available + 1
WHERE book_id = 1;


-- ---------------------------------------------------
-- 6. REFERENTIAL INTEGRITY IN ACTION
-- ---------------------------------------------------

-- ON UPDATE CASCADE: member_id change propagates to issues
UPDATE members SET member_id = 10 WHERE member_id = 2;

-- ON DELETE CASCADE: deleting a member removes their issue history
DELETE FROM members WHERE member_id = 3;

-- ON DELETE RESTRICT: fails as expected — book_id 1 still has issue history
-- DELETE FROM books WHERE book_id = 1;


-- ---------------------------------------------------
-- 7. CONSTRAINT CHECKS (each expected to fail)
-- ---------------------------------------------------
-- INSERT INTO members (name, email, join_date) VALUES ('Test', 'ravi@mail.com', '2026-09-28');  -- UNIQUE
-- INSERT INTO issues (member_id, book_id, issue_date) VALUES (1, 99, '2026-09-28');               -- FOREIGN KEY
-- UPDATE books SET copies_available = -1 WHERE book_id = 1;                                        -- CHECK
-- INSERT INTO members (name, email, join_date) VALUES (NULL, 'x@mail.com', '2026-09-28');          -- NOT NULL
