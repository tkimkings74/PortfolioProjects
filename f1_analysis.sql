SET SQL_SAFE_UPDATES = 0;

use formula1db;


create table practice1 (
	pos int, 
    driver_num int, 
    driver varchar(20), 
    car varchar(30), 
    time varchar(20), 
    gap varchar(20), 
    laps int
);

create table practice2 (
	pos int, 
    driver_num int, 
    driver varchar(20), 
    car varchar(30), 
    time varchar(20), 
    gap varchar(20), 
    laps int
);

create table practice3 (
	pos int, 
    driver_num int, 
    driver varchar(20), 
    car varchar(30), 
    time varchar(20), 
    gap varchar(20), 
    laps int
);

create table qualifying (
	pos int, 
    driver_num int, 
    driver varchar(20), 
    car varchar(30), 
    q1 varchar(20), 
	q2 varchar(20), 
	q3 varchar(20), 
    laps int
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
alter table practice1 
add minute_to_second double; 

update practice1 
set minute_to_second = convert(substring_index(time, ':', 1 ), double) * 60;



alter table practice1
add second_to_second double; 

update practice1 
set second_to_second = convert(substring_index(time, ':', -1 ), double); 

alter table practice1 
add time_in_seconds double; 

update practice1 
set time_in_seconds = minute_to_second + second_to_second; 

update practice1 
set driver = substring(driver, length(driver) - 3, length(driver)); 


-- practice2 conversion
alter table practice2 
add minute_to_second double; 

update practice2 
set minute_to_second = convert(substring_index(time, ':', 1 ), double) * 60;



alter table practice2
add second_to_second double; 

update practice2 
set second_to_second = convert(substring_index(time, ':', -1 ), double); 

alter table practice2 
add time_in_seconds double; 

update practice2 
set time_in_seconds = minute_to_second + second_to_second; 

update practice2
set driver = substring(driver, length(driver) - 3, length(driver)); 


-- practice3 conversion
alter table practice3
add minute_to_second double; 

update practice3
set minute_to_second = convert(substring_index(time, ':', 1 ), double) * 60;



alter table practice3
add second_to_second double; 

update practice3
set second_to_second = convert(substring_index(time, ':', -1 ), double); 

alter table practice3
add time_in_seconds double; 

update practice3
set time_in_seconds = minute_to_second + second_to_second; 

select * from practice1 
union select * from practice2 
union select * from practice3
; 

update practice3 
set driver = substring(driver, length(driver) - 3, length(driver)); 


-- ranks drivers in order based on performance during practice
with cte as (
	select * from practice1 
	union select * from practice2 
	union select * from practice3

) select driver, avg(time_in_seconds) as pace
from cte 
group by driver
order by pace asc; 



-- converting time to seconds in qualifying session 

alter table qualifying
add q1_updated varchar(30); 

alter table qualifying
add q2_updated varchar(30); 

alter table qualifying
add q3_updated varchar(30); 


alter table qualifying
add q1_min double; 

alter table qualifying 
add q1_sec double; 

alter table qualifying
add q2_min double; 

alter table qualifying 
add q2_sec double; 

alter table qualifying
add q3_min double; 

alter table qualifying 
add q3_sec double; 

alter table qualifying 
add q1_in_seconds double;

alter table qualifying 
add q2_in_seconds double;

alter table qualifying 
add q3_in_seconds double; 


update qualifying
set q1_updated = q1; 

update qualifying
set q2_updated = 
case 
	when q2 = 'DNF' then q1
    when q2 = '' then q1 
    else q2
    end;
    
    
update qualifying
set q3_updated = 
case 
	when q3 = 'DNF' then q2_updated
    when q3 = '' then q2_updated
    else q3
    end;
    
update qualifying 
set q1_min = convert(substring_index(q1_updated, ':', 1 ), double) * 60;

update qualifying 
set q1_sec = convert(substring_index(q1_updated, ':', -1 ), double);

update qualifying 
set q2_min = convert(substring_index(q2_updated, ':', 1 ), double) * 60;

update qualifying 
set q2_sec = convert(substring_index(q2_updated, ':', -1 ), double);

update qualifying 
set q3_min = convert(substring_index(q3_updated, ':', 1 ), double) * 60;

update qualifying 
set q3_sec = convert(substring_index(q3_updated, ':', -1 ), double);


update qualifying
set q1_in_seconds = q1_min + q1_sec; 

update qualifying
set q2_in_seconds = q2_min + q2_sec; 

update qualifying
set q3_in_seconds = q3_min + q3_sec; 

alter table qualifying
add time_in_seconds double; 

update qualifying
set time_in_seconds = (q1_in_seconds + q2_in_seconds + q3_in_seconds)/3 ;

-- drop unnecessary columns to create a combined table 

alter table practice1 
	drop column time,
	drop column gap,
	drop column minute_to_second, 
	drop column second_to_second; 

alter table practice2
	drop column time,
	drop column gap,
	drop column minute_to_second, 
	drop column second_to_second; 

alter table practice3 
	drop column time,
	drop column gap,
	drop column minute_to_second, 
	drop column second_to_second; 

select * from qualifying;

alter table qualifying
	drop column q1, 
    drop column q2, 
    drop column q3, 
    drop column q1_updated, 
    drop column q2_updated, 
    drop column q3_updated, 
    drop column q1_min, 
    drop column q1_sec, 
    drop column q2_min, 
    drop column q2_sec, 
    drop column q3_min, 
    drop column q3_sec, 
    drop column q1_in_seconds, 
    drop column q2_in_seconds, 
    drop column q3_in_seconds; 
	
-- ranks drivers based on performance from all practice and qualifying sessions
with pacecte as (
	select * from practice1 union
    select * from practice2 union
    select * from practice3 union 
    select * from qualifying
) select driver, car, avg(time_in_seconds) as pace, avg(laps) as laps, avg(pos) as avg_pos
from pacecte
group by driver, car
order by avg_pos ; 

create table pace_prediction (
	driver varchar(30), 
    car varchar(30), 
    pace double, 
    laps double, 
    avg_pos double
);

with pacecte as (
	select * from practice1 union
    select * from practice2 union
    select * from practice3 union 
    select * from qualifying
) 
update pace_prediction 
set driver = 
pacecte.driver;


update qualifying 
set driver = substring(driver, length(driver) - 3, length(driver)); 

create table pace_prediction as 
with pacecte as (
	select * from practice1 union
    select * from practice2 union
    select * from practice3 union 
    select * from qualifying
) select driver, car, avg(time_in_seconds) as pace, avg(laps) as laps, avg(pos) as avg_pos
from pacecte
group by driver, car
order by avg_pos;

select * from pace_prediction;









