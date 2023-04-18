SET sql_safe_updates = 0; 

CREATE database crowded_airports;

USE crowded_airports;

CREATE TABLE airports (
	airport_rank INT, 
    airport VARCHAR(50), 
    location VARCHAR(50), 
    country VARCHAR(50), 
    code VARCHAR(20), 
    passengers INT, 
    year INT
);

LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/Airports.csv'
INTO TABLE airports
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;



SELECT *, COUNT(country) OVER (PARTITION BY country) AS country_count 
FROM airports
WHERE year = 2020
ORDER BY country_count DESC; 

-- shows number of most crowded airports in each country
SELECT country, COUNT(country) AS country_count
FROM airports
WHERE year = 2020
GROUP BY country
ORDER BY country_count DESC;

-- shows most crowded airports in the US
SELECT *
FROM airports 
WHERE country LIKE 'united states%'
AND year = 2020
ORDER BY passengers DESC; 

-- show the states where the US airports are located in
ALTER TABLE airports
ADD state VARCHAR(20); 

UPDATE airports
SET state = substring_index(location, ',', -1);

-- show airport codes in a modified way
ALTER TABLE airports
ADD airport_code VARCHAR(5);

UPDATE airports
SET airport_code = substring(code, 1, 3); 



-- show change in passengers in each U.S. airport by year
SELECT airport, location, country, code, passengers, year 
FROM airports
WHERE country = 'United States' 
ORDER BY 1,2,3,4,6;





-- show the cities where US airports are located in
ALTER TABLE  airports
ADD city varchar(50); 

UPDATE airports
SET city = substring_index(location, ',', 1);

SELECT airport, location, country, code, passengers, year, sum(passengers) OVER (PARTITION BY year)
FROM airports
WHERE country = 'United States' 
GROUP BY
 airport, location, country, code, passengers, year;
 


-- show change in total passengers in all of the crowded airports in US
SELECT year, sum(passengers) AS total_passengers
FROM airports
WHERE country = 'united states' 
GROUP BY year
ORDER BY year;

SELECT * 
FROM airports 
WHERE year = 2020; 
