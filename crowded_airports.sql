set sql_safe_updates = 0; 

create database crowded_airports;

use crowded_airports;

create table airports (
	airport_rank int, 
    airport varchar(50), 
    location varchar(50), 
    country varchar(50), 
    code varchar(20), 
    passengers int, 
    year int
);

LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/Airports.csv'
INTO TABLE airports
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;



select *, count(country) over (partition by country) as country_count 
from airports
where year = 2020
order by country_count desc; 

-- shows number of most crowded airports in each country
select country, count(country) as country_count
from airports
where year = 2020
group by country
order by country_count desc;

-- shows most crowded airports in the US
select *
from airports 
where country like 'united states%'
and year = 2020
order by passengers desc; 

-- show the states where the US airports are located in
alter table airports
add state varchar(20); 

update airports
set state = substring_index(location, ',', -1);

-- show airport codes in a modified way
alter table airports
add airport_code varchar(5);

update airports
set airport_code = substring(code, 1, 3); 



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
