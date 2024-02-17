--DATA CLEANING IN SQL - NASHVILLE HOUSING

---------------------------------------------------------------------------------------------------------------
--Querying the dataset
Select  *
from NashvilleHousing

----------------------------------------------------------------------------------------------------------------

--STANDARDIZING DATE FORMAT
Select SaleDate, CONVERT(date, saledate)
from NashvilleHousing

--Adding a new column
ALTER table NashvilleHousing
Add SaleDateConverted date

-- SET the new column with standardize date
UPDATE  NashvilleHousing
SET SaleDateConverted = CONVERT(date, saledate)

--Date Standardized - YYYY-MM-DD format
Select SaleDateConverted
From NashvilleHousing

----------------------------------------------------------------------------------------------------------------
--POPULATING PROPERTY ADDRESS DATA

/*
First, I performed a SELF JOIN 
Then, matched the ParcelIds and populated the address wherever there were null values using ISNULL function, making sure 
the UniqueIDs are different for 2 parcelIDs 
*/
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress IS NULL

--Checking whether there are null values present in the PropertyAddress
--This query will return 0 rows as there are no null values present in the PropertyAddress column
Select * from 
NashvilleHousing
where PropertyAddress is NULL

----------------------------------------------------------------------------------------------------------------
--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM NashvilleHousing

--Creating new column PropertySplitAddress to update Address in it 
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--Creating new column PropertySplitCity to update City name in it 
ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Checking if both the new columns are updated with Address and City
Select PropertyAddress, PropertySplitAddress, PropertySplitCity
from NashvilleHousing

-----------------------------------------------------------------------------------------------------------------
--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN (ADDRESS, CITY, STATE) USING PARSENAME FUNCTION

Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) AS State
from NashvilleHousing

--Now, we need to create 3 columns and update them with the PARSENANAME function

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) 

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

--Checking whether new columns are updated with Address,City and State
Select * --OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from NashvilleHousing 

-------------------------------------------------------------------------------------------------------------------
--Changing Y and N to Yes and No respectively in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

--Using CASE statement to chnage Y and N to Yes and No
select SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END  
from NashvilleHousing

--Adding a new column and updating it with above CASE
ALTER TABLE NashvilleHousing
ADD Updated_SoldAsVacant nvarchar(255)

UPDATE NashvilleHousing
SET Updated_SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END 

--Checking whether we can see Yes and No, post updating the new column Updated_SoldAsVacant
select distinct(Updated_SoldAsVacant), count(Updated_SoldAsVacant)
from NashvilleHousing
group by Updated_SoldAsVacant
order by 2

----------------------------------------------------------------------------------------------------------------
--REMOVING DUPLICATES
--We are using ROW_NUMBER Window Function and partioning on the basis of columns which should be unique.  
--So, rows which get value greater than 1, can be deleted.
--If any of the values in a column are same, they will get grouped together and we can just keep the row_number 1 of each group
--And other rows we can delete in that group.

--Creating a CTE 
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY UniqueID) row_num
FROM NashvilleHousing
)
--After executing the below query, we can see that there 104 rows have row numbers greater than 1																						
--select * 
--from RowNumCTE
--where row_num > 1

--Let's delete the rows with row number greater than 1, since those are duplicate rows
DELETE 
from RowNumCTE
where row_num > 1

---------------------------------------------------------------------------------------------------------------------
--DELETING UNUSED ROWS

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict
--DROP COLUMN SaleDateUpdated

-----------------------------------------------------------------------------------------------------------------------
--Execute this query to see the cleaned dataset 
Select * 
from NashvilleHousing
ORDER BY ParcelID









