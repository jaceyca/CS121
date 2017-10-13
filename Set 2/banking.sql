-- [Problem 1a]
SELECT loan_number, amount
FROM loan
WHERE amount >= 1000 AND amount <= 2000;

-- [Problem 1b]
SELECT loan.loan_number, amount
FROM loan
    INNER JOIN borrower
    ON loan.loan_number = borrower.loan_number
WHERE customer_name = 'Smith'
ORDER BY loan.loan_number;

-- [Problem 1c]
SELECT branch_city
FROM branch
WHERE branch_name = (
    SELECT branch_name
    FROM account
    WHERE account_number = 'A-446'
);

-- [Problem 1d]
SELECT DISTINCT customer_name, account.account_number, branch_name, balance
FROM depositor
    NATURAL JOIN account
WHERE customer_name
    LIKE 'J%'
ORDER BY customer_name;

-- [Problem 1e]
SELECT customer_name
FROM depositor
GROUP BY customer_name
    HAVING COUNT(*) > 5;

-- [Problem 2a]
CREATE VIEW pownal_customers AS
SELECT account.account_number, customer_name
FROM account
    NATURAL JOIN depositor
WHERE branch_name = 'Pownal';

-- [Problem 2b]
CREATE VIEW onlyacct_customers AS
SELECT customer_name, customer_street, customer_city
FROM customer
WHERE customer_name NOT IN (
    SELECT customer_name
    FROM depositor
        NATURAL JOIN borrower
)
AND customer_name IN (
    SELECT customer_name
    FROM depositor
        NATURAL JOIN account
)
WITH CHECK OPTION;

-- [Problem 2c]
CREATE VIEW branch_deposits AS
SELECT branch_name, SUM(balance) AS total_balance,
AVG(balance) AS average_balance
FROM account
    NATURAL JOIN depositor
GROUP BY branch_name;

-- [Problem 3a]
SELECT DISTINCT customer_city
FROM customer
WHERE customer_city NOT IN (
    SELECT branch_city
    FROM branch
)
ORDER BY customer_city;

-- [Problem 3b]
SELECT customer_name
FROM customer
WHERE customer_name NOT IN (
    SELECT customer_name 
    FROM depositor
) 
AND customer_name NOT IN (
    SELECT customer_name 
    FROM borrower
);

-- [Problem 3c]
UPDATE account
SET balance = balance + 50
WHERE branch_name IN (
    SELECT branch_name
    FROM branch
    WHERE branch_city = 'Horseneck'
);

-- [Problem 3d]
UPDATE account, branch
SET balance = balance + 50
WHERE branch_city = 'Horseneck' AND account.branch_name = branch.branch_name;

-- [Problem 3e]
SELECT DISTINCT account_number, branch_name, balance
FROM account 
    INNER JOIN (
        SELECT MAX(balance) AS max_balance
        FROM account
        GROUP BY branch_name
    ) AS largest_accounts 
    ON balance = largest_accounts.max_balance;

-- [Problem 3f]
SELECT *
FROM account
WHERE (branch_name, balance) IN (
    SELECT branch_name, MAX(balance)
    FROM account
    GROUP BY branch_name
);

-- [Problem 4]
SELECT branch.branch_name, branch.assets,
COUNT(test.branch_name) + 1 AS rank
FROM branch
    LEFT JOIN branch AS test
    ON branch.assets < test.assets
    GROUP BY branch.branch_name, branch.assets
    ORDER BY rank, branch.branch_name;
