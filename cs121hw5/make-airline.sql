-- [Problem 5]

-- DROP TABLE commands:
-- Clean up tables if they already exist, respecting referential integrity.
DROP TABLE IF EXISTS itinerary;
DROP TABLE IF EXISTS customer_phone;
DROP TABLE IF EXISTS ticket_purchase;
DROP TABLE IF EXISTS ticket_traveler;
DROP TABLE IF EXISTS ticket_seat;
DROP TABLE IF EXISTS ticket_flight;
DROP TABLE IF EXISTS seat;
DROP TABLE IF EXISTS aircraft;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS transaction;
DROP TABLE IF EXISTS traveler;
DROP TABLE IF EXISTS purchaser;
DROP TABLE IF EXISTS purchase;
DROP TABLE IF EXISTS customer;

-- CREATE TABLE commands:
-- This table has customers' general info. More specific info can
-- be found in traveler and purchase.
CREATE TABLE customer (
    cust_id         INT AUTO_INCREMENT,
    first_name      VARCHAR(30) NOT NULL,
    last_name       VARCHAR(30) NOT NULL,
    email           VARCHAR(50) NOT NULL,
    PRIMARY KEY (cust_id)
);

-- This table has purchases, which has the tickets bought by a purchaser
-- in a transaction. The time of the purchase and a confirmation number
-- that the purchaser can use to access the purchase is included.
-- There is a one to many relation between purchaser and purchases,
-- which can be seen in the transaction table.
-- There is a one to many relation between purchases and tickets,
-- which can be seen in the ticket_purchase table.
CREATE TABLE purchase (
    purchase_id          INT AUTO_INCREMENT,
    timestamp            TIMESTAMP NOT NULL,
    confirmation_num     CHAR(6) UNIQUE NOT NULL,
    PRIMARY KEY (purchase_id)
);

-- Has purchasers, who are a type of customer. They have payment info
-- and can make purchases that are shown in the transaction table.
CREATE TABLE purchaser (
    cust_id                 INT,
    credit_card_num         CHAR(16),
    exp_date                CHAR(4), 
    verification_code       CHAR(3), 
    PRIMARY KEY (cust_id),
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- This table has travelers, who are a type of customer.
-- Travelers must give their passport number, citizenship country,
-- name/phone of emergency contact for international flights.
-- They only need to be entered at least 72 hours before the flight.
-- The emergency_name refers to the name of an emergency contact.
-- The emergency_phone refers to the phone number of the contact.
-- If the traveler has one, the frequent flyer number is also stored.
-- There is a 1 - M relation between travelers and tickets,
-- which can be seen in the ticket_traveler table.
CREATE TABLE traveler (
    cust_id                  INT,
    passport_num             VARCHAR(40) UNIQUE,
    country                  VARCHAR(40),
    emergency_name           VARCHAR(60), 
    emergency_phone          VARCHAR(15), 
    frequent_flyer_num       CHAR(7) UNIQUE,
    PRIMARY KEY (cust_id),
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- This table has transactions, relating the purchaser and purchase tables.
-- purchase_id is the primary key because there is a 1 - M relation
-- between purchaser and purchase.
CREATE TABLE transaction (
    purchase_id              INT,
    cust_id                  INT NOT NULL,
    PRIMARY KEY (purchase_id),
    FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- This table has tickets, which have a unique ID and a price. Tickets are
-- related to purchases, travelers, flights, and seats via the 
-- ticket_purchase, ticket_traveler, ticket_flight, and ticket_seat tables.
CREATE TABLE ticket (
    ticket_id                INT AUTO_INCREMENT,
    sale_price               NUMERIC(4, 2) NOT NULL,
    PRIMARY KEY (ticket_id)
);

-- This table has info about flights, such as time, source airport,
-- destination airport, and whether it is domestic.
-- The source and destination airports are represented by a 
-- 3-letter IATA airport code.
-- The primary key uses both the flight_num and flight_date bc a
-- flight_num can be reused, but not on the same day.

CREATE TABLE flight (
    flight_num               VARCHAR(20),
    flight_date              DATE,
    flight_time              TIME NOT NULL,
    source                   CHAR(3) NOT NULL,
    destination              CHAR(3) NOT NULL,
    is_domestic              BOOLEAN NOT NULL,
    PRIMARY KEY (flight_num, flight_date)
);

-- This table has info about tickets and corresponding flights.
-- This is 1 - M relation between flights and tickets, which is why
-- we use ticket_id as the primary key.
CREATE TABLE ticket_flight (
    ticket_id                INT REFERENCES ticket(ticket_id)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    flight_num               VARCHAR(20) NOT NULL
                             REFERENCES flight(flight_num)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    flight_date              DATE NOT NULL
                             REFERENCES flight(flight_date)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    PRIMARY KEY (ticket_id)
);

-- This table has aircrafts, which are identified by type_code,
-- a 3-char value that the IATA uses to identify aircraft.
CREATE TABLE aircraft (
    type_code                CHAR(3),
    manufacturer             VARCHAR(30) NOT NULL,
    model                    VARCHAR(30) NOT NULL,
    PRIMARY KEY (type_code)
);

-- This table has seats, which are related to tickets by the ticket_seat table.
-- seat_class explains the quality of the seat and the seat_type has whether
-- the seat is aisle/middle/window. Since seat_number can be used multiple
-- times between aircraft, we should include type_code in our primary key
-- to avoid confusion.
CREATE TABLE seat (
    type_code                CHAR(3),
    seat_num                 VARCHAR(4),
    seat_class               VARCHAR(20) NOT NULL,
    seat_type                VARCHAR(20) NOT NULL,
    is_exit                  BOOLEAN NOT NULL,

    PRIMARY KEY (type_code, seat_num),
    FOREIGN KEY (type_code) REFERENCES aircraft(type_code)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Has customer phone numbers, which may be numerous.
-- Hence, we use a primary key with all of the columns because there may
-- be multiple rows with the same cust_id.
CREATE TABLE customer_phone (
    cust_id                  INTEGER,
    phone_num                VARCHAR(15),

    PRIMARY KEY (cust_id, phone_num),
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Relates the purchase and ticket tables in a 1-M relation, using ticket_id
-- as our primary key bc it is unique.
CREATE TABLE ticket_purchase (
    ticket_id                INT,
    purchase_id              INT NOT NULL,
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (purchase_id) REFERENCES purchase(purchase_id)
        ON DELETE cascade
        ON UPDATE CASCADE
);

-- Relates the ticket and traveler tables in a 1-M relation, which tells us
-- which tickets a traveler has.
CREATE TABLE ticket_traveler (
    ticket_id               INTEGER,
    cust_id                 INTEGER NOT NULL,
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Relates the seat and ticket tables in a 1-1 relation.
CREATE TABLE ticket_seat (
    ticket_id               INT,
    seat_num                VARCHAR(4) NOT NULL REFERENCES seat(seat_num)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (ticket_id) REFERENCES ticket(ticket_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- Relates flight and aircraft tables in a M-1 relation, using both flight_num
-- and flight_date as our primary key bc there are many flights for 1 aircraft.
CREATE TABLE itinerary (
    flight_num              VARCHAR(20) REFERENCES flight(flight_num)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    flight_date             DATE REFERENCES flight(flight_date)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    type_code               CHAR(3) NOT NULL REFERENCES aircraft(type_code)
                                ON DELETE CASCADE
                                ON UPDATE CASCADE,
    PRIMARY KEY (flight_num, flight_date)
);