*/

Cleaning data in SQL Queries

*/

--Importing and checking data that will be used



SELECT *
FROM Portfolio..NashvilleHousing

--Standardizing Date



SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio..NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE Portfolio..NashvilleHousing
ADD SaleDateConverted Date;


UPDATE Portfolio..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populating Property Address Column



SELECT PropertyAddress
FROM Portfolio..NashvilleHousing
WHERE PropertyAddress is null

--*ParcelID and PropertyAddress are connected, will update Prop.Ad column by joinging to ParcelID

SELECT *
FROM Portfolio..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null



--Separating Address Column into Address, City, and State Columns



SELECT PropertyAddress
FROM Portfolio..NashvilleHousing
--WHERE PropertyAddress is null


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM Portfolio..NashvilleHousing


ALTER TABLE Portfolio..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);


UPDATE Portfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 


ALTER TABLE Portfolio..NashvilleHousing
ADD PropertyCity nvarchar(255);


UPDATE Portfolio..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


SELECT OwnerAddress
From Portfolio..NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Portfolio..NashvilleHousing


ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);


UPDATE Portfolio..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);


UPDATE Portfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE Portfolio..NashvilleHousing
ADD OwnerSplitState nvarchar(255);


UPDATE Portfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



--Changing 'Y' and 'N' to Yes and No in Sold as Vacant Column



SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
Group by SoldasVacant
Order by 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N ' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Portfolio..NashvilleHousing


UPDATE Portfolio..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N ' THEN 'No'
	   ELSE SoldAsVacant
	   END


--Removing Duplicates


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

From Portfolio..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1



--Removing Unused Columns



SELECT *
FROM Portfolio..NashvilleHousing

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN SaleDate

SELECT *
FROM Portfolio..NashvilleHousing



