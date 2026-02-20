DROP TABLE IF EXISTS issues;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS borrowers;
DROP TABLE IF EXISTS authors;
-- AUTHORS TABLE
CREATE TABLE authors(
    author_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
-- BOOKS TABLE
CREATE TABLE books(
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author_id INT NOT NULL REFERENCES authors(author_id)
);
-- BORROWERS TABLE
CREATE TABLE borrowers(
    borrower_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
-- ISSUES TABLE
CREATE TABLE issues(
    issue_id SERIAL PRIMARY KEY,
    book_id INT NOT NULL REFERENCES books(book_id),
    borrower_id INT NOT NULL REFERENCES borrowers(borrower_id),
    issue_date DATE NOT NULL,
    return_date DATE
);
-- Insert Authors
INSERT INTO authors(name) VALUES
('John Smith'),
('Mark Allen Weiss'),
('Caroline Channing');

-- Insert Books
INSERT INTO books(title, author_id) VALUES
('Data Structures', 1),
('Java Programming', 2),
('Database Systems', 3);
-- Insert Borrowers
INSERT INTO borrowers(name) VALUES
('Ali'),
('Ahmed'),
('Sara');

-- FUNCTION 1: ISSUE A BOOK(Prevent issuing if book is already issued)
CREATE OR REPLACE FUNCTION issue_book(bid INT, borid INT)
RETURNS TEXT
AS
$$
DECLARE
    book_taken INT;
BEGIN
    -- Check if the book is already issued and not returned
	--count check number of rows where return date is empty
    SELECT COUNT(*) INTO book_taken
    FROM issues
    WHERE book_id = bid AND return_date IS NULL;

    IF book_taken > 0 THEN--book already borrowed,then stops function
        RETURN '❌ Book already issued and not returned!';
    END IF;

    -- Issue book,,if book free then issue record in issue table
    INSERT INTO issues(book_id, borrower_id, issue_date)
    VALUES (bid, borid, CURRENT_DATE);

    RETURN '✔ Book issued successfully';
END;
$$ LANGUAGE plpgsql;





-- FUNCTION 2: RETURN A BOOK
CREATE OR REPLACE FUNCTION return_book(issueid INT)
RETURNS TEXT AS $$
BEGIN
    UPDATE issues
    SET return_date = CURRENT_DATE
    WHERE issue_id = issueid;

  RETURN '✔ Book returned successfully';
END;
$$ 
LANGUAGE plpgsql;
-- SHOWs LIST OF ALL ISSUED BOOKS
SELECT 
    i.issue_id,
    b.title AS book_title,
    a.name AS author_name,
    br.name AS borrower_name,
    i.issue_date,
    i.return_date
FROM issues i
JOIN books b ON i.book_id = b.book_id
JOIN authors a ON b.author_id = a.author_id
JOIN borrowers br ON i.borrower_id = br.borrower_id
ORDER BY i.issue_id;

SELECT issue_book(1,1);--book with book id 1 is given to borrower id 1(ali) 
-- SELECT return_book(1);   

SELECT issue_book(1,2);  --book id with 1 ia already given to borrower id 1(ali tries to get same book with id 1)
-- SELECT return_book(1);   
SELECT issue_book(1,2);
SELECT return_book(2);   

--CHECKING TABLES
-- SELECT * FROM authors;
-- SELECT * FROM books;
-- SELECT * FROM borrowers;
-- SELECT * FROM issues;
