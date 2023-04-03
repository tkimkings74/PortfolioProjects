use housing; 

create table housing_data (
	UniqueID int,
    ParcelID varchar(30), 
    LandUSe varchar(30), 
    PropertyAddress varchar(50), 
    SaleDate date, 
    SalePrice int, 
    LegalReference varchar(30), 
    SoldAsVacant varchar(10), 
    OwnerName varchar(50), 
    OwnerAddress varchar(50), 
    Acreage double,
    TaxDistrict varchar(50), 
    LandValue int, 
    BuildingValue int, 
    TotalValue int, 
    YearBuilt int, 
    Bedrooms int, 
    FullBath int, 
    HalfBath int
);
SET SQL_SAFE_UPDATES = 0;

LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/Nashville\ Housing\ Data\ for\ Data\ Cleaning.csv '
INTO TABLE housing_data  FIELDS TERMINATED BY ','
ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


select * from housing_data;


-- replace empty records with null value 
update housing_data 
set OwnerName = null 
where OwnerName = '';



update housing_data 
set TaxDistrict = null 
where TaxDistrict = '';




-- finds records where null property addresses exist by using self join
select  a.uniqueID, a.parcelID, a.PropertyAddress, b.uniqueID, b.parcelID, b.PropertyAddress
from housing_data as a
join housing_data as b 
on a.parcelID = b.parcelID 
and a.uniqueID != b.uniqueID
where a.PropertyAddress is null;

-- updates null values in property address with address in records with the same parcelID
update housing_data as a
join housing_data as b 
on a.parcelID = b.parcelID 
and a.uniqueID != b.uniqueID
set a.propertyaddress = b.propertyaddress
where a.PropertyAddress is null;

-- breaking property address into 3 columns: address, city, state
-- position function finds index value of input, substring uses those values to cut string into substrings
select substring(propertyaddress, 1, position(',' in propertyaddress) - 1) 
as address,
 substring(propertyaddress, position(',' in propertyaddress) + 1, length(propertyaddress))
as city
from housing_data;



alter table housing_data 
add address_cut varchar(50); 

alter table housing_data
add address_city varchar(50); 

update housing_data 
set address_cut = substring(propertyaddress, 1, position(',' in propertyaddress) - 1) ;

update housing_data 
set address_city = substring(propertyaddress, position(',' in propertyaddress) +1, length(propertyaddress));


-- split up owner address into address, city, and state

-- split up state in address
select substring_index(owneraddress, ',', -1 ) from housing_data;

-- split up owner's address
select substring_index(owneraddress, ',', 1 ) from housing_data;

-- split up owner's city 
select substring_index(substring_index(owneraddress, ',', 2 ) , ',', -1) from housing_data; 

alter table housing_data 
add owner_address varchar(50); 

alter table housing_data 
add owner_city varchar(50); 

alter table housing_data
add owner_state varchar(5); 

update housing_data 
set owner_address = substring_index(owneraddress, ',', 1 ); 

update housing_data
set owner_city = substring_index(substring_index(owneraddress, ',', 2 ) , ',', -1); 

update housing_data 
set owner_state = substring_index(owneraddress, ',', -1); 

-- update y and n values to yes and no in soldasvacant field 

update housing_data 
set soldasvacant = 'yes' 
where soldasvacant = 'y'; 

update housing_data 
set soldasvacant = 'no' 
where soldasvacant = 'n'; 

-- alternatively

update housing_data
set soldasvacant = 
case 
	when soldasvacant = 'y' then 'yes'
	when soldasvacant = 'n' then 'no'
	else soldasvacant 
	end;




-- remove duplicates
with rowNumCTE 
as ( 
	select *, row_number() over (
	partition by 
		parcelID, 
        -- propertyaddress, 
        saledate, 
        legalreference 
	order by 
		uniqueid
	) row_num
from housing_data 

)
delete from h
using housing_data as h 
join rownumcte as r 
on h.parcelid = r.parcelid
where r.row_num > 1; 





-- removed columns that aren't needed

alter table housing_data 
drop column owneraddress;

 alter table housing_data 
 drop column TaxDistrict; 
 
 alter table housing_data 
 drop column PropertyAddress; 
 

select * from housing_data; 


