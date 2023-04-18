SET sql_safe_updates = 0; 

CREATE database exploring_wealth; 

USE exploring_wealth;

CREATE TABLE richest_people(
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

SELECT * FROM richest_people; 


-- networth is saved as a string containing $ sign and the letter B. remove these and save as int
UPDATE richest_people 
SET net_worth = substring(net_worth, 1, position('B' IN net_worth) -1);

ALTER TABLE richest_people 
rename column net_worth to networth_b;


-- delete blank rows from data table
SELECT * FROM richest_people WHERE networth_b = ''; 

DELETE FROM richest_people
WHERE networth_b = ''; 

ALTER TABLE richest_people 
modify networth_b int; 



-- some records are missing value for age. set these to null 
UPDATE richest_people 
SET age = null 
WHERE age = 0; 


ALTER TABLE richest_people
add second_source varchar(50);


UPDATE richest_people
SET second_source = 
CASE 
	WHEN position(',' in source) != 0 THEN substring_index(source, ',', -1)
	ELSE NULL 
	END; 
    
UPDATE richest_people 
SET source = 
CASE 
	WHEN position(',' in source) != 0 THEN substring_index(source, ',', 1)
	ELSE source
	END;
    


-- create separate table for people with multiple sources of income
CREATE TABLE people_with_second_source AS 
with cte AS (
SELECT * FROM richest_people
WHERE second_source IS NOT NULL
) SELECT * FROM cte; 


-- compare average networth of those with multiple sources of income compared to those with single source
SELECT avg(networth_b) FROM people_with_second_Source;

SELECT avg(networth_b) FROM richest_people; 




-- show avg wealth of billionaires from each country 

SELECT avg(networth_b), country 
FROM richest_people
GROUP BY country 
ORDER BY avg(networth_b) DESC; 

-- show countries with the most billionaries around the world
SELECT COUNT(*) AS COUNT, country 
FROM richest_people 
GROUP BY country
ORDER BY COUNT DESC; 

-- show industries with the most billionaires
SELECT COUNT(*) AS COUNT, industry 
FROM richest_people
GROUP BY industry
ORDER BY COUNT DESC; 

-- show top 10 industries with the most billionaires
SELECT COUNT(*) AS COUNT, industry 
FROM richest_people
GROUP BY industry
ORDER BY COUNT DESC
LIMIT 10; 

-- show top 10 industries with the least billionaires
SELECT COUNT(*) AS COUNT, industry 
FROM richest_people
GROUP BY industry
ORDER BY COUNT
LIMIT 10; 


-- show industries with the highest average networth
SELECT avg(networth_b) AS networth, industry
FROM richest_people 
GROUP BY industry
ORDER BY networth DESC
LIMIT 15;







    

