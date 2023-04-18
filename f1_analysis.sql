SET SQL_SAFE_UPDATES = 0;

USE formula1db;


CREATE TABLE practice1 (
	pos INT, 
    driver_num INT, 
    driver VARCHAR(20), 
    car VARCHAR(30), 
    time VARCHAR(20), 
    gap VARCHAR(20), 
    laps INT
);

CREATE TABLE practice2 (
	pos INT, 
    driver_num INT, 
    driver VARCHAR(20), 
    car VARCHAR(30), 
    time VARCHAR(20), 
    gap VARCHAR(20), 
    laps INT
);

CREATE TABLE practice3 (
	pos INT, 
    driver_num INT, 
    driver VARCHAR(20), 
    car VARCHAR(30), 
    time VARCHAR(20), 
    gap VARCHAR(20), 
    laps INT
);

CREATE TABLE qualifying (
	pos INT, 
    driver_num INT, 
    driver VARCHAR(20), 
    car VARCHAR(30), 
    q1 VARCHAR(20), 
	q2 VARCHAR(20), 
	q3 VARCHAR(20), 
    laps INT
);


LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/archive\ \(11\)/2023/Bahrain\ GP/practice-1.csv '
INTO TABLE practice1  FIELDS TERMINATED BY ','
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/archive\ \(11\)/2023/Bahrain\ GP/practice-2.csv '
INTO TABLE practice2  FIELDS TERMINATED BY ','
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/archive\ \(11\)/2023/Bahrain\ GP/practice-3.csv '
INTO TABLE practice3  FIELDS TERMINATED BY ','
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/archive\ \(11\)/2023/Bahrain\ GP/qualifying.csv '
INTO TABLE qualifying  FIELDS TERMINATED BY ','
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- convert time into seconds (string into numbers) 


-- practice1 conversion 
ALTER TABLE practice1 
ADD minute_to_second DOUBLE; 

UPDATE practice1 
SET minute_to_second = convert(substring_index(time, ':', 1 ), DOUBLE) * 60;



ALTER TABLE practice1
ADD second_to_second DOUBLE; 

UPDATE practice1 
SET second_to_second = convert(substring_index(time, ':', -1 ), DOUBLE); 

ALTER TABLE practice1 
ADD time_in_seconds DOUBLE; 

UPDATE practice1 
SET time_in_seconds = minute_to_second + second_to_second; 

UPDATE practice1 
SET driver = substring(driver, length(driver) - 3, length(driver)); 


-- practice2 conversion
ALTER TABLE practice2 
ALTER minute_to_second double; 

UPDATE practice2 
SET minute_to_second = convert(substring_index(time, ':', 1 ), double) * 60;



ALTER TABLE practice2
add second_to_second double; 

UPDATE practice2 
SET second_to_second = convert(substring_index(time, ':', -1 ), double); 

ALTER TABLE practice2 
add time_in_seconds double; 

UPDATE practice2 
SET time_in_seconds = minute_to_second + second_to_second; 

UPDATE practice2
SET driver = substring(driver, length(driver) - 3, length(driver)); 


-- practice3 conversion
ALTER TABLE practice3
ADD minute_to_second double; 

UPDATE practice3
SET minute_to_second = convert(substring_index(time, ':', 1 ), double) * 60;



ALTER TABLE practice3
ADD second_to_second double; 

UPDATE practice3
SET second_to_second = convert(substring_index(time, ':', -1 ), double); 

ALTER TABLE practice3
add time_in_seconds double; 

UPDATE practice3
SET time_in_seconds = minute_to_second + second_to_second; 

SELECT * FROM practice1 
UNION 
SELECT * FROM practice2 
UNION 
SELECT * FROM practice3
; 

UPDATE practice3 
SET driver = substring(driver, length(driver) - 3, length(driver)); 


-- ranks drivers in order based on performance during practice
WITH cte AS (
	SELECT * FROM practice1 
	UNION SELECT * FROM practice2 
	UNION SELECT * FROM practice3

) SELECT driver, avg(time_in_seconds) AS pace
FROM cte 
GROUP BY driver
ORDER BY pace ASC; 



-- converting time to seconds in qualifying session 
ALTER TABLE qualifying
ADD q1_updated varchar(30); 

ALTER TABLE qualifying
ADD q2_updated varchar(30); 

ALTER TABLE qualifying
ADD q3_updated varchar(30); 


ALTER TABLE qualifying
ADD q1_min double; 

ALTER TABLE qualifying 
ADD q1_sec double; 

ALTER TABLE qualifying
ADD q2_min double; 

ALTER TABLE qualifying 
ADD q2_sec double; 

ALTER TABLE qualifying
ADD q3_min double; 

ALTER TABLE qualifying 
ADD q3_sec double; 

ALTER TABLE qualifying 
ADD q1_in_seconds double;

ALTER TABLE qualifying 
ADD q2_in_seconds double;

ALTER TABLE qualifying 
ADD q3_in_seconds double; 


UPDATE qualifying
SET q1_updated = q1; 

UPDATE qualifying
SET q2_updated = 
CASE 
	WHEN q2 = 'DNF' THEN q1
	WHEN q2 = '' THEN q1 
	ELSE q2
	END;
    
    
UPDATE qualifying
SET q3_updated = 
CASE 
	WHEN q3 = 'DNF' THEN q2_updated
	WHEN q3 = '' THEN q2_updated
	ELSE q3
	END;
    
UPDATE qualifying 
SET q1_min = convert(substring_index(q1_updated, ':', 1 ), double) * 60;

UPDATE qualifying 
SET q1_sec = convert(substring_index(q1_updated, ':', -1 ), double);

UPDATE qualifying 
SET q2_min = convert(substring_index(q2_updated, ':', 1 ), double) * 60;

UPDATE qualifying 
SET q2_sec = convert(substring_index(q2_updated, ':', -1 ), double);

UPDATE qualifying 
SET q3_min = convert(substring_index(q3_updated, ':', 1 ), double) * 60;

UPDATE qualifying 
SET q3_sec = convert(substring_index(q3_updated, ':', -1 ), double);


UPDATE qualifying
SET q1_in_seconds = q1_min + q1_sec; 

UPDATE qualifying
SET q2_in_seconds = q2_min + q2_sec; 

UPDATE qualifying
SET q3_in_seconds = q3_min + q3_sec; 

ALTER TABLE qualifying
ADD time_in_seconds double; 

UPDATE qualifying
SET time_in_seconds = (q1_in_seconds + q2_in_seconds + q3_in_seconds)/3 ;

-- drop unnecessary columns to create a combined table 

ALTER TABLE practice1 
	DROP column time,
	DROP column gap,
	DROP column minute_to_second, 
	DROP column second_to_second; 

ALTER TABLE practice2
	DROP column time,
	DROP column gap,
	DROP column minute_to_second, 
	DROP column second_to_second; 

ALTER TABLE practice3 
	DROP column time,
	DROP column gap,
	DROP column minute_to_second, 
	DROP column second_to_second; 

SELECT * FROM qualifying;

ALTER TABLE qualifying
    DROP column q1, 
    DROP column q2, 
    DROP column q3, 
    DROP column q1_updated, 
    DROP column q2_updated, 
    DROP column q3_updated, 
    DROP column q1_min, 
    DROP column q1_sec, 
    DROP column q2_min, 
    DROP column q2_sec, 
    DROP column q3_min, 
    DROP column q3_sec, 
    DROP column q1_in_seconds, 
    DROP column q2_in_seconds, 
    DROP column q3_in_seconds; 
	
-- ranks drivers based on performance from all practice and qualifying sessions
WITH pacecte AS (
	SELECT * FROM practice1 UNION
    SELECT * FROM practice2 UNION
    SELECT * FROM practice3 UNION 
    SELECT * FROM qualifying
) SELECT driver, car, avg(time_in_seconds) AS pace, avg(laps) AS laps, avg(pos) AS avg_pos
FROM pacecte
GROUP BY driver, car
ORDER BY avg_pos ; 

CREATE TABLE pace_prediction (
    driver varchar(30), 
    car varchar(30), 
    pace double, 
    laps double, 
    avg_pos double
);

with pacecte AS (
	SELECT * FROM practice1 UNION
    SELECT * FROM practice2 UNION
    SELECT * FROM practice3 UNION 
    SELECT * FROM qualifying
) 
UPDATE pace_prediction 
SET driver = 
pacecte.driver;


UPDATE qualifying 
SET driver = substring(driver, length(driver) - 3, length(driver)); 

CREATE TABLE pace_prediction AS 
with pacecte AS (
	SELECT * FROM practice1 UNION
    SELECT * FROM practice2 UNION
    SELECT * FROM practice3 UNION 
    SELECT * FROM qualifying
) SELECT driver, car, avg(time_in_seconds) AS pace, avg(laps) AS laps, avg(pos) AS avg_pos
FROM pacecte
GROUP BY driver, car
ORDER BY avg_pos;

SELECT * FROM pace_prediction;









