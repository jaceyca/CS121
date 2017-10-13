-- [Problem 1]
SELECT *
FROM club_members
WHERE join_date BETWEEN 
    (CURRENT_TIMESTAMP() - INTERVAL 2 WEEK) AND
     CURRENT_TIMESTAMP();

-- [Problem 2]
SELECT *
FROM club_members 
WHERE member_id IN
(
    SELECT member_id
    FROM purchases
    WHERE sale_timestamp BETWEEN 
        (CURRENT_TIMESTAMP() - INTERVAL 3 MONTH) AND
         CURRENT_TIMESTAMP()
    GROUP BY member_id
    HAVING SUM(purchase_total) <= 10
);

-- [Problem 3]
DELETE FROM purchase_items
WHERE purchase_id IN
(
    SELECT purchase_id
    FROM purchases
    WHERE member_id = 535210
);

DELETE FROM purchases
WHERE member_id = 535210;

DELETE FROM club_members
WHERE member_id = 535210;

-- [Problem 4]
UPDATE sales_items
SET club_price = standard_price
WHERE club_price IN (
    SELECT club_price
    FROM sales_items
        NATURAL JOIN purchase_items
    WHERE AVG(item_price - other_discounts) <= .6 * standard_price
    GROUP BY item_sku
);
-- [Problem 5]
SELECT member_id, COUNT(complete_purchases) AS num_complete_purchases
FROM purchases
WHERE (
    SELECT (member_id, purchase_id)
    FROM (purchases 
        NATURAL JOIN purchase_items)
        NATURAL JOIN sales_items
    WHERE COUNT(DISTINCT item_category) =
    COUNT(SELECT DISTINCT item_category FROM sales_items)
    GROUP BY member_id
) AS complete_purchases;
