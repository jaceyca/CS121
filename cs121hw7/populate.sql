-- PLEASE DO NOT INCLUDE date-udfs HERE!!!

-- [Problem 4a]
-- Populate resource_dim by inserting combinations of values (resource,
-- method, protocol, response), grouping by the values to ensure distinctness.
INSERT INTO resource_dim(resource, method, protocol, response)
    SELECT resource, method, protocol, response
    FROM raw_web_log
    GROUP BY resource, method, protocol, response;

-- [Problem 4b]
-- Populate visitor_dim by inserting combos of values (ip_addr, visit_val),
-- grouping by the values to ensure distinctness.
INSERT INTO visitor_dim(ip_addr, visit_val)
    SELECT ip_addr, visit_val
    FROM raw_web_log
    GROUP BY ip_addr, visit_val;

-- [Problem 4c]
DROP PROCEDURE IF EXISTS populate_dates;
DELIMITER !

-- The procedure goes through the date/hour combos of the given interval,
-- and checks if it is a weekend and/or holiday using date-udfs.sql.
-- Then, it inserts the info into datetime_dim.
CREATE PROCEDURE populate_dates(d_start DATE, d_end DATE)
BEGIN
    DECLARE d DATE DEFAULT d_start;
    DECLARE h INTEGER DEFAULT 0;

    DELETE FROM datetime_dim
    WHERE date_val BETWEEN d_start AND d_end;

    WHILE d <= d_end DO  -- loop through days
        SET h = 0;
            WHILE h <= 23 DO  -- loop through hours
                INSERT INTO datetime_dim(date_val, hour_val, weekend, holiday)
                    VALUES (d, h, is_weekend(d), is_holiday(d));
                SET h = h + 1;  -- increment hours
            END WHILE;
        SET d = d + INTERVAL 1 DAY;  -- increment days
    END WHILE;

END!

DELIMITER ;

-- CALL populate_dates('1995-07-01', '1995-08-31');

-- [Problem 5a]
-- Populate resource_fact by joining raw_web_log and datetime_dim and
-- resource_dim to get all the info. We join using <=> to equate null values
-- to each other. Group on date_id and resource_id and compute aggregates on
-- the grouping. Insert desired info and computed facts into resource_fact.
INSERT INTO resource_fact(date_id, resource_id, num_requests, total_bytes)
SELECT date_id, resource_id, COUNT(ip_addr) AS num_requests, SUM(bytes_sent)
    AS total_bytes
FROM raw_web_log AS rw JOIN datetime_dim AS d ON
    (DATE(rw.logtime) <=> d.date_val AND HOUR(rw.logtime) <=> d.hour_val)
    JOIN resource_dim AS r ON (rw.resource <=> r.resource
    AND rw.method <=> r.method AND rw.protocol <=> r.protocol
    AND rw.response <=> r.response)
GROUP BY date_id, resource_id;

-- [Problem 5b]
-- Populate visitor_fact by joining raw_web_log and datetime_dim and
-- resource_dim to get all the info. We join using <=> to equate null values
-- to each other. Group on date_id and resource_id and compute aggregates on
-- the grouping. Insert desired info and computed facts into resource_fact.
INSERT INTO visitor_fact(date_id, visitor_id, num_requests, total_bytes)
SELECT date_id, visitor_id, COUNT(rw.ip_addr) AS num_requests, SUM(bytes_sent)
    AS total_bytes
FROM raw_web_log AS rw JOIN datetime_dim AS d ON
    (DATE(rw.logtime) <=> d.date_val AND HOUR(rw.logtime) <=> d.hour_val)
    JOIN visitor_dim AS v ON (rw.ip_addr <=> v.ip_addr
    AND rw.visit_val <=> v.visit_val)
GROUP BY date_id, visitor_id;

