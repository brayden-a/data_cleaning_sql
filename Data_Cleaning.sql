/*

Cleaning Data in SQL Queries

*/

select * from dbo.Housing;

-----------------------------------------------------------------------------------------------------------

-- Standardize date format 

ALTER TABLE dbo.Housing
Add SaleDateConverted Date;

UPDATE dbo.Housing
SET SaleDateConverted = CONVERT(Date,SaleDate);


-----------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select * 
from dbo.Housing
where PropertyAddress is NULL 
order by ParcelID;


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.Housing a
Join dbo.Housing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL;

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.Housing a
Join dbo.Housing b 
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL;

----------------------------------------------------------------------------------------------------------

-- Breaking out Property address into individual columns

select PropertyAddress
from dbo.Housing
where PropertyAddress is null
order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from dbo.Housing


Alter Table dbo.Housing
add PropertySplitAddress Nvarchar(255);

update dbo.Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

alter table dbo.Housing
add PropertySplitCity Nvarchar(255);

update dbo.Housing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

--------------------------------------------------------------------------------------------------------------
-- Breaking out OwnerAddress into individual columns

select OwnerAddress 
from dbo.Housing


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,	3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,	2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,	1)
from dbo.Housing

alter table dbo.Housing
add OwnerSplitAddress Nvarchar(255);

update dbo.Housing	
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,	3);

alter table dbo.Housing
add OwnerSplitCity Nvarchar(255);

update dbo.Housing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,	2);

alter table dbo.Housing
add OwnerSplitState Nvarchar(255);

update dbo.Housing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,	1);

---------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in SoldAsVacant 

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from dbo.Housing
group by SoldAsVacant
order by 2 

select SoldAsVacant
,CASE When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
END
from dbo.Housing

Update dbo.Housing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
else SoldAsVacant
END;

-------------------------------------------------------------------------------------------------------

--Remove duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.Housing
--order by ParcelID
)
--select * 
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

----------------------------------------------------------------------------------------------------------------
-- Delete unused columns

select * 
from dbo.Housing

alter table dbo.Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

------------------------------------------------------------------------------------------------------------------

select * 
from dbo.Housing;

