--   ####  DATA CLEANING  ####

Select * from nashville_housing;

-- Standardize Date Format

Select saledate
from nashville_housing;

-- Populate Property Address data
Select *
from nashville_housing
where propertyaddress is null;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
coalesce(a.PropertyAddress, b.PropertyAddress)
from nashville_housing a
left join nashville_housing b
   on a.parcelid=b.parcelid
   and a.uniqueid<>b.uniqueid
where a.propertyaddress is null;


Update nashville_housing
SET PropertyAddress = coalesce(a.PropertyAddress, b.PropertyAddress)
From nashville_housing a
JOIN nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID  <> b.UniqueID 
Where a.PropertyAddress is null;

-------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select propertyaddress
from nashville_housing;

select 
substring(propertyaddress from 1 for position(',' in propertyaddress)-1) as Address1,
substring(propertyaddress, position(',' in propertyaddress)+1, 
                                           length(propertyaddress)) as City
from nashville_housing;

alter table nashville_housing
add "PropertySplitAddress" varchar(255);

alter table nashville_housing
rename "PropertySplitAddress" to propertysplitaddress;

update  nashville_housing
set propertysplitaddress=substring(propertyaddress from 1 
                                   for position(',' in propertyaddress)-1);

alter table nashville_housing
add propertysplitcity varchar(255);

update nashville_housing
set propertysplitcity=substring(propertyaddress, position(',' in propertyaddress)+1, 
                                           length(propertyaddress));

Select *
From nashville_housing;


select owneraddress
from nashville_housing;

select 
(string_to_array(owneraddress, ','))[1],
(string_to_array(owneraddress, ','))[2],
(string_to_array(owneraddress, ','))[3]
from nashville_housing;


ALTER TABLE nashville_housing
Add ownersplitaddress varchar(255);

Update nashville_housing
SET ownersplitaddress = (string_to_array(owneraddress, ','))[1];

ALTER TABLE nashville_housing
Add ownersplitcity varchar(255);

Update nashville_housing
SET ownersplitcity = (string_to_array(owneraddress, ','))[2];

ALTER TABLE nashville_housing
Add ownersplitstate varchar(255);

Update nashville_housing
SET ownersplitstate = (string_to_array(owneraddress, ','))[3];

select *
from nashville_housing;

------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct soldasvacant, count(soldasvacant)
from nashville_housing
group by soldasvacant
order by 2;

select soldasvacant, 
case
    when soldasvacant='Y' then 'Yes'
	when soldasvacant='N' then 'No'
	else
	soldasvacant
	end
from nashville_housing;

update nashville_housing
set soldasvacant= case
    when soldasvacant='Y' then 'Yes'
	when soldasvacant='N' then 'No'
	else
	soldasvacant
	end;


-------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH rownumcte AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
           ORDER BY UniqueID
         ) AS row_num
  FROM nashville_housing
)

DELETE FROM nashville_housing
USING rownumcte
WHERE nashville_housing.UniqueID = rownumcte.UniqueID
  AND rownumcte.row_num > 1;
  



Select *
From nashville_housing;


-----------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From nashville_housing;


ALTER TABLE nashville_housing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress,
DROP COLUMN saledate;












