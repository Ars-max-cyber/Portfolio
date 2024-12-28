---Most Important thing to do before dive into data to make one copy of it

USE nashvilla;
Create table Housing_backup as
select * from nashvilla.housing;

---cleaning data sets

select * from nashvilla.housing;

----Standardize the date formate 

select saleDate, Date_format(str_to_date(saleDate, '%M %d, %Y'), '%d-%m-%Y') as Formatted_Date from nashvilla.housing;

---turn off sql safemode only for current session

set sql_safe_Updates = 0;

update nashvilla.housing
set saleDate = Date_format(str_to_date(saleDate, '%M %d, %Y'), '%d-%m-%Y')

select * from nashvilla.housing;

----populate the propertyaddress

select a.PropertyAddress, a.uniqueID_, a.parcelID, b.PropertyAddress, b.uniqueID_, b.parcelID, ifnull(a.propertyaddress, b.propertyaddress) 
from nashvilla.housing a
join nashvilla.housing b
on b.parcelID = a.parcelID
and a.UniqueID_ <> b.UniqueID_ 
where a.propertyAddress is null

update nashvilla.housing a
join nashvilla.housing b
on b.parcelID = a.parcelID
and a.UniqueID_ <> b.UniqueID_ 
set a.propertyaddress = ifnull(a.propertyaddress, b.propertyaddress)
where a.propertyAddress is null

---Breaking out Address into individual columns 

select propertyaddress from nashvilla.housing;

select
trim(Substring(propertyaddress, 1, locate(',', propertyaddress)-1)) as HouseAddress,
trim(substring(propertyaddress, locate(',',propertyaddress)+1)) as City
from nashvilla.housing;

Alter table nashvilla.housing
add HouseAddress nvarchar(255);

update nashvilla.housing
set HouseAddress = trim(Substring(propertyaddress, 1, locate(',', propertyaddress)-1))

Alter table nashvilla.housing
add City nvarchar(255);

update nashvilla.housing
set City = trim(substring(propertyaddress, locate(',',propertyaddress)+1))

---now check if the table is updated with new columns or not

select * from nashvilla.housing;

----now owner address
select owneraddress from nashvilla.housing;

select substring_index(ownerAddress, ',', 1) as OwnerHouseAddress,
	   substring_index(substring_index(owneraddress, ',', 2),',',-1) as OwnerCity,
       substring_index(ownerAddress, ',', -1) as OwnerState
 from nashvilla.housing 
 
 ---now insert into database
 
 alter table nashvilla.housing
 add OwnerHouseAddress nvarchar(255);
 
 update nashvilla.housing
 set OwnerHouseAddress = substring_index(ownerAddress, ',', 1);
  
alter table nashvilla.housing
add OwnerCity nvarchar(255);

update nashvilla.housing
set OwnerCity = substring_index(substring_index(owneraddress, ',', 2),',',-1);

alter table nashvilla.housing
add OwnerState nvarchar(255);

update nashvilla.housing
set OwnerState = substring_index(ownerAddress, ',', -1)
 
 
 ---check
 
 select * from nashvilla.housing;
 
 
 ---changing Y and N to Yes and NO in column 'SoldAsVaccant'

select soldasvacant, count(Soldasvacant)
from nashvilla.housing
group by soldasvacant
order by 2

select soldasvacant,
case
    when soldasvacant = 'Y' then 'Yes'
    when soldasvacant = 'N' then 'No'
    Else soldasvacant
end as newresult
from nashvilla.housing


update nashvilla.housing
set soldasvacant = case
    when soldasvacant = 'Y' then 'Yes'
    when soldasvacant = 'N' then 'No'
    Else soldasvacant
end

---check

select * from nashvilla.housing

----Deleting duplicates

select *,
Row_Number() over 
    (partition by parcelID,
				propertyaddress,
                saleprice,
                saledate
                order by UniqueID_
				 ) Row_no
 from nashvilla.housing
 order by parcelID

---use CTE 

with Num_Cte as (
select *,
Row_Number() over 
    (partition by parcelID,
				propertyaddress,
                saleprice,
                saledate
                order by UniqueID_
				 ) Row_no
 from nashvilla.housing
 order by parcelID
)
 select * 
 from Num_cte
 where Row_no > 1
 order by Propertyaddress
 
delete h
from nashvilla.housing as h
join(
 select UniqueID_,Row_Number() 
                  over (partition by parcelID,
				propertyaddress,
                saleprice,
                saledate
                order by UniqueID_) as row_num 
                from nashvilla.housing) as Subquery
                on h.UniqueID_ = Subquery.UniqueID_
                where Subquery.row_num > 1
                
-----to check if the duplicates are deleted or not copy the same code from above and replace delete h with select *                
		
select *
from nashvilla.housing as h
join(
 select UniqueID_,Row_Number() 
                  over (partition by parcelID,
				propertyaddress,
                saleprice,
                saledate
                order by UniqueID_) as row_num 
                from nashvilla.housing) as Subquery
                on h.UniqueID_ = Subquery.UniqueID_
                where Subquery.row_num > 1

---deleting unused columns from table
---im going to delete columns Propertyaddress and OwnerAddress because i already split them 
---into better view.

Alter table nashvilla.housing
drop column PropertyAddress;

Alter table nashvilla.housing
drop column OwnerAddress;

select * from nashvilla.housing;








