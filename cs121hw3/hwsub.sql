-- [Problem 1a]
SELECT SUM(perfectscore) AS perfect_scores
FROM assignment;

-- [Problem 1b]
SELECT sec_name, COUNT(username) AS students_per_section
FROM section NATURAL JOIN student
GROUP BY sec_name;

-- [Problem 1c]
CREATE VIEW totalscores AS
    SELECT username, SUM(score) AS total_score
    FROM submission
    WHERE graded = 1
    GROUP BY username;
    
-- [Problem 1d]
CREATE VIEW passing AS
    SELECT *
    FROM totalscores
    WHERE total_score >= 40;

-- [Problem 1e]
CREATE VIEW failing AS
    SELECT *
    FROM totalscores
    WHERE total_scores < 40;

-- [Problem 1f]
-- Result of this query: harris, ross, miller, turner, edwards,
-- murphy, simmons, tucker, coleman, flores, gibson (11 rows returned)
SELECT username
FROM submission NATURAL JOIN assignment
WHERE shortname LIKE 'lab%' AND sub_id NOT IN (
    SELECT sub_id
    FROM fileset
)
AND username IN (
    SELECT username
    FROM passing
);

-- [Problem 1g]
-- Result of this query: collins (1 row returned)
SELECT username
FROM submission NATURAL JOIN assignment
WHERE (shortname LIKE 'midterm' OR shortname LIKE 'final') AND sub_id NOT IN (
    SELECT sub_id
    FROM fileset
)
AND username IN (
    SELECT username
    FROM passing
);

-- [Problem 2a]
SELECT DISTINCT username
FROM assignment NATURAL JOIN submission NATURAL JOIN fileset
WHERE shortname LIKE 'midterm' AND sub_date > due;

-- [Problem 2b]
SELECT EXTRACT(HOUR FROM sub_date) AS sub_hour, COUNT(sub_id) AS num_labs
FROM submission NATURAL JOIN fileset NATURAL JOIN assignment
WHERE shortname LIKE 'lab%'
GROUP BY sub_hour;

-- [Problem 2c]
SELECT COUNT(*) AS nearly_late
FROM assignment NATURAL JOIN fileset NATURAL JOIN submission
WHERE shortname LIKE 'final' AND
    sub_date BETWEEN (due - INTERVAL 30 MINUTE) AND due;

-- [Problem 3a]
ALTER TABLE student
    ADD COLUMN email    VARCHAR(200);
UPDATE student
    SET email = CONCAT(username, '@school.edu');
ALTER TABLE student
    CHANGE COLUMN email email VARCHAR(200) NOT NULL;

-- [Problem 3b]
ALTER TABLE assignment
    ADD COLUMN submit_files     BOOLEAN DEFAULT TRUE;
UPDATE assignment
    SET submit_files = FALSE
WHERE shortname LIKE 'dq%';

-- [Problem 3c]
CREATE TABLE gradescheme (
    scheme_id   INT,
    scheme_desc VARCHAR(100) NOT NULL,
    PRIMARY KEY (scheme_id)
);

INSERT INTO gradescheme VALUES
(0, 'Lab assignment with min-grading.'),
(1, 'Daily quiz.'),
(2, 'Midterm or final exam.');

ALTER TABLE assignment
    CHANGE COLUMN gradescheme scheme_id INT NOT NULL;
ALTER TABLE gradescheme
    ADD FOREIGN KEY (scheme_id)
    REFERENCES assignment(scheme_id);
    
-- [Problem 4a]
-- Given a date, return true if it is on a weekend and false if it is a weekday.
DELIMITER !
CREATE FUNCTION is_weekend(d DATE) RETURNS BOOLEAN
BEGIN
    IF dayofweek(d) = 1
        THEN RETURN TRUE;
    ELSEIF dayofweek(d) = 7
        THEN RETURN TRUE;
    END IF;
    RETURN FALSE;
END !
DELIMITER ;

-- [Problem 4b]
-- Given a date, return name of the holiday if it is a holiday or
-- null if it is not.
DELIMITER !
CREATE FUNCTION is_holiday(d DATE) RETURNS VARCHAR(20)
BEGIN
    IF dayofyear(d) = 1
        THEN RETURN 'New Year\'s Day';
    ELSEIF month(d) = 5 AND dayofweek(d) = 2 AND day(d) BETWEEN 25 AND 31
        THEN RETURN 'Memorial Day';
    ELSEIF month(d) = 7 AND day(d) = 4
        THEN RETURN 'Independence Day';
    ELSEIF month(d) = 9 AND dayofweek(d) = 2 AND day(d) BETWEEN 1 AND 6
        THEN RETURN 'Labor Day';
    ELSEIF month(d) = 11 AND dayofweek(d) = 5 AND day(d) BETWEEN 22 AND 28
        THEN RETURN 'Thanksgiving';
    ELSE RETURN NULL;
    END IF;
END !
DELIMITER ;

-- [Problem 5a]
SELECT is_holiday(DATE(sub_date)) AS holiday_subs, COUNT(sub_id) AS num_subs
FROM fileset
GROUP BY holiday_subs;

-- [Problem 5b]
SELECT CASE
    WHEN is_weekend(DATE(sub_date)) = TRUE THEN 'weekend'
        ELSE 'weekday'
    END AS type_of_day, COUNT(sub_id) AS num_subs
FROM fileset
GROUP BY type_of_day;

