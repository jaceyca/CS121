-- [Problem 1]
-- Cleans up old tables.
-- Drop tables in an order that respects referential integrity.
DROP TABLE IF EXISTS participated;
DROP TABLE IF EXISTS owns;
DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS car;
DROP TABLE IF EXISTS accident;

-- Contains information on people.
CREATE TABLE person (
    driver_id   CHAR(10),                   -- driver license
    name        VARCHAR(50)     NOT NULL,   -- person's name
    address     VARCHAR(100)    NOT NULL,   -- person's address
    PRIMARY KEY (driver_id)
);

-- Contains information about cars.
CREATE TABLE car (
    license     CHAR(7),        -- car's license plate
    model       VARCHAR(50),    -- car's model
    year        YEAR(4),        -- car's year
    PRIMARY KEY (license)
);

-- Contains information about accidents that occurred.
CREATE TABLE accident (
    report_number     INT AUTO_INCREMENT,     -- Has report numbers that
                                              --  are auto-incremented
    date_occurred     DATETIME NOT NULL,      -- Date and time the
                                              --  accident occurred
    location          VARCHAR(1000) NOT NULL, -- Location of accident, which is
                                              --  a nearby address/intersection
    description       TEXT,                   -- Report of accident
    PRIMARY KEY (report_number)
);

-- Contains info about ownership of cars, referencing the person and car tables.
CREATE TABLE owns (
    driver_id       CHAR(10),       -- driver license
    license         CHAR(7),        -- car's license plate
    PRIMARY KEY (driver_id, license),
    FOREIGN KEY (driver_id) REFERENCES person(driver_id)
                            ON UPDATE CASCADE
                            ON DELETE CASCADE,
    FOREIGN KEY (license) REFERENCES car(license)
                          ON UPDATE CASCADE
                          ON DELETE CASCADE
);

-- Contains info about drivers and cars involved in accidents.
CREATE TABLE participated (
    driver_id       CHAR(10),       -- driver license
    license         CHAR(7),        -- car's license plate
    report_number   INT,            -- report number that doesn't need to
                                    --  auto-increment bc it's cascaded
    damage_amount   NUMERIC(10,2),  -- monetary amount
    PRIMARY KEY (driver_id, license, report_number),
    FOREIGN KEY (driver_id)     REFERENCES person(driver_id)
                                ON UPDATE CASCADE,
    FOREIGN KEY (license)       REFERENCES car(license)
                                ON UPDATE CASCADE,
    FOREIGN KEY (report_number) REFERENCES accident(report_number)
                                ON UPDATE CASCADE
);