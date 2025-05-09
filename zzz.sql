create database zomato
use zomato

show tables;
#imported dataset from php admin
select* from india_zomato_dataset;
rename table india_zomato_dataset to zomato_data


select * from zomato_data ;

#REPAIR TABLE `zomato`;
#SHOW TABLE STATUS LIKE 'zomato';
#ALTER TABLE `zomato` ENGINE = InnoDB;  #did'nt work



-- Change default column names 
alter table zomato_data change `COL 1` id int;
alter table zomato_data change `COL 2` restaurant varchar(255) ,
alter table zomato_data change `COL 3` city varchar(100),
                   change `COL 4` area varchar(100),
                   change `COL 5` rating double default null,
                   change `COL 6` rating_count int default null,
                   change `COL 7` cuisine text,
                   change `COL 8` cost_for_two int default null,
                   change `COL 9` address text,
                   change `COL 10` order_type varchar(100),
                   change `COL 11` table_reservation varchar(100),
                   change `COL 12` famous_food text;
alter table zomato_data add primary key(id)

DESCRIBE zomato_data;

#alter table zomato change column RESTAURANT_NAME TO restaurant;
---------------------------------------------------------------

select count(*) from zomato_data  # 44795 rows
delete from zomato_data where id=0  #Delete the row where the column name has beed added accidently

select * from zomato_data

# total rest. 39588
select count(distinct restaurant) as total_restaurants
 from zomato_data 
 
 -- Distinct cities (7)
select distinct city from zomato_data;
 
 set sql_safe_updates =0 #To turn off Safe updates. 
 
 -- How many restaurants are there in each city?
select city,count(restaurant) as rest_count from zomato_data group by city order by rest_count desc

 
# Multiple restaurant outlets in same city
 select restaurant,city,count(*) as count 
 from zomato_data 
 group by city,restaurant having count>1 
 order by restaurant  
 
#Restaurants present in multiple cities.
select restaurant,count(distinct city) as city_count , group_concat(distinct city) as cities_available
from zomato_data group by restaurant having city_count>1 order by city_count desc 


# Flag as restaurants as present in 'Single City' or 'Multiple Cities'.
select restaurant,count(distinct city) as city_count , group_concat(distinct city) as cities_available,
case
  when count(distinct city)  >1 then 'Multiple Cities'
  else 'Single City' 
  end as rest_available_in
from zomato_data group by restaurant
order by city_count desc



------------------------------
#COST_FOR_TWO 
-- Values with 0 in  order by city (364 values)
select cost_for_two, count(*) 
from zomato_data where cost_for_two = 0

update zomato_data 
 set cost_for_two=
 (select avg(cost_for_two) from zomato_data where cost_for_two>0)
 where cost_for_two = 0


# RATING_COUNT 
-- 72 rows with rating_count=0
select rating_count, count(*) from zomato_data where rating_count = 0

select restaurant,rating_count, rating  #For rating more than 0 , rating_count should be atleast 1. 
 from zomato_data where rating_count = 0
 
#Update rows with 0 in rating_count to avg of the column.  
select avg(rating_count) from zomato_data where rating_count>0

update zomato_data 
 set rating_count=
 (select avg(rating_count) from zomato_data where rating_count>0)
 where rating_count = 0
 
 set sql_safe_updates =0

-------------------------------------------------------------------------------------------
#Order dataset by restaurant name in desc
select * from zomato_data order by restaurant desc;

#Order dataset by rating name from highest to lowest
select * from zomato_data order by rating desc;

#Order dataset by cost_for_two in asc
select * from zomato_data order by cost_for_two asc;


###########################################################structured analysis#####################################################
# Display only the rows where the id is an even number.
select id, restaurant from zomato_data where id%2 =0;


  ---------------------------------cost_for_two------------------------------
  
-- Average cost_for_two across all restaurants
select avg(cost_for_two) as avg_cost from zomato_data where cost_for_two>0  # avg is 529.65, max is 30,000

-- Maximum cost_for_two across the dataset
select max(cost_for_two)as max_cost from zomato_data 

-- Top 5 expensive restaurants in each city
with cte as
(select id, restaurant, city ,cost_for_two,
 dense_rank() over(partition by city order by cost_for_two desc) as dr
from zomato_data )
select * from cte where dr <=5;
  
-- avg dining cost_for_two in all cities
select city,round(avg(cost_for_two),0)as avg_cost_for_two
 from zomato_data group by city order by avg_cost_for_two
 
-- Restaurants where cost_for_two is more than the average.
select restaurant,city,area, cost_for_two from zomato_data where cost_for_two> (select round(avg(cost_for_two),0) from zomato_data);

-- Cost_for_two between 400 and 1000
select restaurant,city,cost_for_two from zomato_data where cost_for_two between 400 and 1000;

-- Affordable places 
select city,area,restaurant,cost_for_two,rating from zomato_data order by rating desc,cost_for_two asc limit 10


-- Label restaurants according to cost 
select restaurant , 
case 
     when cost_for_two < 500 then 'Affordable' 
     when cost_for_two between 500 and 2500 then 'Mid-range' 
     when cost_for_two > 2500 then 'High-end' 
  end as cost_category   
from zomato_data 

-- Cost difference in each city
select city, 
   max(cost_for_two) as max_cost,
   min(cost_for_two) as min_cost
from zomato_data
group by city;

  ------------------------------------rating------------------------------

# Rest with highest rating (overall)
select id,restaurant, city ,rating from zomato_data 
where rating = (select max(rating) from zomato_data )

-- Top-Rated Budget-Friendly Eateries
select city,area,restaurant,rating from zomato_data order by cost_for_two asc, rating desc 


# 3 Rest with highest rating in each city 
with cte as
 (select id, restaurant,city, rating,
 row_number() over(partition by city order by rating desc) as rn
 from zomato_data )
select id, restaurant,city,rating,rn from cte where rn < 4	

-- rest w rating less than the avg 
select id,restaurant, city, rating from zomato_data 
where rating < (select avg(rating) as avg_rating from zomato_data)

-- Average rating in each city
select city, round(avg(rating),2) as city_avg_rating from zomato_data group by city

-- Min rating of restaurants in each city
select city, min(rating) as city_min_rating from zomato_data group by city

-- Restaurants with rating between 3.5 and 4.5
select restaurant,city,rating from zomato_data where rating => 3.5 and rating <= 4.5;

-- Emerging places with low rating_count but high ratings
select city,area,restaurant,rating from zomato_data order by rating desc, rating_count asc limit 10

-- Overrated restaurants (Rating low, cost high)
select city, restaurant, rating, cost_for_two from zomato_data order by rating asc, cost_for_two desc


--------------------------------------rating_count------------------------------------------------

-- Restaurant with most reviews given.
select max(rating_count) from zomato_data

1111111111 -- check rat count wrt most rest in each city
-- Average rating count given to restaurants in each city
select city, round(avg(rating_count)) as cities_avg_rating_count from zomato_data group by city

-- Famous restaurants with high rating as well as high rating_count
select restaurant,city,rating,rating_count from zomato_data order by rating desc, rating_count desc limit 10

-- Restaurants needing improvement 
select restaurant,city,rating,rating_count from zomato_data order by rating asc, rating_count desc limit 10


---------------------- basic queries ----------------------
 select * from zomato_data
 
-- Rest. where reservation is to be made 
select id,restaurant,city,cost_for_two,table_reservation
from zomato_data where table_reservation='reservation' order by city 


-- Restaurants with low rating count but high ratings
select id,city,restaurant,cost_for_two,rating_count,rating
from zomato_data where rating>=3.7 order by rating desc ,rating_count

-- Restaurants in Mumbai and Banglore
select City,restaurant,area, rating from zomato_data where city in ('Mumbai','Banglore')

-- Restaurants except Chennai
select City,restaurant,area, rating from zomato_data where city != 'Chennai'

-- Restaurants with rating between 3 and 4.5
select id, City,restaurant,area, rating from zomato_data where rating between 3 and 4.5


-- most no. of ratings given to a rest
select restaurant,city,rating_count from zomato_data order by rating_count desc limit 10


# Areas with the Best Value for Money:top 10 best-rated dining for the least amount of money?
select restaurant,city,rating,cost_for_two from zomato_data order by rating desc,cost_for_two asc limit 10

1111111
-- CHECK THIS 
select restaurant,city from zomato_data where famous_food = '%pizza%' 


--------------------------------------order_type------------------------------------------------

-- Identify the top-rated restaurants that offer online ordering in each city.(25755 online avail)
select id,city,restaurant,area ,cost_for_two,rating,order_type 
from zomato_data where order_type='Online-Order' and rating between 3.7 and 5
order by rating desc, city asc

-- online order available rest each city
select city, count(*) from zomato_data group by city order by count(*) desc


-- % of restaurants allowing having online ordering feature.
select 
round(100*sum(case when order_type='Online-Order' then 1 else 0 end)/count(order_type),2) 
     as online_ordering_percent_overall
from zomato_data


-- % of rest with Online ordering in each city
with cte as(
select city,
round(100* sum(case when order_type='Online-Order' then 1 else 0 end)/count(order_type),2) 
      as online_percent
from zomato_data  group by city
)
select * from cte
order by online_percent desc

  ------------------------------------Table_Reservation------------------------------
select * from zomato_data

-- Compare costs for restaurants having table reservation and without
select table_reservation, round(avg(cost_for_two),2) as avg_cost_wrt_reservation
from zomato_data group by table_reservation # Costs are higher for restaurants with reservation

-- Compare restaurants having table reservation with respect to rating count
select table_reservation, round(avg(rating_count),2) as avg_rating_count_wrt_reservation
from zomato_data group by table_reservation 
#restaurants with reservation have customers who more likely to rate them


-- % of restaurants having table reservation
select 
round(100*sum(case when table_reservation = 'Reservation' then 1 else 0 end)/ count(table_reservation),2)
as percent_reservation
from zomato_data # Only 6.6 % of restaurants have table_reservation

  ------------------------------------area------------------------------
-- Restaurants and their count in each area of cities
select city,area, group_concat(restaurant separator ' , ') as restaurants_available ,
count(restaurant) as restaurant_count
from zomato_data group by city,area order by restaurant_count desc


-- Top 10 popular areas (with highest restaurant count)
select city,area, count(restaurant) as restaurant_count
from zomato_data group by city,area order by restaurant_count desc limit 10

-- Price difference in different areas
select city, area, 
       min(cost_for_two) as min_cost,
       max(cost_for_two) as max_cost,
       round(avg(cost_for_two),0) as avg_cost
from zomato_data
group by city, area
order by avg_cost desc;

  ------------------------------------ cuisine ------------------------------
  -- highest cuisines availabe in a city
select city,  count(cuisine) as cuisine_count,group_concat(cuisine) as all_cuisine 
from zomato_data group by city order by cuisine_count desc

