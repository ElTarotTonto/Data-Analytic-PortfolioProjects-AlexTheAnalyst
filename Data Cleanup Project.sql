

--Cleaning Data in SQL Queries

select *
from PortfolioProject..NashvilleHousing




------------------------------------------------------------------------------------------------

/*
Standardize Date Format 
*/

select SaleDate, Convert(Date,SaleDate)
from PortfolioProject..NashvilleHousing

update portforlioproject..NashvilleHousing
set SaleDate - Convert(Date,SaleDate)

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted Date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted = Convert(Date,SaleDate)



-------------------------------------------------------------------------------------------------

/** Populate Property Address Data ***/

--Investigation of all property address data

select PropertyAddress 
from PortfolioProject..NashvilleHousing
where PropertyAddress is null


--Further investigation shows that property addresses are correlated to the parcel ids

select * 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


--Our objective is to find all property address nulls and add the addresses 
-- based on existing parcel ids associated with the address names


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress)
from portfolioproject..nashvillehousing A
join portfolioproject..nashvillehousing B
on a.parcelid = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set propertyaddress = isnull(a.propertyaddress, b.PropertyAddress)
from portfolioproject..nashvillehousing A
join portfolioproject..nashvillehousing B
on a.parcelid = b.ParcelID
and a.[UniqueID] <> b.[UniqueID]

--------------------------------------------------------------------------------------

---Breaking out address into individual columns (Address, City, State)


select propertyaddress 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(propertyaddress,1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(propertyaddress,CHARINDEX(',', PropertyAddress)+ 1, len(PropertyAddress)) as Location

from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress,1, CHARINDEX(',', PropertyAddress)-1)


alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress,CHARINDEX(',', PropertyAddress)+ 1, len(PropertyAddress)) 

Select *
from PortfolioProject..NashvilleHousing


 --- Alternative---

Select owneraddress
from PortfolioProject.dbo.NashvilleHousing

Select
Parsename(replace(owneraddress,',','.') , 3) as OwnerAddress
,Parsename(replace(owneraddress,',','.') , 2) as City
,Parsename(replace(owneraddress,',','.') , 1) as State
from portfolioproject.dbo.nashvillehousing


alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = Parsename(replace(owneraddress,',','.') , 3)


alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = Parsename(replace(owneraddress,',','.') , 2) 

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitState = Parsename(replace(owneraddress,',','.') , 1)


Select *
From PortfolioProject.dbo.NashvilleHousing






-------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant


/* Note: Downloaded Test Data for field SoldAsVacant came completely categorized.
0 meaning 'no' and 1 meaning 'yes'. 
This clean up process was designed to organize the data results from SoldAsVacant 
to be uniformly be shown as 2 simple answers like Yes or No.

Below are notes on how to fix the process if the row options under field SoldAsVacant were shown as Yes, No, 1, 0 

As as a personal note: The solution is similar to Excel IF statements and Python If, Elif, and else statements*/


--select SoldAsVacant
--, Case when SoldAsVacant = '1' then 'Yes'
--       when SoldAsVacant = '0' then 'No'
--       else SoldAsVacant
--       end
--from portfolioproject..NashvilleHousing








----------------------------------------------------------------------------------------------
/* Removing Duplicates */ 

-- A CTE is needed to bypass an error when removing duplicate data entries ----

with RowNumCTE As(
select *,
	ROW_NUMBER() Over (
	partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				     UniqueID
					 ) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *    --Used Delete command plus coding below to delete 104 duplicate rows
from RowNumCTE
where row_num > 1
--order by PropertyAddress



select *
from PortfolioProject.dbo.NashvilleHousing



-----------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
drop column SaleDate

