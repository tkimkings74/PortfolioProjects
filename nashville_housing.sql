USE housing; 

CREATE TABLE housing_data (
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


SELECT * FROM housing_data;


-- replace empty records with null value 
UPDATE housing_data 
SET OwnerName = null 
WHERE OwnerName = '';



UPDATE housing_data 
SET TaxDistrict = null 
WHERE TaxDistrict = '';




-- finds records where null property addresses exist by using self join
SELECT  a.uniqueID, a.parcelID, a.PropertyAddress, b.uniqueID, b.parcelID, b.PropertyAddress
FROM housing_data AS a
JOIN housing_data S b 
ON a.parcelID = b.parcelID 
AND a.uniqueID != b.uniqueID
WHERE a.PropertyAddress IS null;

-- updates null values in property address with address in records with the same parcelID
UPDATE housing_data AS a
JOIN housing_data AS b 
ON a.parcelID = b.parcelID 
AND a.uniqueID != b.uniqueID
SET a.propertyaddress = b.propertyaddress
WHERE a.PropertyAddress IS null;

-- breaking property address into 3 columns: address, city, state
-- position function finds index value of input, substring uses those values to cut string into substrings
SELECT substring(propertyaddress, 1, position(',' IN propertyaddress) - 1) 
AS address,
 substring(propertyaddress, position(',' IN propertyaddress) + 1, length(propertyaddress))
AS city
FROM housing_data;



ALTER TABLE housing_data 
ADD address_cut varchar(50); 

ALTER TABLE housing_data
ADD address_city varchar(50); 

UPDATE housing_data 
SET address_cut = substring(propertyaddress, 1, position(',' IN propertyaddress) - 1) ;

UPDATE housing_data 
SET address_city = substring(propertyaddress, position(',' IN propertyaddress) +1, length(propertyaddress));


-- split up owner address into address, city, and state

-- split up state in address
SELECT substring_index(owneraddress, ',', -1 ) FROM housing_data;

-- split up owner's address
SELECT substring_index(owneraddress, ',', 1 ) FROM housing_data;

-- split up owner's city 
SELECT substring_index(substring_index(owneraddress, ',', 2 ) , ',', -1) FROM housing_data; 

ALTER TABLE housing_data 
ADD owner_address varchar(50); 

ALTER TABLE housing_data 
ADD owner_city varchar(50); 

ALTER TABLE housing_data
ADD owner_state varchar(5); 

UPDATE housing_data 
SET owner_address = substring_index(owneraddress, ',', 1 ); 

UPDATE housing_data
SET owner_city = substring_index(substring_index(owneraddress, ',', 2 ) , ',', -1); 

UPDATE housing_data 
SET owner_state = substring_index(owneraddress, ',', -1); 

-- update y and n values to yes and no in soldasvacant field 

UPDATE housing_data 
SET soldasvacant = 'yes' 
WHERE soldasvacant = 'y'; 

UPDATE housing_data 
SET soldasvacant = 'no' 
WHERE soldasvacant = 'n'; 

-- alternatively

UPDATE housing_data
SET soldasvacant = 
case 
	when soldasvacant = 'y' then 'yes'
	when soldasvacant = 'n' then 'no'
	else soldasvacant 
	end;




-- remove duplicates
with rowNumCTE 
AS ( 
	SELECT *, row_number() over (
	partition BY 
		parcelID, 
        -- propertyaddress, 
        saledate, 
        legalreference 
	ORDER BY 
		uniqueid
	) row_num
FROM housing_data 

)
DELETE FROM h
using housing_data AS h 
JOIN rownumcte S r 
ON h.parcelid = r.parcelid
WHERE r.row_num > 1; 





-- removed columns that aren't needed

ALTER TABLE housing_data 
DROP column owneraddress;

ALTER TABLE housing_data 
DROP column TaxDistrict; 
 
ALTER TABLE housing_data 
DROP column PropertyAddress; 
 

SELECT * FROM housing_data; 


