CREATE TABLE KPMG_clients (
	order_id INT,
	product_id INT,
	customer_id INT,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	customer_address VARCHAR(255),
	postcode INT,
	state_code VARCHAR(20),
	order_date DATE,
	online_order VARCHAR(10),
	order_status VARCHAR(10),
	brand VARCHAR(20),
	product_line VARCHAR(20),
	product_class VARCHAR(20),
	product_size VARCHAR(20),
	order_total DECIMAL(10,2),
	first_sold_date DATE
);

SELECT * FROM KPMG_clients;

BULK INSERT KPMG_clients
FROM 'C:\Users\ovokp\OneDrive\Education and Resources\BVC Tech Skills Project\Database Management & Administration\Module 4\KPMG_client.csv'
WITH
	(FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE=300000);

SELECT * FROM KPMG_clients;


UPDATE KPMG_clients
SET state_code = CASE
	WHEN state_code = 'New South Wales' THEN 'NSW'
	WHEN state_code = 'Victoria' THEN 'VIC'
	END
WHERE state_code IN ('New South Wales', 'Victoria');


UPDATE KPMG_clients
SET product_id = 101
WHERE product_id = 0;

-- CREATE DATABASE TABLES --
SELECT customer_id, first_name, last_name, customer_address, postcode, state_code
INTO Customers
FROM KPMG_clients;

SELECT * FROM Customers;

SELECT order_id, order_date, product_id, customer_id, online_order, order_status, order_total
INTO Orders
FROM KPMG_clients;

SELECT * FROM Orders;

SELECT product_id, brand, product_line, product_class, product_size, first_sold_date
INTO Products
FROM KPMG_clients;

SELECT * FROM Products ORDER BY product_id;

SELECT brand, product_line, product_class
INTO ProductLines
FROM KPMG_clients;

SELECT * FROM ProductLines;


-- CHECK FOR DUPLICATES --
SELECT
customer_id,
COUNT(*) AS duplicate_counts
FROM Customers
GROUP BY customer_id
HAVING COUNT(customer_id)>1
ORDER BY customer_id;

WITH cte AS (
	SELECT
		customer_id,
		first_name, 
		last_name, 
		customer_address, 
		postcode, 
		state_code,
		ROW_NUMBER() OVER (
			PARTITION BY
				first_name, 
				last_name, 
				customer_address, 
				postcode, 
				state_code
			ORDER BY
				first_name, 
				last_name, 
				customer_address, 
				postcode, 
				state_code
		) row_num
	FROM
		Customers
)
DELETE FROM cte
WHERE row_num > 1;

SELECT * FROM Customers ORDER BY customer_id;



-- NO DUPLICATE ORDERS --
SELECT
order_id,
COUNT(*) AS counts
FROM Orders
GROUP BY order_id
HAVING COUNT(order_id)>1
ORDER BY order_id;

--DEALING WITH DUPLICATE PRODUCTS --
SELECT
product_id,
COUNT(*) AS duplicate_counts
FROM Products
GROUP BY product_id
HAVING COUNT(product_id)>1
ORDER BY product_id;


WITH cte AS (
	SELECT
		product_id,
		brand,
		product_line,
		product_class,
		product_size,
		ROW_NUMBER() OVER (
			PARTITION BY
				product_id,
				brand,
				product_line,
				product_class,
				product_size
			ORDER BY
				product_id,
				brand,
				product_line,
				product_class,
				product_size
		) row_num
	FROM
		Products
)
DELETE FROM cte
WHERE row_num > 1;

SELECT * FROM Products;

-- ADJUST IDENTITY KEY FOR PRODUCTS TABLE, since all rows are unique --

ALTER TABLE Products
DROP COLUMN product_id;


ALTER TABLE Products
ADD product_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL;

SELECT * FROM Products ORDER BY product_id;

-- CHECK FOR DUPLICATES IN ProductLine TABLE --
SELECT
product_line,
COUNT(*) AS duplicate_counts
FROM ProductLines
GROUP BY product_line
HAVING COUNT(product_line)>1
ORDER BY product_line;

WITH cte AS (
	SELECT
		brand,
		product_line,
		product_class,
		ROW_NUMBER() OVER (
			PARTITION BY
				brand,
				product_line,
				product_class
			ORDER BY
				brand,
				product_line,
				product_class
		) row_num
	FROM
		ProductLines
)
DELETE FROM cte
WHERE row_num > 1;



SELECT * FROM ProductLines;

-- INSERT IDENTITY COLUMN FOR ProductLines TABLE --
ALTER TABLE ProductLines
ADD product_line_id INT IDENTITY(1,1) PRIMARY KEY NOT NULL;

-- WE NOW VERIFY THE ABSENCE OF DUPLICATES IN THE ProductLines TABLE --
SELECT
product_line_id,
COUNT(*) AS duplicate_counts
FROM ProductLines
GROUP BY product_line_id
HAVING COUNT(product_line_id)>1
ORDER BY product_line_id;


-- UPDATE Products TABLE with unique product line id --
ALTER TABLE Products
ADD product_line_id INT;


SELECT * FROM Products;

UPDATE Products
SET product_line_id = CASE
	WHEN brand = 'Trek Bicycles' AND product_line = 'Standard' AND product_class = 'high' THEN 1
	WHEN brand = 'Norco Bicycles' AND product_line = 'Standard' AND product_class = 'low' THEN 2
	WHEN brand = 'OHM Cycles' AND product_line = 'Road' AND product_class = 'high' THEN 3
	WHEN brand = 'Norco Bicycles' AND product_line = 'Mountain' AND product_class = 'low' THEN 4
	WHEN brand = 'Norco Bicycles' AND product_line = 'Road' AND product_class = 'medium' THEN 5
	WHEN brand = 'Giant Bicycles' AND product_line = 'Road' AND product_class = 'medium' THEN 6
	WHEN brand = 'Giant Bicycles' AND product_line = 'Standard' AND product_class = 'medium' THEN 7
	WHEN brand = 'Trek Bicycles' AND product_line = 'Road' AND product_class = 'low' THEN 8
	WHEN brand = 'Solex' AND product_line = 'Standard' AND product_class = 'low' THEN 9
	WHEN brand = 'Solex' AND product_line = 'Road' AND product_class = 'medium' THEN 10
	WHEN brand = 'OHM Cycles' AND product_line = 'Standard' AND product_class = 'medium' THEN 11
	WHEN brand = 'OHM Cycles' AND product_line = 'Standard' AND product_class = 'high' THEN 12
	WHEN brand = 'Trek Bicycles' AND product_line = 'Standard' AND product_class = 'medium' THEN 13
	WHEN brand = 'WeareA2B' AND product_line = 'Touring' AND product_class = 'medium' THEN 14
	WHEN brand = 'Solex' AND product_line = 'Touring' AND product_class = 'medium' THEN 15
	WHEN brand = 'WeareA2B' AND product_line = 'Standard' AND product_class = 'low' THEN 16
	WHEN brand = 'WeareA2B' AND product_line = 'Road' AND product_class = 'low' THEN 17
	WHEN brand = 'Trek Bicycles' AND product_line = 'Mountain' AND product_class = 'low' THEN 18
	WHEN brand = 'Norco Bicycles' AND product_line = 'Road' AND product_class = 'high' THEN 19
	WHEN brand = 'Giant Bicycles' AND product_line = 'Touring' AND product_class = 'medium' THEN 20
	WHEN brand = 'Giant Bicycles' AND product_line = 'Road' AND product_class = 'low' THEN 21
	WHEN brand = 'Giant Bicycles' AND product_line = 'Standard' AND product_class = 'high' THEN 22
	WHEN brand = 'Trek Bicycles' AND product_line = 'Road' AND product_class = 'medium' THEN 23
	WHEN brand = 'Trek Bicycles' AND product_line = 'Standard' AND product_class = 'low' THEN 24
	WHEN brand = 'WeareA2B' AND product_line = 'Standard' AND product_class = 'medium' THEN 25
	WHEN brand = 'OHM Cycles' AND product_line = 'Standard' AND product_class = 'low' THEN 26
	WHEN brand = 'Norco Bicycles' AND product_line = 'Standard' AND product_class = 'medium' THEN 27
	WHEN brand = 'OHM Cycles' AND product_line = 'Road' AND product_class = 'medium' THEN 28
	WHEN brand = 'Solex' AND product_line = 'Standard' AND product_class = 'medium' THEN 29
	WHEN brand = 'OHM Cycles' AND product_line = 'Touring' AND product_class = 'low' THEN 30
	WHEN brand = 'Norco Bicycles' AND product_line = 'Standard' AND product_class = 'high' THEN 31
	WHEN brand = 'Solex' AND product_line = 'Standard' AND product_class = 'high' THEN 32
	END
WHERE brand IN ('Trek Bicycles', 'Norco Bicycles', 'OHM Cycles', 'Giant Bicycles','Solex', 'WeareA2B')
AND product_line IN ('Standard', 'Road', 'Mountain', 'Touring')
AND product_class IN ('low', 'medium', 'high');

-- REMOVE COLUMNS VIOLATING 3NF FROM Products TABLE --
ALTER TABLE Products
DROP COLUMN brand, product_line, product_class;

SELECT * FROM Products;
DELETE FROM ProductLines WHERE brand IS NULL;

ALTER TABLE Customers
ALTER COLUMN customer_id INT NOT NULL;

ALTER TABLE Customers
ADD CONSTRAINT PK_Customers PRIMARY KEY (customer_id);



ALTER TABLE Products
ALTER COLUMN product_id INT NOT NULL;

ALTER TABLE Products
ADD CONSTRAINT PK_Products PRIMARY KEY (product_id);

ALTER TABLE Products
ADD CONSTRAINT FK_ProductLineID FOREIGN KEY (product_line_id)
REFERENCES ProductLines(product_line_id);




ALTER TABLE Orders
ALTER COLUMN order_id INT NOT NULL;

ALTER TABLE Orders
ADD CONSTRAINT PK_Orders PRIMARY KEY (order_id);

ALTER TABLE Orders
ADD CONSTRAINT FK_productID FOREIGN KEY (product_id)
REFERENCES Products(product_id);

ALTER TABLE Orders
ADD CONSTRAINT FK_CustomerID FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id);

SELECT * FROM Customers;

SELECT * FROM Orders;

SELECT * FROM Products;

SELECT * FROM ProductLines;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

--COURSE PROJECT --

CREATE DATABASE Review_Project;

USE Review_Project;

DROP TABLE IF EXISTS gradeRecord;

CREATE TABLE gradeRecord (
	studentID INT,
	firstName VARCHAR(50),
	lastName VARCHAR(50),
	midTermExam DECIMAL(10,2),
	finalExam DECIMAL(10,2),
	assignment1 DECIMAL(10,2),
	assignment2 DECIMAL(10,2),
	totalPoints INT,
	studentAverage DECIMAL(10,2),
	grade VARCHAR(5)
);

BULK INSERT gradeRecord
FROM 'C:\Users\ovokp\OneDrive\Education and Resources\BVC Tech Skills Project\Database Management & Administration\Course Review Project\gradeRecordModuleV.csv'
WITH
	(FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	BATCHSIZE = 300000);

SELECT * FROM gradeRecord;

SELECT
studentID,
COUNT(*) AS duplicate_values
FROM gradeRecord
GROUP BY studentID
HAVING COUNT(studentID)>1
ORDER BY studentID;

/*
gradeRecord TABLE appears to violates 1NF. CREATE IDENTITY COLUMN and call it scoreID.
PURPOSE? AS PRIMARY KEY for the StudentScores TABLE TO BE CREATED BELOW
*/

ALTER TABLE gradeRecord
ADD scoreID INT IDENTITY(1,1);

-- Replace studentAverage with a calculated column for better granularity --
ALTER TABLE gradeRecord
DROP COLUMN studentAverage;

ALTER TABLE gradeRecord
ADD studentAverage AS ((assignment1 + assignment2 + midTermExam + finalExam)/4);





-- CREATE DATABASE TABLES AND VERIFY NORMALIZATION RULES --
SELECT studentID, firstName, lastName, scoreID
INTO StudentNames
FROM gradeRecord;

SELECT * FROM studentNames;

SELECT
studentID,
COUNT(*) AS duplicate_values
FROM studentNames
GROUP BY studentID
HAVING COUNT(studentID)>1
ORDER BY studentID;

-- Duplicates Found, same as above --
/*   DECISION: Make a Composite Key out of StudentID, firstName, lastName 
           IN ORDER TO PRESERVE INCORRECTLY ENTERED DATA                   */

SELECT scoreID, assignment1, assignment2, midTermExam, finalExam
INTO StudentScores
from gradeRecord;

SELECT * FROM studentScores;

-- TO QUERY DROPPED COLUMNS BY CALCULATION --
SELECT
*,
((midTermExam + finalExam + assignment1 + assignment2)*100) AS totalPoints,
((midTermExam + finalExam + assignment1 + assignment2)/4) AS studentAverage
FROM studentScores
ORDER BY studentAverage DESC;
-- Other options: Create a View OR write this query into a Stored Procedure --

SELECT
scoreID,
COUNT(*) AS duplicate_values
FROM studentScores
GROUP BY scoreID
HAVING COUNT(scoreID)>1
ORDER BY scoreID;
--VERIFIED no duplicate records in StudentScores--

SELECT DISTINCT studentAverage, grade
INTO GradeList
FROM gradeRecord;

SELECT * FROM GradeList;
/*       Could have used a CASE/WHEN statement to assign Grades, but would not do so arbitrarily. 
                         Need to check with relevant Faculty or Admin authority                                  */

SELECT
studentAverage,
COUNT(*) AS duplicate_values
FROM GradeList
GROUP BY studentAverage
HAVING COUNT(*)>1
ORDER BY studentAverage;

/*
DROP TABLE GradeList;
DROP TABLE StudentNames;
DROP TABLE StudentScores;
*/

-- ADDING NORMALIZATION CONSTRAINTS --
ALTER TABLE StudentNames
ALTER COLUMN studentID INT NOT NULL;

ALTER TABLE StudentNames
ALTER COLUMN firstName VARCHAR(50) NOT NULL;

ALTER TABLE StudentNames
ALTER COLUMN lastName VARCHAR(50) NOT NULL;

ALTER TABLE StudentNames
ADD CONSTRAINT PK_StudentID PRIMARY KEY(studentID, firstName, lastName); --COMPOSITE KEY--

ALTER TABLE StudentNames
ADD CONSTRAINT FK_ScoreID FOREIGN KEY(scoreID)
REFERENCES StudentScores(scoreID);

ALTER TABLE StudentScores
ALTER COLUMN scoreID INT NOT NULL;

ALTER TABLE StudentScores
ADD CONSTRAINT PK_ScoreID PRIMARY KEY(scoreID);

ALTER TABLE GradeList
ALTER COLUMN studentAverage DECIMAL(17,4) NOT NULL;

ALTER TABLE GradeList
ALTER COLUMN grade VARCHAR(5) NOT NULL;

ALTER TABLE GradeList
ADD CONSTRAINT PK_Grades PRIMARY KEY (studentAverage, grade); -- ANOTHER COMPOSITE, plus issues regarding Grade Assignment --



-- CONSOLIDATED TABLE FROM JOINS --
WITH TotalScoreTable AS(
	SELECT
		*,
		((midTermExam + finalExam + assignment1 + assignment2)*100) AS totalPoints,
		((midTermExam + finalExam + assignment1 + assignment2)/4) AS studentAverage
	FROM studentScores
)
SELECT
	c.studentID,
	c.firstName,
	c.lastName,
	a.assignment1,
	a.assignment2,
	a.midTermExam,
	a.finalExam,
	a.totalPoints,
	a.studentAverage,
	b.grade
FROM TotalScoreTable as a
INNER JOIN GradeList as b
ON a.studentAverage = b.studentAverage
INNER JOIN StudentNames as c
ON a.scoreID = c.scoreID;
