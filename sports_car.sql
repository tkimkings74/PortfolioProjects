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
update sports_car 
set horsepower = substring_index(horsepower, '+', 1)
where substring(horsepower, length(horsepower),length(horsepower)) = '+'; 

-- some horsepower values have a comma in them. we fix this 

select * from sports_car
where horsepower like '%,%'; 



-- remove comma from horsepower value that contains comma 
update sports_car 
set horsepower = substring_index(horsepower, ',', 1) + substring_index(horsepower, ',', -1)
where horsepower like '%,%'; 


update sports_car 
set horsepower = convert(horsepower, double);

alter table sports_car 
add horse_power double; 

update sports_car 
set horse_power = convert(horsepower, double); 



-- we find an outlier Tesla model with horsepower of 10000, which is clearly an input error. we fix the horsepower 

update sports_car 
set horsepower = 1000 
where car_make = 'tesla' 
and car_model = 'roadster'
and horsepower > 5000;

-- some data records have incorrect horsepower value where two identical models with the same year and make have different values. 
-- we correct this by using the larger value of the two using selfjoin. 


update sports_car 
as a join sports_car as b 
on a.car_make = b.car_make
and a.car_model = b.car_model 
and a.year = b.year 
and a.horsepower != b.horsepower
set a.horsepower = greatest(a.horsepower, b.horsepower);



update sports_car 
as a join sports_car as b 
on a.car_make = b.car_make
and a.car_model = b.car_model 
and a.year = b.year 
and a.horsepower != b.horsepower
set b.horsepower = greatest(a.horsepower, b.horsepower);


-- price field contains comma, which we want removed. 

alter table sports_car
add price_ double; 


update sports_car 
set price_ =
case 
	when length(price) <= 7 then convert(concat(substring_index(price, ',', 1), substring_index(price, ',', -1)), double)
    when length(price) > 7 then convert(concat(substring_index(price, ',', 1), substring_index(substring_index(price, ',', 2), ',', -1), 
					substring_index(price, ',', -1)), double)
	else price
    end;

alter table sports_car 
drop column price; 

alter table sports_car
rename column price_ to price; 



-- delete tesla vehicles with horsepower input error
delete from sports_car 
where car_make = 'tesla' 
and horsepower <= 500; 




-- fix engine_size values: electric vehicles and hybrids have values other than numbers
SELECT * FROM sports_Car WHERE concat('',convert(engine_size, double) * 1) != engine_size;

update sports_car
set engine_size = 'electric' 
where engine_size like '%electric%';

update sports_car
set engine_size = 'hybrid' 
where engine_size like '%hybrid%';

update sports_car
set engine_size = 'electric' 
where engine_size like '%n/a%';


update sports_car
set engine_size = 'electric' 
where engine_size like '%-%';

update sports_car
set engine_size = 'electric' 
where engine_size like '0';


-- fix torque values 

select distinct torque from sports_car order by torque; 

select * from sports_car where torque like '%+%';



update sports_car 
set torque = 7376 
where car_make = 'tesla' 
and car_model = 'roadster';  

update sports_car 
set torque = 1020 
where car_model = 'model s plaid' 
and torque = 'n/a';

update sports_car 
set torque = 520 
where car_make = 'maserati'
and car_model = 'granturismo';

alter table sports_car 
drop column electric; 

select * from sports_car 
where torque = 'n/a' ;


alter table sports_car 
add torque_ double ;

update sports_car 
set torque = 
case when torque like '%,%' then concat(substring_index(torque, ',', 1), substring_index(torque, ',', -1))
	else torque
    end; 


alter table sports_car 
modify torque double; 

select * from sports_car 
where torque like '%,%'; 

alter table sports_car 
modify zero_to_60 double; 





create table car_data as
with cte as (
	select * from sports_car 
) select * from cte; 


select * from car_data; 


select car_make, car_model, min(zero_to_60) as pace
from sports_car 
group by car_make, car_model
order by pace ;


select * from car_data as a
where zero_to_60 = (select  min(zero_to_60)from car_data as b where a.car_make = b.car_make)
order by zero_to_60, car_make;

select car_make,  min(zero_to_60) as acceleration from car_data as a
where zero_to_60 = (select  min(zero_to_60)from car_data as b where a.car_make = b.car_make)
group by car_make 
order by acceleration, car_make;

create table brand_by_acceleration as 
with cte as (select car_make,  min(zero_to_60) as acceleration from car_data as a
where zero_to_60 = (select  min(zero_to_60)from car_data as b where a.car_make = b.car_make)
group by car_make 
order by acceleration, car_make) select * from cte; 



select car_make, car_model, year, avg(horsepower), avg(zero_to_60) as pace, 
avg(torque) from car_data 
group by car_make, car_model, year
order by pace 
limit 15;

select car_make, car_model, avg(horsepower) as horsepower, avg(zero_to_60) as acceleration, 
avg(torque) as torque from car_data 
group by car_make, car_model
order by acceleration 
limit 15;




