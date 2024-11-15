-- Project: Cleaning Data Set

CREATE TABLE nashville(
  UniqueID INT,
  ParcelID VARCHAR(50),
  LandUse VARCHAR(50),
  PropertyAddress VARCHAR(100),
  SaleDate TEXT,
  SalePrice VARCHAR(100),
  LegalReference varchar(100),
  SoldAsVacant varchar(100),
  OwnerName varchar(100),
  OwnerAddress varchar(100),
  Acreage VARCHAR(100),
  TaxDistrict varchar(100),
  LandValue VARCHAR(100),
  BuildingValue VARCHAR(100),
  TotalValue VARCHAR(100),
  YearBuilt VARCHAR(100),
  Bedrooms VARCHAR(100),
  FullBath VARCHAR(100),
  HalfBath VARCHAR(100)
);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Nashville/Nashville_2.csv"
INTO TABLE nashville
FIELDS TERMINATED BY '$'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT *
FROM Nashville;

-- Standarize Date Format

SELECT SaleDate
FROM nashville;

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y') 
FROM nashville;

UPDATE nashville
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

SELECT SaleDate
FROM nashville;

ALTER TABLE nashville
MODIFY COLUMN SaleDate date;

-- Clean PropertyAddress and OwnerAddress

SELECT *
FROM nashville;

SELECT OwnerAddress
FROM Nashville;

SELECT OwnerAddress
FROM nashville
WHERE OwnerAddress = 'Null';

SELECT ParcelID, PropertyAddress, OwnerAddress
FROM Nashville
WHERE PropertyAddress = 'Null'
ORDER BY ParcelID;

-- Self join to propagate the information from b into a
-- I look for the ProppertyAddress in a where their value is 'Null'.

  
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       IF(a.PropertyAddress = 'Null', b.PropertyAddress, a.PropertyAddress)
FROM nashville a
JOIN nashville b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress = 'Null';

UPDATE nashville a
JOIN nashville b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = 'Null';

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1) as Address 
FROM nashville;

ALTER TABLE Nashville
ADD PropertySplitAddress VARCHAR(255);

UPDATE Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, POSITION(',' IN PropertyAddress)-1);

ALTER TABLE Nashville
ADD PropertySplitCity VARCHAR(255);

UPDATE Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, POSITION(',' IN PropertyAddress)+1);

SELECT *
FROM Nashville;

-- Breaking out Owner Address

SELECT SUBSTRING_INDEX('Anne Smith', ' ', -1);

SELECT OwnerAddress
FROM Nashville;

SELECT 
    OwnerAddress,
    SUBSTRING_INDEX(OwnerAddress, ',', 1) AS StreetAddress,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS City,
    SUBSTRING_INDEX(OwnerAddress, ',', -1) AS State
FROM Nashville;

ALTER TABLE Nashville
ADD StreetAddressOwner VARCHAR(255);

UPDATE Nashville
SET StreetAddressOwner = SUBSTRING_INDEX(OwnerAddress, ',', 1);


ALTER TABLE Nashville
ADD CityOwner VARCHAR(255);

UPDATE Nashville
SET CityOwner = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

ALTER TABLE Nashville
ADD StateOwner VARCHAR(255);

UPDATE Nashville
SET StateOwner = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT *
FROM Nashville;

-- Change Y and N to Yes and No in SoldAsVacant

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) as Count
 FROM nashville
 GROUP BY SoldAsVacant
 Order BY 2;
 
 SELECT SoldAsVacant,
	CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
    END
 FROM Nashville;
 
 UPDATE Nashville
 SET SoldAsVacant = 
 CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END;

-- Remove Duplicates
SELECT *,
	ROW_NUMBER() OVER(
    PARTITION BY 
		ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        ORDER BY 
        UniqueID
        ) row_num
FROM nashville
ORDER BY ParcelID;
           

WITH ROW_NUM_CTE AS (
    SELECT 
        UniqueID,
        ROW_NUMBER() OVER (
            PARTITION BY 
                ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
            ORDER BY 
                UniqueID
        ) AS row_num
    FROM nashville
)
DELETE FROM nashville
WHERE UniqueID IN (
    SELECT UniqueID
    FROM ROW_NUM_CTE
    WHERE row_num > 1
);


-- Delete Unused Columns


SELECT *
FROM Nashville;

ALTER TABLE nashville
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress;



