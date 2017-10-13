-- [Problem 6a]
-- Find all purchases for cust_id = 54321
SELECT timestamp, flight_date,
    (SELECT last_name
    FROM traveler AS t1
    WHERE t1.cust_id IN (SELECT c FROM

    ((customer NATURAL JOIN transaction NATURAL JOIN purchase NATURAL JOIN
    ticket_purchase NATURAL JOIN ticket NATURAL JOIN ticket_flight) NATURAL JOIN
    (SELECT ticket_id AS t, cust_id AS c
    FROM ticket_traveler) AS temp)

    )) AS last_name,
    (SELECT first_name
    FROM traveler AS t1
    WHERE t1.cust_id IN (SELECT c FROM

    ((customer NATURAL JOIN transaction NATURAL JOIN purchase NATURAL JOIN
    ticket_purchase NATURAL JOIN ticket NATURAL JOIN ticket_flight) NATURAL JOIN
    (SELECT ticket_id AS t, cust_id AS c
    FROM ticket_traveler) AS temp)

    )) AS first_name
FROM
((customer NATURAL JOIN transaction NATURAL JOIN purchase NATURAL JOIN
ticket_purchase NATURAL JOIN ticket NATURAL JOIN ticket_flight) NATURAL JOIN
    (SELECT ticket_id AS t, cust_id AS c
    FROM ticket_traveler) AS temp)
WHERE cust_id = 54321
ORDER BY timestamp DESC, flight_date, last_name, first_name;


-- [Problem 6b]
-- Reports total revenue from ticket sales for each aircraft type in
-- the last 2 weeks.
SELECT type_code, IFNULL(sum_sales, 0) AS sum_sales
FROM aircraft NATURAL LEFT OUTER JOIN
    (SELECT type_code, SUM(sale_price) AS sum_sales
    FROM itinerary NATURAL JOIN flight NATURAL JOIN ticket_flight
    NATURAL JOIN ticket
    WHERE flight_date BETWEEN NOW() - INTERVAL 2 WEEK AND NOW()
    GROUP BY type_code) AS temp;


-- [Problem 6c]
-- Reports all travlers on internation flights that haven't filled out
-- their flight info.
SELECT cust_id
FROM traveler NATURAL JOIN ticket_traveler NATURAL JOIN ticket NATURAL JOIN
    ticket_flight NATURAL JOIN flight
WHERE NOT is_domestic AND (passport_num IS NULL OR
    country IS NULL OR emergency_name IS NULL OR
    emergency_phone IS NULL);