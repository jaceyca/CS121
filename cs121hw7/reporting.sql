-- [Problem 6a]
-- Reports distinct HTTP protocol values and total requests from each value.
SELECT protocol, SUM(num_requests) AS total_requests
FROM resource_dim NATURAL JOIN resource_fact
GROUP BY protocol
ORDER BY total_requests DESC
LIMIT 10;

-- [Problem 6b]
-- Reports top 20 (resource, error response) combos.
SELECT resource, response, SUM(num_requests) AS num_errors
FROM resource_dim NATURAL JOIN resource_fact
WHERE response >= 400
GROUP BY resource, response
ORDER BY num_errors DESC
LIMIT 20;

-- [Problem 6c]
-- Reports top 20 clients based on total bytes sent.
SELECT ip_addr, COUNT(DISTINCT visit_val) AS num_visits,
    SUM(num_requests) AS total_requests, SUM(total_bytes) AS total_bytes
FROM visitor_dim NATURAL JOIN visitor_fact
GROUP BY ip_addr
ORDER BY total_bytes DESC
LIMIT 20;


-- [Problem 6d]
-- Reports daily request-total and total bytes served from 7/3/1995 - 8/12/1995.
-- Gap between 8/1 and 8/3 was because of Hurricane Erin, which led to the
-- Web server being shut down.
-- Gap btw 7/28 and 8/1 has no explanation.
SELECT date_val, IFNULL(SUM(num_requests), 0) AS daily_request_total,
    IFNULL(SUM(total_bytes), 0) AS total_bytes_served
FROM datetime_dim NATURAL LEFT JOIN resource_fact
WHERE date_val BETWEEN '1995-07-23' AND '1995-08-12'
GROUP BY date_val;


-- [Problem 6e]
-- Reports the resource that generated the largest "total bytes served"
-- daily by joining a table that contains the max values for total_bytes
-- for each date_val with a table that contains total bytes for each date_val
-- and resource combo and selecting where max_total_bytes = total_bytes.
SELECT date_val, resource, total_requests, total_bytes
FROM
    (SELECT date_val, MAX(total_bytes) AS max_total_bytes
    FROM
        (SELECT date_val, SUM(total_bytes) AS total_bytes
        FROM datetime_dim NATURAL JOIN resource_fact NATURAL JOIN resource_dim
        GROUP BY date_val, resource) AS temp
    GROUP BY date_val) AS temp2 NATURAL JOIN
    (SELECT date_val, resource, SUM(num_requests) AS total_requests,
    SUM(total_bytes) AS total_bytes
    FROM datetime_dim NATURAL JOIN resource_fact NATURAL JOIN resource_dim
    GROUP BY date_val, resource) AS temp3
WHERE total_bytes = max_total_bytes
ORDER BY date_val;

-- [Problem 6f]
-- Computes avg number of visits per hour over weekday days and weekend days.
-- Avg_weekday_visits is much higher than avg_weekend_visits between 7 am and
-- 5 pm, probably because people were at work during those times and had to
-- access internet resources, which led to increased visits. During weekends,
-- people weren't at work and may not have had Internet access at home. Thus,
-- there are lower number of visits during the weekend. The difference btw
-- weekday and weekend visits were caused by the fact that more people probably
-- had internet access at work but not at home. Also, people may not have
-- visited the Web server while at home as often as they did while at work.
SELECT hour_val, avg_weekday_visits, avg_weekend_visits
FROM
    (SELECT hour_val, COUNT(visit_val) /
        (SELECT COUNT(DISTINCT date_val)
        FROM datetime_dim AS d2 NATURAL JOIN visitor_fact
            NATURAL JOIN visitor_dim
        WHERE weekend = FALSE AND d2.hour_val = d1.hour_val)
            AS avg_weekday_visits
    FROM datetime_dim AS d1 NATURAL JOIN visitor_fact NATURAL JOIN visitor_dim
    WHERE weekend = FALSE
    GROUP BY hour_val) AS weekday_temp
    NATURAL JOIN
    (SELECT hour_val, COUNT(visit_val) /
        (SELECT COUNT(DISTINCT date_val)
        FROM datetime_dim AS d2 NATURAL JOIN visitor_fact
            NATURAL JOIN visitor_dim
        WHERE weekend = TRUE AND d2.hour_val = d1.hour_val)
            AS avg_weekend_visits
    FROM datetime_dim AS d1 NATURAL JOIN visitor_fact NATURAL JOIN visitor_dim
    WHERE weekend = True
    GROUP BY hour_val) AS weekend_temp;