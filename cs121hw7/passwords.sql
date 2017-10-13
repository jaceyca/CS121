-- [Problem 1a]
DROP TABLE IF EXISTS user_info;

-- Stores data for users: their username, their salt,
-- and their hashed password.
CREATE TABLE user_info (
    username    VARCHAR(20),
    salt        VARCHAR(20) NOT NULL,
    password_hash CHAR(64)  NOT NULL, -- generated with SHA2
    PRIMARY KEY (username),
    CHECK (LEN(salt) >= 6)
);
-- [Problem 1b]
DROP PROCEDURE IF EXISTS sp_add_user;

DELIMITER !
-- Adds a new row to user_info with the input username, salt, and
-- new hashed pasword. The hashed password is made by concatenating
-- the salt and input password, and using SHA2 encryption on it.
CREATE PROCEDURE sp_add_user (
    IN new_username VARCHAR(20),
    IN password     VARCHAR(20)
)

BEGIN
    DECLARE new_salt    CHAR(10);
    DECLARE new_pass_hash CHAR(64);
    SELECT make_salt(10) INTO new_salt;
    SELECT SHA2(CONCAT(new_salt, password), 256) INTO new_pass_hash;
    INSERT INTO user_info VALUES (new_username, new_salt, new_pass_hash);
END!

DELIMITER ;

-- [Problem 1c]
DROP PROCEDURE IF EXISTS sp_change_password;

DELIMITER !

-- Updates password for user by making a new salt and hashing the new password.
CREATE PROCEDURE sp_change_password (
    IN username     VARCHAR(20),
    IN new_password VARCHAR(20)
)

BEGIN
    DECLARE new_salt    CHAR(10);
    DECLARE new_pass_hash CHAR(64);
    SELECT make_salt(10) INTO new_salt;
    SELECT SHA2(CONCAT(new_salt, new_password), 256) INTO new_pass_hash;
    UPDATE user_info AS u
        SET salt = new_salt,
            password_hash = new_pass_hash
        WHERE u.username = username;
END!

DELIMITER ;

-- [Problem 1d]
DROP FUNCTION IF EXISTS authenticate;

DELIMITER !

-- Given a username and a password, this function returns a bool of true/false
-- based on whether they were valid. Returns true if username is in user_info
-- and password_hash is its corresponding hashed password, and false otherwise.
CREATE FUNCTION authenticate (
    a_username    VARCHAR(20),
    a_password    VARCHAR(20)
) RETURNS BOOLEAN

BEGIN
    DECLARE a_salt        VARCHAR(20);
    IF a_username IN (SELECT username FROM user_info) THEN
        SELECT salt INTO a_salt FROM user_info WHERE username = a_username;
        IF SHA2(CONCAT(a_salt, a_password), 256) IN
        (SELECT password_hash FROM user_info WHERE username = a_username)
        THEN RETURN TRUE;
        ELSE RETURN FALSE;
        END IF;
    ELSE RETURN FALSE;
    END IF;

END!


DELIMITER ;