set sql_safe_updates = 0; 

create database exploring_wealth; 

use exploring_wealth;
create table richest_people(
	weatlh_rank int, 
    name varchar(50), 
    net_worth varchar(20), 
    age int, 
    country varchar(30), 
    source varchar(50), 
    industry varchar(50)
    
);



LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/forbes_richman.csv'
INTO TABLE richest_people
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from richest_people; 


-- networth is saved as a string containing $ sign and the letter B. remove these and save as int
update richest_people 
set net_worth = substring(net_worth, 1, position('B' in net_worth) -1);

alter table richest_people 
rename column net_worth to networth_b;


-- delete blank rows from data table
select * from richest_people where networth_b = ''; 

delete from richest_people
where networth_b = ''; 

alter table richest_people 
modify networth_b int; 



-- some records are missing value for age. set these to null 
update richest_people 
set age = null 
where age = 0; 


alter table richest_people
add second_source varchar(50);


update richest_people
set second_source = 
case 
	when position(',' in source) != 0 then substring_index(source, ',', -1)
    else null 
    end; 
    
update richest_people 
set source = 
case 
	when position(',' in source) != 0 then substring_index(source, ',', 1)
    else source
    end;
    


-- create separate table for people with multiple sources of income
create table people_with_second_source as 
with cte as (
select * from richest_people
where second_source is not null
) select * from cte; 


-- compare average networth of those with multiple sources of income compared to those with single source
select avg(networth_b) from people_with_second_Source;

select avg(networth_b) from richest_people; 




-- show avg wealth of billionaires from each country 

select avg(networth_b), country 
from richest_people
group by country 
order by avg(networth_b) desc; 

-- show countries with the most billionaries around the world
select count(*) as count, country 
from richest_people 
group by country
order by count desc; 

-- show industries with the most billionaires
select count(*) as count, industry 
from richest_people
group by industry
order by count desc; 

-- show top 10 industries with the most billionaires
select count(*) as count, industry 
from richest_people
group by industry
order by count desc
limit 10; 

-- show top 10 industries with the least billionaires
select count(*) as count, industry 
from richest_people
group by industry
order by count 
limit 10; 


-- show industries with the highest average networth
select avg(networth_b) as networth, industry
from richest_people 
group by industry
order by networth desc
limit 15;







    

