-- [Problem 1]
DROP FUNCTION IF EXISTS min_submit_interval;

DELIMITER !

CREATE FUNCTION min_submit_interval(id INT)
RETURNS INT
BEGIN
    DECLARE first_val INT;
    DECLARE second_val INT;
    DECLARE done INT DEFAULT 0;
    DECLARE difference INT;
    DECLARE smallest_difference INT;
    DECLARE cur CURSOR FOR
        SELECT UNIX_TIMESTAMP(sub_date) AS unix_sub_date
        FROM fileset
        WHERE sub_id = id
        ORDER BY unix_sub_date;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;
        
    OPEN cur;
    FETCH cur INTO first_val;
    WHILE NOT done DO
        FETCH cur INTO second_val;
        IF NOT done THEN
            SET difference = second_val - first_val;
            IF difference < IFNULL(smallest_difference, 2147483647)
                THEN SET smallest_difference = difference;
            END IF;
            SET first_val = second_val;
        END IF;
    END WHILE;
    CLOSE cur;
    RETURN smallest_difference;
END!

DELIMITER ;

-- [Problem 2]
DROP FUNCTION IF EXISTS max_submit_interval;

DELIMITER !

CREATE FUNCTION max_submit_interval(id INT)
RETURNS INT

BEGIN
    DECLARE first_val INT;
    DECLARE second_val INT;
    DECLARE done INT DEFAULT 0;
    DECLARE difference INT;
    DECLARE largest_difference INT;
    DECLARE cur CURSOR FOR
        SELECT UNIX_TIMESTAMP(sub_date) AS unix_sub_date
        FROM fileset
        WHERE sub_id = id
        ORDER BY unix_sub_date;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
        SET done = 1;
        
    OPEN cur;
    FETCH cur INTO first_val;
    WHILE NOT done DO
        FETCH cur INTO second_val;
        IF NOT done THEN
            SET difference = second_val - first_val;
            IF difference > IFNULL(largest_difference, 0)
                THEN SET largest_difference = difference;
            END IF;
            SET first_val = second_val;
        END IF;
    END WHILE;
    CLOSE cur;
    RETURN largest_difference;
END!

DELIMITER ;

-- [Problem 3]
DROP FUNCTION IF EXISTS avg_submit_interval;

DELIMITER !

CREATE FUNCTION avg_submit_interval(id INT)
RETURNS DOUBLE
BEGIN
    DECLARE max_sub INT;
    DECLARE min_sub INT;
    DECLARE num_intervals INT;
    DECLARE avg_interval DOUBLE;
    
    SELECT UNIX_TIMESTAMP(MAX(sub_date)) INTO max_sub
    FROM fileset
    WHERE sub_id = id;
    
    SELECT UNIX_TIMESTAMP(MIN(sub_date)) INTO min_sub
    FROM fileset
    WHERE sub_id = id;
    
    SELECT COUNT(sub_date) - 1 INTO num_intervals
    FROM fileset
    WHERE sub_id = id;
    
    SET avg_interval = (max_sub - min_sub) / num_intervals;
    
    RETURN avg_interval;
END !

DELIMITER ;

-- [Problem 4]
CREATE INDEX idx_sub_id ON fileset(sub_id, sub_date);
/*
SELECT sub_id,
    min_submit_interval(sub_id) AS min_interval,
    max_submit_interval(sub_id) AS max_interval,
    avg_submit_interval(sub_id) AS avg_interval
FROM (SELECT sub_id
    FROM fileset 
    GROUP BY sub_id HAVING COUNT(*) > 1) AS multi_subs
ORDER BY min_interval, max_interval;
*/
