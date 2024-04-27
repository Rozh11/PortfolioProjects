
--cleaning Data in SQL Queries 

-- Activities
-- 1. Standardize Date Format
-- 2. Populate Property Address Data
-- 3. Breaking out Address Into Individual Columns (Address, City, State)
-- 4. Change Y and N to Yes and No in "Sold as Vacant" field
-- 5. Remove Duplicates
-- 6. Delete Unused Columns

--------------------------------------------------------------

USE PortfolioProject;

SELECT * 
FROM PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------

--  Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM PortfolioProject..NashvilleHousing

Select * 
From NashvilleHousing 

UPDATE NashvilleHousing
SET SaleDate = Convert(Date,SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)




---------------------------------------------------------------------------------

--  Populate Property Address Data

SELECT * 
FROM PortfolioProject..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

-- we replace null of propertyAddress that have same ParcelID with other propertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ] 
where a.PropertyAddress is null

UPDATE a
SET propertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ] 

---------------------------------------------------------------------------------

--  Breaking out Address Into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM PortfolioProject..NashvilleHousing
-- where PropertyAddress is null
-- order by ParcelID


SELECT 
SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))  as Address

FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT * 
FROM NashvilleHousing



SELECT OwnerAddress  -- it has address , city , state
FROM NashvilleHousing



SELECT OwnerAddress  -- it has address , city , state
FROM NashvilleHousing

-- EASIER METHOD TO DIVIDE A COLUMN
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

FROM NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitstate Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM NashvilleHousing






---------------------------------------------------------------------------------

--  Change Y and N to Yes and No in "Sold as Vacant" field
-- we use CASE STATEMENT for this case



SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing



---------------------------------------------------------------------------------

--  Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER ( 
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY uniqueid
			 ) row_num
FROM NashvilleHousing
-- order by ParcelID
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1 -- this indicate duplication of values that has more than 1 value
order by PropertyAddress



------------------------------------------------------

-- DELETE Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate



