-- [Problem 1]
DROP TABLE IF EXISTS emp_salaries;

-- Contains emp_id's and salaries, storing the employees in the subtree we are
-- working with. Employees are inserted into the table until the entire subtree
-- has been inserted.
CREATE TABLE emp_salaries (
    emp_id     INT PRIMARY KEY,
    salary     INT
);

DROP FUNCTION IF EXISTS total_salaries_adjlist;

DELIMITER !

-- Computes the sum of employee salaries in a subtree by using employee_adjlist
-- and emp_salaries.
CREATE FUNCTION total_salaries_adjlist(
    fn_emp_id INT
) RETURNS INT

BEGIN
    DECLARE sum INT DEFAULT 0;

    -- Clear the table
    DELETE FROM emp_salaries;

    -- Insert the specified employee and his salary into emp_salaries
    INSERT INTO emp_salaries
        SELECT emp_id, salary
        FROM employee_adjlist
        WHERE emp_id = fn_emp_id;

    -- Insert employees and salaries into emp_salaries if they are not already
    -- in emp_salaries and their manager is in emp_salaries. Continue doing this
    -- while there are nodes in previous levels, until all desired employees are
    -- in emp_salaries.
    WHILE ROW_COUNT() > 0 DO
        INSERT INTO emp_salaries SELECT emp_id, salary FROM employee_adjlist
            WHERE manager_id IN (SELECT emp_id FROM emp_salaries)
            AND emp_id NOT IN (SELECT emp_id FROM emp_salaries);
    END WHILE;
    
    SELECT SUM(salary) INTO sum FROM emp_salaries;
    RETURN sum;
END!

DELIMITER ;

-- [Problem 2]
DROP FUNCTION IF EXISTS total_salaries_nestset;

DELIMITER !

-- Computes the sum of all salaries in a subtree using employee_nestset.
CREATE FUNCTION total_salaries_nestset(
    fn_emp_id INT
) RETURNS INT

BEGIN
    DECLARE sum         INT DEFAULT 0;
    DECLARE emp_low     INT;
    DECLARE emp_high    INT;

    -- Select low from specified employee into emp_low.
    SELECT low INTO emp_low
    FROM employee_nestset
    WHERE emp_id = fn_emp_id;

    -- Select high from specified employee into emp_high.
    SELECT high INTO emp_high
    FROM employee_nestset
    WHERE emp_id = fn_emp_id;
    
    -- Sum the salaries of employees who have a low between emp_low and
    -- emp_high, which is the same as summing salaries of all employees
    -- in the subtree. Includes original employee's salary bc between
    -- is inclusive.
    SELECT SUM(salary) INTO sum
    FROM employee_nestset
    WHERE low BETWEEN emp_low AND emp_high;

    RETURN sum;
END!
DELIMITER ;

-- [Problem 3]
-- To find all employees that are leaves, we want to find employees that aren't
-- managers. We can select the manager_ids from employee_adjlist that are not
-- null, and we can compare with the emp_ids to see which employees aren't
-- managers.
SELECT emp_id, name, salary
FROM employee_adjlist
WHERE emp_id NOT IN (SELECT manager_id FROM employee_adjlist
                    WHERE manager_id IS NOT NULL);


-- [Problem 4]
-- To find all employees that are leaves, we want to find employees that aren't
-- managers. We can select employees that don't have another employee's low or
-- high between their low and high. We will use NOT EXISTS to make sure no
-- low or high exists between the employee's low or high.
SELECT emp_id, name, salary
FROM employee_nestset AS a
WHERE NOT EXISTS (
    SELECT low, high
    FROM employee_nestset AS b
    WHERE b.high < a.high AND b.low > a.low);


-- [Problem 5]
DROP TABLE IF EXISTS emp_id_only;

-- Contains only emp_ids, storing all the employees in emp_tree.
CREATE TABLE emp_id_only (
    emp_id     INT PRIMARY KEY
);

DROP FUNCTION IF EXISTS tree_depth;

DELIMITER !

-- I chose to use employee_adjlist because I realized I could reuse a lot of
-- the code for setting up employee_adjlist.
CREATE FUNCTION tree_depth()
    RETURNS INT

BEGIN
    -- The depth should default to 0 before the root is added
    DECLARE depth INT DEFAULT 0;

    -- Clear the table
    DELETE FROM emp_id_only;

    -- Insert the root of the tree into emp_id_only
    INSERT INTO emp_id_only
        SELECT emp_id
        FROM employee_adjlist
        WHERE manager_id IS NULL;

    -- Insert employees from employee_adjlist if they aren't already in
    -- emp_id_only and their manager is in emp_id_only. This inserts the tree
    -- into emp_id_only one level at a time, which means that if we count the
    -- number of insertions made, we can find the depth. (The first insert/root
    -- and the last insert/nothing cancel each other out).
    WHILE ROW_COUNT() > 0 DO
        -- increment depth
        SET depth = depth + 1;
        INSERT INTO emp_id_only SELECT emp_id FROM employee_adjlist
            WHERE manager_id IN (SELECT emp_id FROM emp_id_only)
            AND emp_id NOT IN (SELECT emp_id FROM emp_id_only);
    END WHILE;
    
    RETURN depth;
END!
DELIMITER ;

-- Testing
SELECT tree_depth();

-- [Problem 6]
DROP FUNCTION IF EXISTS emp_reports;

DELIMITER !

-- Uses employee_nestset to compute how many children (aka the employees that
-- the employee manages) the specified employee has in the organization.
CREATE FUNCTION emp_reports(
    fn_emp_id INT
) RETURNS INT

BEGIN
    DECLARE num_children INT DEFAULT 0;
    DECLARE emp_low INT;
    DECLARE emp_high INT;
    DECLARE emp_num_parents INT DEFAULT 0;

    -- Select low from specified employee into emp_low
    SELECT low INTO emp_low
    FROM employee_nestset
    WHERE emp_id = fn_emp_id;

    -- Select high from specified employee into emp_high
    SELECT high INTO emp_high
    FROM employee_nestset
    WHERE emp_id = fn_emp_id;

    -- Select the number of parents of the employee into emp_num_parents
    SELECT COUNT(*) INTO emp_num_parents
    FROM employee_nestset AS e
    WHERE e.high > emp_high AND e.low < emp_low;

    -- Select the number of children of employee into num_children.
    -- Children have a low or high contained within the specified
    -- employee's low and high.
    -- Children also have 1 more parent than the specified employee because
    -- they are one level above him.
    SELECT COUNT(*) INTO num_children
    FROM employee_nestset AS e
    WHERE e.low > emp_low AND e.high < emp_high AND
        emp_num_parents = (SELECT COUNT(*) AS num_parents
        FROM employee_nestset AS a
        WHERE a.high > e.high AND a.low < e.low) - 1;

    return num_children;
    
END!

DELIMITER ;
