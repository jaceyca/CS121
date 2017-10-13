-- [Problem 3]
-- Drop tables while respecting referential integrity.
DROP TABLE IF EXISTS visitor_fact;
DROP TABLE IF EXISTS resource_fact;
DROP TABLE IF EXISTS visitor_dim;
DROP TABLE IF EXISTS resource_dim;
DROP TABLE IF EXISTS datetime_dim;

-- The dimension table for datetime contains every day/hour combo for a
-- certain amount of time.
CREATE TABLE datetime_dim (
    date_id  INT AUTO_INCREMENT,
    date_val DATE NOT NULL,
    hour_val INT NOT NULL,
    weekend  BOOLEAN NOT NULL,
    holiday  VARCHAR(20),
    PRIMARY KEY (date_id),
    UNIQUE (date_val, hour_val)
);

-- The dimension table for resources contains info about internet resources.
CREATE TABLE resource_dim (
    resource_id INT AUTO_INCREMENT,     
    resource    VARCHAR(200) NOT NULL,  
    method      VARCHAR(15),            -- GET/POST
    protocol    VARCHAR(200),           
    response    INT NOT NULL,           
    PRIMARY KEY (resource_id),
    UNIQUE (resource, method, protocol, response)
);

-- The dimension table for visitors contains info about people who visited
-- the web servers.
CREATE TABLE visitor_dim (
    visitor_id INT AUTO_INCREMENT,
    ip_addr    VARCHAR(200) NOT NULL,
    visit_val  INT NOT NULL,    -- which visit the visitor was part of
    PRIMARY KEY (visitor_id),
    UNIQUE (visit_val)
);

-- The fact table for resources contains additional info about internet
-- resources that aren't stored in resource_dim.
CREATE TABLE resource_fact (
    date_id      INT,
    resource_id  INT,
    num_requests INT NOT NULL,  -- total requests involving a resource
    total_bytes  BIGINT,        -- total bytes sent to a resource
    PRIMARY KEY (date_id, resource_id),
    FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id),
    FOREIGN KEY (resource_id) REFERENCES resource_dim(resource_id)
);

-- The fact table for visitors contains additional info about visitors
-- besides the info in visitor_dim.
CREATE TABLE visitor_fact (
    date_id INT,
    visitor_id INT,
    num_requests INT NOT NULL, -- number of requests involving a visitor
    total_bytes INT,           -- total bytes sent by visitors
    PRIMARY KEY (date_id, visitor_id),
    FOREIGN KEY (date_id) REFERENCES datetime_dim(date_id),
    FOREIGN KEY (visitor_id) REFERENCES visitor_dim(visitor_id)
);