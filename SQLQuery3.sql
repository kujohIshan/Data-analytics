-- data cleaning
select* from portfolio.dbo.housing
--steps
-- standerdize date format
-- populate property address data
-- breaking out address into individual columns
-- change Y and N to yes and no
-- remove duplicates 
-- delete unused columns

-- standerdize date format


Alter Table portfolio.dbo.housing
Add SaleDateconverted Date;

Update portfolio.dbo.housing
set SaleDateconverted = CONVERT(Date,Saledate) 


-- populate property address data


Select *
from portfolio.dbo.housing
--Where PropertyAddress is NULL
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio.dbo.housing as a
JOIN portfolio.dbo.housing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

update a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portfolio.dbo.housing as a
JOIN portfolio.dbo.housing as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


-- breaking out address into individual columns(Address, city, state)

SELECT PropertyAddress
from portfolio.dbo.housing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
from portfolio.dbo.housing

Alter Table portfolio.dbo.housing
Add Property_Addresss Nvarchar(255);

Update portfolio.dbo.housing
set Property_Addresss = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table portfolio.dbo.housing
Add Property_city Nvarchar(255);

Update portfolio.dbo.housing
set Property_city = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

-- owner address

select 
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from portfolio.dbo.housing

Alter Table portfolio.dbo.housing
Add Owner_Addresss Nvarchar(255);

Update portfolio.dbo.housing
set Owner_Addresss  = PARSENAME(replace(OwnerAddress,',','.'),3)


Alter Table portfolio.dbo.housing
Add Owner_city Nvarchar(255);

Update portfolio.dbo.housing
set Owner_city = PARSENAME(replace(OwnerAddress,',','.'),2)


Alter Table portfolio.dbo.housing
Add Owner_state Nvarchar(255);

Update portfolio.dbo.housing
set Owner_state = PARSENAME(replace(OwnerAddress,',','.'),1)


select *
from portfolio.dbo.housing

-- change Y and N to yes and no in 'sold vacant'


select distinct(SoldAsVacant)
from portfolio.dbo.housing

Select distinct(SoldAsVacant) ,count(SoldAsVacant)
from portfolio.dbo.housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant= 'Y' then 'Yes'
	 when SoldAsVacant= 'N' then 'No'
	 else SoldAsVacant
	 end
from portfolio.dbo.housing

update portfolio.dbo.housing
set SoldAsVacant= case when SoldAsVacant= 'Y' then 'Yes'
	 when SoldAsVacant= 'N' then 'No'
	 else SoldAsVacant
	 end


-- remove duplicates 

select *,
ROW_NUMBER() OVER(
partition by ParcelId , PropertyAddress, Saleprice, Saledate,LegalReference 
order by UniqueID) as row_num
from portfolio.dbo.housing

-- put it into a cte
WITH CTE_rownum AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelId, PropertyAddress, Saleprice, Saledate, LegalReference 
               ORDER BY UniqueID
           ) AS row_num
    FROM portfolio.dbo.housing
)
select*
FROM CTE_rownum
where row_num >1


-- delete unused columns

select*
from portfolio.dbo.housing
-- delete owner address and property address and tax district

ALter table portfolio.dbo.housing
DROP column OwnerAddress, PropertyAddress, TaxDistrict

ALter table portfolio.dbo.housing
DROP column SaleDate





