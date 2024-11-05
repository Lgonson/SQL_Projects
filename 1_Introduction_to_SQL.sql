
-- Where statements:

SELECT *
FROM parks_and_recreation.employee_salary
WHERE salary >= 50000;

SELECT *
FROM parks_and_recreation.employee_demographics
WHERE birth_date > '1985-07-20';

-- AND OR NOT -- Logical Operators

SELECT *
FROM parks_and_recreation.employee_demographics
WHERE (first_name = 'Leslie' AND age = 44) OR age > 55;

-- LIKE Statement
-- % and _

-- llamar a la tabla employee_demographics:

SELECT *
FROM parks_and_recreation.employee_demographics;

-- llamar a la tabla employee_salary:

SELECT *
FROM parks_and_recreation.employee_salary;

-- llamar a la tabla parks_departments:

SELECT *
FROM parks_and_recreation.parks_departments;

-- JOIN 3 different tables

SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments pd
ON sal.dept_id = pd.department_id;

-- UNIONS:

SELECT first_name, last_name, 'Old Man' AS Label2
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old Lady' AS Label1
FROM employee_demographics
WHERE AGE > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Higly Paid Employee' AS Salary
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name;

-- Length function:

-- String Functions
SELECT LENGTH('Skyfall');

-- Upper and Lower function:

SELECT first_name, UPPER(first_name), LOWER(first_name)
FROM employee_salary
ORDER BY LENGTH(first_name);

-- Substring function:

SELECT birth_date,
SUBSTRING(birth_date,1,4) AS Birth_year,
SUBSTRING(birth_date,6,2) AS Birth_month,
SUBSTRING(birth_date,9,2) AS Birth_day
FROM employee_demographics;

-- Replace function:

SELECT first_name, REPLACE(first_name, 'A', 'Z') as A,
REPLACE(first_name, 'a', 'z') as B
FROM employee_demographics; 

-- Locate function:

SELECT first_name, LOCATE('an', first_name)
FROM employee_demographics;

-- Concatenation using SQL

SELECT first_name, last_name,
CONCAT(first_name, ' ', last_name) AS Full_name
FROM employee_demographics;

-- Case statement: primera parte

SELECT first_name,
last_name, 
age,
CASE
	WHEN age <= 30 THEN 'Young'
	WHEN age BETWEEN 31 and  50 THEN 'Old'
	WHEN age >= 50 THEN 'On Deaths Door'
END AS Age_Bracket
FROM employee_demographics;

-- Case statement: ejercicio de aumento de sueldos y bono empresarial

-- New Salary
-- < 50.000 = 5%
-- > 50.0000 = 7%
-- Bonus finance = 10%

SELECT first_name, last_name, dept_id, salary,
CASE
	WHEN salary < 50000 THEN salary + (salary * 0.05)
    WHEN salary > 50000 THEN salary + (salary * 0.07)
END AS New_Salary,
CASE
	WHEN dept_id = 6 THEN salary * 0.10
END as Bonus
FROM employee_salary;

-- Subqueries:

SELECT * 
FROM employee_demographics
WHERE employee_id IN 
	(SELECT employee_id
    FROM employee_salary
    WHERE dept_id = 1);

-- Window functions vs Group by

-- Group by:    

SELECT gender, AVG(salary) as avg_salary
FROM employee_demographics as dem
JOIN employee_salary as sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender;

-- Window function:

SELECT dem.first_name, dem.last_name, sal.salary, gender, AVG(salary) OVER(PARTITION BY gender) as avg_salary
FROM employee_demographics dem
JOIN employee_salary sal
ON dem.employee_id = sal.employee_id;

-- Rolling total using Window function:

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, sal.salary,
SUM(salary) OVER(PARTITION BY gender ORDER BY dem.employee_id) as Rolling_Total
FROM employee_demographics dem
JOIN employee_salary sal
ON dem.employee_id = sal.employee_id;

-- ROW_NUMBER vs RANK vs DENSE_RANK (continua siendo parte de Window functions)

SELECT dem.employee_id, dem.first_name, dem.last_name, gender, sal.salary,
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) as row_numb,
RANK() OVER(PARTITION BY gender ORDER BY salary DESC) as rank_num,
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) as dense_num
FROM employee_demographics dem
JOIN employee_salary sal
ON dem.employee_id = sal.employee_id;

-- CTE's (Common Table Expression) 1 de 3

WITH CTE_Example AS 
(
SELECT gender, AVG(salary) avg_salary, MAX(salary) max_salary, MIN(salary) min_salary, COUNT(salary) count_salary
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT AVG(avg_salary)
FROM CTE_Example;

-- CTE's 2 de 3

WITH CTE_Example1 AS
(
SELECT employee_id, gender, birth_date
FROM employee_demographics
WHERE birth_date > '1985-01-01'
),
CTE_Example2 AS
(
SELECT *
FROM employee_salary
WHERE salary > 50000
)
SELECT *
FROM CTE_Example1
JOIN CTE_Example2
	ON CTE_Example1.employee_id = CTE_Example2.employee_id;
    
-- CTE's 3 de 3
    
WITH CTE_Example (Gender, AVG_Sal, MAX_Sal, MIN_Sal, COUNT_Sal) AS
(
SELECT gender, AVG(salary), MAX(salary), MIN(salary), COUNT(salary)
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT *
FROM CTE_Example;

-- Temporary Tables 1 de 2

CREATE TEMPORARY TABLE temp_table
(first_name varchar(50),
second_name varchar(50),
favourite_movie varchar(100)
);

SELECT *
FROM temp_table;

INSERT INTO temp_table
VALUES('Lucas','Gonzalez Sonnenberg', 'The Matrix');

SELECT *
FROM temp_table;

-- Temporary Tables 2 de 2

CREATE TEMPORARY TABLE salary_over_50k
SELECT *
FROM employee_salary
WHERE salary >= 50000;

SELECT * 
FROM salary_over_50k;

-- Stored Procedures 1 de 3

CREATE PROCEDURE large_salaries()
SELECT * 
FROM employee_salary
WHERE salary >= 50000;

CALL large_salaries;

-- Stored Procedures 2 de 3

DELIMITER $$
CREATE PROCEDURE large_salaries2()
BEGIN
	SELECT *
    FROM employee_salary
    WHERE salary > 50000;
    SELECT *
	FROM employee_salary
    WHERE salary > 10000;
END $$
DELIMITER ;

CALL large_salaries2();

-- Stored Procedures 3 de 3 (Parameter)

DELIMITER $$
CREATE PROCEDURE large_salaries3(huggymuffin INT)
BEGIN
	SELECT salary
    FROM employee_salary
    WHERE employee_id = huggymuffin;

END $$
DELIMITER ;

CALL large_salaries3(1);

-- Triggers

DELIMITER $$
CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN 
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$
DELIMITER ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES(13, 'Lucas', 'Gonzalez Sonnenberg', 'Data Analyst', 55000, NULL);

-- Control the trigger:

SELECT *
FROM employee_demographics;

SELECT *
FROM employee_salary;

-- Events:

DELIMITER $$
CREATE EVENT delete_retirees
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
	DELETE 
    FROM employee_demographics
    WHERE age > 60;
END $$
DELIMITER ; 

SELECT *
FROM employee_demographics;

SHOW VARIABLES LIKE 'event%';




