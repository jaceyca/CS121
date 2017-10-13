-- [Problem 1]
DROP PROCEDURE IF EXISTS sp_deposit;

DELIMITER !

-- Given an amount and account number, this procedure adds the amount to
-- the balance of the account. The output status reflects the failure
-- or success of the operation. 0 indicates a success, -1 indicates the
-- passed in amount was negative and it failed, and -2 indicates the 
-- account number was invalid and it failed.
CREATE PROCEDURE sp_deposit (
    IN sp_account_number   VARCHAR(15),
    IN amount              NUMERIC(12, 2),
    OUT status             INT
)

BEGIN
    SET status = 0;
    -- if amount is negative, set status to -1
    IF amount < 0 THEN
        SET status = -1;
    ELSE
        -- if amount is positive, start transaction
        START TRANSACTION;
            UPDATE account
                -- add to balance if the account_number is the desired one
                SET balance = balance + amount
                WHERE account_number = sp_account_number;
            
            -- check if update worked. if it didn't, then set status to -2
            -- because the given account number is invalid
            IF ROW_COUNT() = 0 THEN
                SET status = -2;
            END IF;
        COMMIT;
    END IF;

END!

DELIMITER ;

-- [Problem 2]
DROP PROCEDURE IF EXISTS sp_withdraw;

DELIMITER !

-- Given an amount and account_number, this procedure subtracts the amount
-- from the balance of the account. The output status reflects the success
-- or failure of the operation. 0 indicates a success, -1 indicates the
-- passed in amount was negative and it failed, -2 indicates the 
-- account number was invalid and it failed, -3 indicates the account
-- being subtracted from had insufficient funds and it failed.
CREATE PROCEDURE sp_withdraw (
    IN sp_account_number   VARCHAR(15),
    IN amount              NUMERIC(12, 2),
    OUT status             INT
)

BEGIN
    DECLARE sp_balance NUMERIC(12, 2) DEFAULT NULL;
    SET status = 0;
    -- if amount is negative, set status to -1
    IF amount < 0 THEN
        SET status = -1;
    ELSE
        -- if amount is positive, start transaction
        START TRANSACTION;
            -- get balance and make sure it isn't outdated by using FOR UPDATE
            SELECT balance INTO sp_balance
            FROM account
            WHERE account_number = sp_account_number
            FOR UPDATE;
            
            UPDATE account
                -- subtract from balance if account_number is the desired one
                SET balance = balance - amount
                WHERE account_number = sp_account_number;
            
            -- check if update worked. if it didn't, then set status to -2
            -- because the given account number is invalid
            IF ROW_COUNT() = 0 THEN
                SET status = -2;
            
            -- if account being subtracted from has insufficient funds,
            -- set status to -3 and rollback the update
            ELSEIF (sp_balance - amount) < 0 THEN
                SET status = -3;
                ROLLBACK;
                
            END IF;
        COMMIT;
    END IF;

END!

DELIMITER ;

-- [Problem 3]
DROP PROCEDURE IF EXISTS sp_transfer;

DELIMITER !

-- This procedure transfers amount from account_1_number to account_2_number.
-- The output status reflects the success or failure of the operation.
-- 0 indicates a success, -1 indicates the passed in amount was negative
-- and it failed, -2 indicates the account number was invalid and it failed,
-- -3 indicates the account being subtracted from had insufficient funds
-- and it failed.
CREATE PROCEDURE sp_transfer (
    IN account_1_number     VARCHAR(15),
    IN account_2_number     VARCHAR(15),
    IN amount               NUMERIC(12, 2),
    OUT status              INT
)

BEGIN
    DECLARE account_1_balance   NUMERIC(12, 2) DEFAULT NULL;
    DECLARE account_2_balance   INT;
    
    SET status = 0;
    -- if amount is negative, set status to -1
    IF amount < 0 THEN
        SET status = -1;
    ELSE
        -- if amount is positive, start transaction
        START TRANSACTION;
            -- get balance and make sure it isn't outdated by using FOR UPDATE
            SELECT balance INTO account_1_balance
            FROM account
            WHERE account_number = account_1_number
            FOR UPDATE;
            
            UPDATE account
                -- subtract from balance if account_number is the desired one 
                SET balance = balance - amount
                WHERE account_number = account_1_number;
            
            -- check if update worked. if it didn't, then set status to -2
            -- because the given account number is invalid            
            IF ROW_COUNT() = 0 THEN
                SET status = -2;
            
            -- if account being subtracted from has insufficient funds,
            -- set status to -3 and rollback the update            
            ELSEIF (account_1_balance - amount) < 0 THEN
                SET status = -3;
                ROLLBACK;
                
            ELSE
                UPDATE account
                    -- add to balance for desired account_number
                    SET balance = balance + amount
                    WHERE account_number = account_2_number;
            
                -- check if update worked. if it didn't, then set status to -2
                -- because the given account number is invalid. rollback the
                -- update because the withdrawal couldn't be deposited elsewhere
                IF ROW_COUNT() = 0 THEN
                    SET status = -2;
                    ROLLBACK;
                END IF;
            END IF;
        COMMIT;
    END IF;

END!

DELIMITER ;

