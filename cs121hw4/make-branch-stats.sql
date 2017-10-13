-- [Problem 1]
CREATE INDEX idx_balance ON account(branch_name, balance);

-- [Problem 2]
CREATE TABLE my_branch_account_stats(
    branch_name VARCHAR(15),
    num_accounts INT NOT NULL DEFAULT 0,
    total_deposits INT NOT NULL DEFAULT 0,
    min_balance NUMERIC(12, 2) NOT NULL DEFAULT 0,
    max_balance NUMERIC(12, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (branch_name)
);
-- [Problem 3]
INSERT INTO my_branch_account_stats
SELECT
    branch_name,
    COUNT(*) AS num_accounts,
    SUM(balance) AS total_deposits,
    MIN(balance) AS min_balance,
    MAX(balance) AS max_balance
FROM account
GROUP BY branch_name;

-- [Problem 4]
CREATE VIEW branch_account_stats AS
SELECT
    branch_name,
    num_accounts,
    total_deposits / num_accounts AS avg_balance,
    min_balance,
    max_balance
FROM my_branch_account_stats
GROUP BY branch_name;

-- [Problem 5]
DELIMITER !

CREATE PROCEDURE sp_insert(
    IN sp_branch_name VARCHAR(15),
    IN sp_balance NUMERIC(12, 2)
)

BEGIN
    INSERT IGNORE INTO my_branch_account_stats
    (branch_name, num_accounts, total_deposits, min_balance, max_balance)
    VALUES (sp_branch_name, 1, sp_balance, sp_balance, sp_balance);
    
    UPDATE my_branch_account_stats
    SET num_accounts = num_accounts + 1,
        total_deposits = total_deposits + sp_balance,
        min_balance = LEAST(min_balance, sp_balance),
        max_balance = GREATEST(max_balance, sp_balance)
    WHERE branch_name = sp_branch_name;
END!

CREATE TRIGGER trg_insert
AFTER INSERT ON account
FOR EACH ROW

BEGIN
    CALL sp_insert(NEW.branch_name, NEW.balance);
END!

DELIMITER ;

-- [Problem 6]
DELIMITER !

CREATE PROCEDURE sp_delete(
    IN sp_branch_name VARCHAR(15),
    IN sp_balance NUMERIC(12, 2)
)

BEGIN
    IF 1 IN (
        SELECT num_accounts
        FROM my_branch_account_stats
        WHERE branch_name = sp_branch_name)
    THEN
        DELETE FROM my_branch_account_stats
        WHERE branch_name = sp_branch_name;
    ELSE
        UPDATE my_branch_account_stats
        SET num_accounts = num_accounts - 1,
            total_deposits = total_deposits - sp_balance,
            min_balance = (
                SELECT MIN(balance)
                FROM account
                WHERE branch_name = sp_branch_name),
            max_balance = (
                SELECT MAX(balance)
                FROM account
                WHERE branch_name = sp_branch_name)
        WHERE branch_name = sp_branch_name;
    END IF;
END!

CREATE TRIGGER trg_delete
AFTER DELETE ON account
FOR EACH ROW

BEGIN
    CALL sp_delete(OLD.branch_name, OLD.balance);
END!

DELIMITER ;

-- [Problem 7]
DELIMITER !

CREATE TRIGGER trg_update
AFTER UPDATE ON account
FOR EACH ROW

BEGIN
    CALL sp_insert(NEW.branch_name, NEW.balance);
    CALL sp_delete(OLD.branch_name, OLD.balance);
END!

DELIMITER ;


