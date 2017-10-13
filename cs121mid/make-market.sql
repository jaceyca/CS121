-- [Problem 5]
-- Clean up tables if they already exist.
DROP TABLE IF EXISTS purchase_items;
DROP TABLE IF EXISTS purchases;
DROP TABLE IF EXISTS sales_items;
DROP TABLE IF EXISTS club_members;
DROP TABLE IF EXISTS stores;

-- [Problem 1]
-- Contains information about the location and phone number
-- of each store in a supermarket chain.
-- The store_id is a unique auto-generated integer ID.
CREATE TABLE stores (
    store_id        INT AUTO_INCREMENT  PRIMARY KEY, 
    store_address   VARCHAR(100)        NOT NULL, 
    store_city      VARCHAR(100)        NOT NULL, 
    store_state     VARCHAR(100)        NOT NULL, 
    store_zipcode   NUMERIC(5, 0)        NOT NULL
);

-- Contains the location, phone number, and join date of each member
-- of the supermarket chain.
-- The member_id is a unique auto-generated integer ID.
CREATE TABLE club_members (
    member_id           INT AUTO_INCREMENT  PRIMARY KEY, 
    member_name         VARCHAR(100)        NOT NULL, 
    member_address      VARCHAR(100)        NOT NULL, 
    member_city         VARCHAR(100)        NOT NULL, 
    member_zipcode      NUMERIC(5, 0)        NOT NULL, 
    member_phone_number NUMERIC(9, 0)        NOT NULL, 
    join_date           TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Contains identifying info (barcode, name, category)
-- and price (dependent on whether purchaser is a member)
-- of each item.
CREATE TABLE sales_items (
    item_sku        NUMERIC(10, 0)       PRIMARY KEY, 
    item_name       VARCHAR(50), 
    item_category   VARCHAR(20),
    standard_price  NUMERIC(5, 2)        NOT NULL, 
    club_price      NUMERIC(5, 2)        NOT NULL
);

-- Contains records of purchases made at a store by a customer,
-- including the time of sale, membership of customer,
-- and total amount spent. Each purchase is assigned a unique,
-- auto-generated integer ID.
CREATE TABLE purchases (
    purchase_id           INT AUTO_INCREMENT  PRIMARY KEY,
    store_id              INT NOT NULL REFERENCES stores,
    sale_timestamp        TIMESTAMP           NOT NULL,
    register_number       INT                 NOT NULL,
    purchase_total        NUMERIC(12, 2),
    member_id             INT REFERENCES club_members,
    UNIQUE(store_id, sale_timestamp, register_number)
);

-- Contains records of individual items in each purchase.
-- Item_price is set to club_price if customer is a member,
-- and standard_price otherwise.
-- Amount customer spends on an item is item_price - other_discounts.
-- Multiples of a particular item are differentiated by
-- the item_id, which is a unique, auto-generated integer ID.
CREATE TABLE purchase_items (
    item_id             INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id         INT NOT NULL REFERENCES purchases,
    item_sku            NUMERIC(10, 0) NOT NULL REFERENCES sales_items,
    item_price          NUMERIC(5, 2) NOT NULL,
    other_discounts     NUMERIC(5, 2),
    FOREIGN KEY (item_price)
        REFERENCES item_price(purchases(member_id), item_sku)
-- wasn't sure how to set it to club/standard price because
-- we didn't cover how to conditionally set a value in the create table.
-- considered using a trigger on insert, but i didn't think that was
-- the correct solution
);


-- [Problem 2]

DROP FUNCTION IF EXISTS item_price;

DELIMITER !

CREATE FUNCTION item_price(mem_id INT, sku INT)
RETURNS NUMERIC(5, 2)

BEGIN
    DECLARE item_price NUMERIC(5, 2);
    IF sku NOT IN (SELECT item_sku
                   FROM sales_items
    ) THEN
    SET item_price = NULL;
    
    ELSEIF  (SELECT member_id
         FROM (purchases
                NATURAL JOIN purchase_items)) IN 
        (SELECT member_id 
         FROM club_members)
    THEN SET item_price = (SELECT club_price
                           FROM sales_items
                           WHERE sku = item_sku
    );
    ELSE SET item_price = (SELECT standard_price
                           FROM sales_items
                           WHERE sku = item_sku
    );
    RETURN item_price;
    END IF;
END!

DELIMITER ;

-- [Problem 3]
DROP VIEW IF EXISTS store_revenues;
CREATE VIEW store_revenues AS
SELECT
    store_id,
    store_address,
    store_city,
    store_state,
    store_zipcode,
    total_sales
FROM stores
    NATURAL JOIN purchases
WHERE total_sales = (
    SELECT SUM(purchase_total) AS total_sales
    FROM purchases
    GROUP BY store_id
)
ORDER BY total_sales DESC;

-- [Problem 4]
DROP VIEW IF EXISTS frequent_visitors;

CREATE VIEW frequent_visitors AS
SELECT
    store_id,
    member_id,
    member_name,
    join_date,
    num_purchases
FROM purchases
    NATURAL JOIN club_members
WHERE (member_id, num_purchases) IN
(
    SELECT member_id, COUNT(purchase_id) AS num_purchases
    FROM purchases
    GROUP BY member_id
    HAVING MAX(num_purchases)
);

