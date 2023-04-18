SET SQL_SAFE_UPDATES = 0; 


CREATE DATABASE sports_car_prices; 

USE sports_car_prices; 


CREATE TABLE sports_car (
	car_make VARCHAR(30), 
    car_model VARCHAR(30), 
    year VARCHAR(30), 
    engine_size VARCHAR(30), 
    horsepower VARCHAR(30), 
    torque VARCHAR(30), 
    zero_to_60 VARCHAR(30), 
    price VARCHAR(30)
);



LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/Sport\ car\ price.csv'
INTO TABLE sports_car
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;



-- certain models have incorrect horsepower values such as 1000+ 
-- we first clean the data to fix these values
UPDATE sports_car 
SET horsepower = substring_index(horsepower, '+', 1)
WHERE substring(horsepower, length(horsepower),length(horsepower)) = '+'; 

-- some horsepower values have a comma in them. we fix this 

SELECT * FROM sports_car
WHERE horsepower LIKE '%,%'; 



-- remove comma from horsepower value that contains comma 
UPDATE sports_car 
SET horsepower = substring_index(horsepower, ',', 1) + substring_index(horsepower, ',', -1)
WHERE horsepower LIKE '%,%'; 


UPDATE sports_car 
SET horsepower = convert(horsepower, double);

ALTER TABLE sports_car 
ADD horse_power double; 

UPDATE sports_car 
SET horse_power = convert(horsepower, double); 



-- we find an outlier Tesla model with horsepower of 10000, which is clearly an input error. we fix the horsepower 

UPDATE sports_car 
SET horsepower = 1000 
WHERE car_make = 'tesla' 
AND car_model = 'roadster'
AND horsepower > 5000;

-- some data records have incorrect horsepower value where two identical models with the same year and make have different values. 
-- we correct this by using the larger value of the two using selfjoin. 


UPDATE sports_car 
AS a JOIN sports_car AS b 
ON a.car_make = b.car_make
AND a.car_model = b.car_model 
AND a.year = b.year 
AND a.horsepower != b.horsepower
SET a.horsepower = greatest(a.horsepower, b.horsepower);



UPDATE sports_car 
AS a JOIN sports_car AS b 
ON a.car_make = b.car_make
AND a.car_model = b.car_model 
AND a.year = b.year 
AND a.horsepower != b.horsepower
SET b.horsepower = greatest(a.horsepower, b.horsepower);


-- price field contains comma, which we want removed. 

ALTER TABLE sports_car
ADD price_ double; 


UPDATE sports_car 
SET price_ =
CASE 
	WHEN length(price) <= 7 THEN convert(concat(substring_index(price, ',', 1), substring_index(price, ',', -1)), double)
	WHEN length(price) > 7 THEN convert(concat(substring_index(price, ',', 1), substring_index(substring_index(price, ',', 2), ',', -1), 
					substring_index(price, ',', -1)), double)
	ELSE price
	END;

ALTER TABLE sports_car 
DROP column price; 

ALTER TABLE sports_car
RENAME column price_ to price; 



-- delete tesla vehicles with horsepower input error
DELETE FROM sports_car 
WHERE car_make = 'tesla' 
AND horsepower <= 500; 




-- fix engine_size values: electric vehicles and hybrids have values other than numbers
SELECT * FROM sports_Car WHERE concat('',convert(engine_size, double) * 1) != engine_size;

UPDATE sports_car
SET engine_size = 'electric' 
WHERE engine_size LIKE '%electric%';

UPDATE sports_car
SET engine_size = 'hybrid' 
WHERE engine_size LIKE '%hybrid%';

UPDATE sports_car
SET engine_size = 'electric' 
WHERE engine_size LIKE '%n/a%';


UPDATE sports_car
SET engine_size = 'electric' 
WHERE engine_size LIKE '%-%';

UPDATE sports_car
SET engine_size = 'electric' 
WHERE engine_size LIKE '0';


-- fix torque values 

SELECT DISTINCT torque FROM sports_car ORDER BY torque; 

SELECT * FROM sports_car WHERE torque LIKE '%+%';



UPDATE sports_car 
SET torque = 7376 
WHERE car_make = 'tesla' 
AND car_model = 'roadster';  

UPDATE sports_car 
SET torque = 1020 
WHERE car_model = 'model s plaid' 
AND torque = 'n/a';

UPDATE sports_car 
SET torque = 520 
WHERE car_make = 'maserati'
AND car_model = 'granturismo';

ALTER TABLE sports_car 
DROP column electric; 

SELECT * FROM sports_car 
WHERE torque = 'n/a' ;


ALTER TABLE sports_car 
ADD torque_ double ;

UPDATE sports_car 
SET torque = 
CASE 
	WHEN torque LIKE '%,%' THEN concat(substring_index(torque, ',', 1), substring_index(torque, ',', -1))
	ELSE torque
	END; 


ALTER TABLE sports_car 
MODIFY torque double; 

SELECT * FROM sports_car 
WHERE torque LIKE '%,%'; 

ALTER TABLE sports_car 
MODIFY zero_to_60 double; 





CREATE TABLE car_data AS
with cte AS (
	SELECT * FROM sports_car 
) SELECT * FROM cte; 





SELECT car_make, car_model, min(zero_to_60) AS pace
FROM sports_car 
GROUP BY car_make, car_model
ORDER BY pace ;


SELECT * FROM car_data AS a
WHERE zero_to_60 = (SELECT  min(zero_to_60) FROM car_data AS b WHERE a.car_make = b.car_make)
ORDER BY zero_to_60, car_make;

SELECT car_make,  min(zero_to_60) AS acceleration FROM car_data AS a
WHERE zero_to_60 = (SELECT  min(zero_to_60)FROM car_data AS b WHERE a.car_make = b.car_make)
GROUP BY car_make 
ORDER BY acceleration, car_make;

CREATE TABLE brand_by_acceleration AS 
with cte AS (SELECT car_make,  min(zero_to_60) AS acceleration FROM car_data AS a
WHERE zero_to_60 = (SELECT  min(zero_to_60) FROM car_data AS b WHERE a.car_make = b.car_make)
GROUP BY car_make 
GROUP BY acceleration, car_make) SELECT * FROM cte; 



SELECT car_make, car_model, year, avg(horsepower), avg(zero_to_60) AS pace, 
avg(torque) FROM car_data 
GROUP BY car_make, car_model, year
ORDER BY pace 
LIMIT 15;

SELECT car_make, car_model, avg(horsepower) AS horsepower, avg(zero_to_60) AS acceleration, 
avg(torque) AS torque FROM car_data 
GROUP BY car_make, car_model
ORDER BY acceleration 
LIMIT 15;




