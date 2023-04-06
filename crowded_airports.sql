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
select airport, location, country, code, passengers, year 
from airports
where country = 'United States' 
order by 1,2,3,4,6;





-- show the cities where US airports are located in
alter table airports
add city varchar(50); 

update airports
set city = substring_index(location, ',', 1);

select airport, location, country, code, passengers, year, sum(passengers) over (partition by year)
from airports
where country = 'United States' 
group by 
 airport, location, country, code, passengers, year;
 


-- show change in total passengers in all of the crowded airports in US
select year, sum(passengers) as total_passengers
from airports
where country = 'united states' 
group by year
order by year;

select * 
from airports 
where year = 2020; 