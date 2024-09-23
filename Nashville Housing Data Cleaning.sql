/* Cleaning Data */


-- SaleDate
ALTER TABLE Nashville_Housing..NashvilleHousing
Add SaleDateConverted Date;

Update Nashville_Housing..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDate, SaleDateConverted
From Nashville_Housing..NashvilleHousing


-- Populate Property Address Data
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville_Housing..NashvilleHousing a
join Nashville_Housing..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Select *
from Nashville_Housing..NashvilleHousing
where PropertyAddress is null


--Breaking out Address into Columns (Address, City, State)

--Using Substring
Select PropertyAddress
From Nashville_Housing..NashvilleHousing

Select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From Nashville_Housing..NashvilleHousing

ALTER TABLE Nashville_Housing..NashvilleHousing
Add PropertySplitAddress Nvarchar(255), PropertySplitCity Nvarchar(255);

Update Nashville_Housing..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
, PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Using Parsename
Select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From Nashville_Housing..NashvilleHousing

ALTER TABLE Nashville_Housing..NashvilleHousing
Add OwnerState Nvarchar(255), OwnerCity Nvarchar(255), OwnerSplitAddress Nvarchar(255);

Update Nashville_Housing..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
from Nashville_Housing..NashvilleHousing



--Change Y, N to Yes and No in SoldAsVacant Column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from Nashville_Housing..NashvilleHousing
group by SoldAsVacant


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
from Nashville_Housing..NashvilleHousing

UPDATE Nashville_Housing..NashvilleHousing
SET SoldAsVacant = 
	   CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END


--Remove Duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by 
					UniqueID) row_num
from Nashville_Housing..NashvilleHousing
)

DELETE from RowNumCTE
where row_num > 1

	