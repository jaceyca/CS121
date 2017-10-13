-- [Problem 2a]
SELECT COUNT(*)
FROM raw_web_log;

-- [Problem 2b]
SELECT ip_addr, COUNT(*) AS num_requests
FROM raw_web_log
GROUP BY ip_addr
ORDER BY num_requests DESC
LIMIT 20;

-- [Problem 2c]
SELECT resource, COUNT(ip_addr) AS num_requests, SUM(bytes_sent) AS bytes_served
FROM raw_web_log
GROUP BY resource
ORDER BY bytes_served DESC
LIMIT 20;

-- [Problem 2d]
SELECT visit_val, ip_addr, COUNT(ip_addr) AS num_requests,
MIN(logtime) AS start_time, MAX(logtime) AS end_time
FROM raw_web_log
GROUP BY visit_val
ORDER BY num_requests DESC
LIMIT 20;


-- LOAD DATA LOCAL INFILE
-- '~/Downloads/raw_web_log.dat' INTO
-- TABLE raw_web_log;
