-- [Problem 1a]
SELECT DISTINCT name
FROM takes, student
WHERE course_id
    LIKE '%CS%';

-- [Problem 1c]
SELECT i.dept_name, MAX(i.salary)
FROM instructor, instructor AS i
GROUP BY i.dept_name;

-- [Problem 1d]
SELECT MIN(test.maxsalary)
FROM (
    SELECT i.dept_name, MAX(i.salary) AS maxsalary
    FROM instructor, instructor AS i
    GROUP BY i.dept_name
) AS test;

-- [Problem 2a]
INSERT INTO course
VALUES ('CS-001', 'Weekly Seminar', 'Comp. Sci.', '0');

-- [Problem 2b]
INSERT INTO section
VALUES ('CS-001', '1', 'Fall', '2009', NULL, NULL, NULL);

-- [Problem 2c]
INSERT INTO takes (ID, course_id, sec_id, semester, year)
SELECT ID, course_id, sec_id, semester, year
FROM student 
    JOIN section
    ON ID
WHERE dept_name = 'Comp. Sci.' AND course_id = 'CS-001';

-- [Problem 2d]
DELETE FROM takes
WHERE ID = (
    SELECT ID
    FROM student
    WHERE name = 'Chavez'
) AND course_id = 'CS-001';

-- [Problem 2e]
-- If the course is deleted before the sections are deleted, then the sections
-- are deleted as well but there is a row of null values in section.
DELETE FROM course 
WHERE course_id = 'CS-001';

-- [Problem 2f]
DELETE FROM takes
WHERE course_id = (
    SELECT course_id
    FROM course 
    WHERE lower(title) 
        LIKE '%database%'
);

-- [Problem 3a]
SELECT name 
FROM member 
WHERE memb_no IN (
    SELECT memb_no 
    FROM borrowed 
    WHERE isbn IN (
        SELECT isbn 
        FROM book 
        WHERE publisher = 'McGraw-Hill'
    )
);

-- [Problem 3b]
SELECT name
FROM member 
WHERE memb_no IN (
    SELECT memb_no
    FROM (
        SELECT * 
        FROM borrowed 
        WHERE isbn in (
            SELECT isbn 
            FROM book 
            WHERE publisher = 'McGraw-Hill'
        )
        GROUP BY memb_no HAVING COUNT(*) = (
            SELECT COUNT(*) 
            FROM book 
            WHERE publisher = 'McGraw-Hill'
        )
    ) AS MGH_count
);

-- [Problem 3c]
SELECT publisher, name
FROM (
    SELECT name, publisher, COUNT(*) AS count
    FROM member
        NATURAL JOIN borrowed
        NATURAL JOIN book
    GROUP BY publisher, name
    HAVING COUNT(*) > 5
) AS popular_publishers;

-- [Problem 3d]
SELECT AVG(borrowed_books)
FROM (
    SELECT COUNT(isbn) AS borrowed_books
    FROM borrowed
        NATURAL RIGHT JOIN member 
    GROUP BY memb_no
) AS average;
