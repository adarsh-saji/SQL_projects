-- filling the null values in propertyaddress

select *
from housing_data
where propertyaddress is null;

select *
from housing_data
order by parcelid desc;

select a.parcelid, a.propertyaddress,b.parcelid, b.propertyaddress,
coalesce(a.propertyaddress,b.propertyaddress) as propertyaddress_cleaned
from housing_data as a
join housing_data b
on a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid
where a.propertyaddress is null

--filling it by self joining it and then using the address to fill it as multiple
-- sales has the same address if it is done by the same person
update housing_data as a
set propertyaddress = coalesce(a.propertyaddress,b.propertyaddress)
from housing_data as b
where a.parcelid = b.parcelid
and a.uniqueid <> b.uniqueid

select *
from housing_data
where propertyaddress is null

--Breaking address into individual colunms(Address,city,state)
select propertyaddress
from housing_data

select substring(propertyaddress from 1 for position(','in propertyaddress) -1) as address,
substring(propertyaddress from position(','in propertyaddress) +1) as city
from housing_data

alter table housing_data
add column Address varchar(255)

alter table housing_data
add column City varchar(50)

update housing_data
set Address = substring(propertyaddress from 1 for position(','in propertyaddress) -1) 

update housing_data
set City = substring(propertyaddress from position(','in propertyaddress) +1) 

select * from housing_data

-- split owneraddress

-- instead of using substring we have used split_part here as it more convenient
select split_part(owneraddress,',',1) as Owner_address,
split_part(owneraddress,',',2) as Owner_city,
split_part(owneraddress,',',3) as Owner_state
from housing_data

alter table housing_data
add column Owner_address varchar(255)

alter table housing_data
add column Owner_city varchar(255)

alter table housing_data
add column Owner_state varchar(255)

update housing_data
set Owner_address = split_part(owneraddress,',',1)

update housing_data
set Owner_city = split_part(owneraddress,',',2)

update housing_data
set Owner_state = split_part(owneraddress,',',3)

select * from housing_data

--replace yes with y and no with n in soldasvacant

select distinct(soldasvacant), count(soldasvacant)
from housing_data
group by soldasvacant
order by 2

-- using a subquery with the case sentence to identify the yes and no cases
select distinct(soldasvacant_1), count(soldasvacant_1)
from(
select 
case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end as soldasvacant_1
from housing_data) a 
group by a.soldasvacant_1
order by 2

update housing_data
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end

--remove duplicates just for the purpose of this project

with Duplicatecte as(
select *,
	   ROW_NUMBER () OVER (
	   PARTITION BY parcelid,
	   				propertyaddress,
	   				saledate,
	   				saleprice,
	   				legalreference
	   ORDER BY UniqueID) row_num
FROM housing_data
)	   

-- select * 
-- FROM Duplicatecte
-- where row_num >1

Delete FROM housing_data
USING Duplicatecte
WHERE housing_data.uniqueid = Duplicatecte.uniqueid AND duplicatecte.row_num>1

--deleting unwanted columns

ALTER TABLE housing_data
DROP COLUMN propertyaddress,
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict;




