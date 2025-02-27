create database zomato
use zomato

describe zomato

#imported dataset from php admin
select* from zomato_dataset
rename table zomato_dataset to zomato
select * from zomato

-- Change default column names 
alter table zomato change `COL 1` id int;
alter table zomato change `COL 2` restaurant varchar(255),
			       change `COL 3` city varchar(100),
                   change `COL 4` area varchar(100),
                   change `COL 5` rating double,
                   change `COL 6` rating_count int,
                   change `COL 7` cuisine text,
                   change `COL 8` cost_for_two int,
                   change `COL 9` address text,
                   change `COL 10` order_type varchar(100),
                   change `COL 11` table_reservation varchar(100),
                   change `COL 12` famous_food text;
alter table zomato add primary key(id)


  ---------------------------------------------------------------

select count(*) from zomato  # 44795 rows
delete from zomato where id=0

# total rest. 39588
select count(distinct restaurant) as total_restaurants
 from zomato 
 
 
 
# Multiple restaurant outlets in same city
 select restaurant,city,count(*) as count 
 from zomato 
 group by city,restaurant having count>1 
 order by restaurant  
 
#Restaurants present in multiple cities.
select restaurant,count(distinct city) as city_count , group_concat(distinct city) as cities_available
from zomato group by restaurant having city_count>1 order by city_count desc 


# Flag as restaurants as present in 'Single City' or 'Multiple Cities'.
select restaurant,count(distinct city) as city_count , group_concat(distinct city) as cities_available,
case
  when count(distinct city)  >1 then 'Multiple Cities'
  else 'Single City' 
  end as rest_available_in
from zomato group by restaurant
order by city_count desc

-- Distinct cities (7)
select distinct city from zomato;

-- How many restaurants are there in each city?
select city,count(restaurant) as rest_count from zomato group by city order by rest_count desc


------------------------------
#COST_FOR_TWO 
-- Values with 0 in  order by city (364 values)
select cost_for_two, count(*) 
from zomato where cost_for_two = 0

update zomato 
 set cost_for_two=
 (select avg(cost_for_two) from zomato where cost_for_two>0)
 where cost_for_two = 0


# RATING_COUNT 
-- 72 rows with rating_count=0
select rating_count, count(*) from zomato where rating_count = 0

select restaurant,rating_count, rating  #For rating more than 0 , rating_count should be atleast 1. 
 from zomato where rating_count = 0
 
#Update rows with 0 in rating_count to avg of the column.  
select avg(rating_count) from zomato where rating_count>0

update zomato 
 set rating_count=
 (select avg(rating_count) from zomato where rating_count>0)
 where rating_count = 0
 
 set sql_safe_updates =0

-------------------------------------------------------------------------------------------
#Order dataset by restaurant name in desc
select * from zomato order by restaurant desc;

#Order dataset by rating name from highest to lowest
select * from zomato order by rating desc;

#Order dataset by cost_for_two in asc
select * from zomato order by cost_for_two asc;


###########################################################structured analysis#####################################################
# Display only the rows where the id is an even number.
select id, restaurant from zomato where id%2 =0;



  ---------------------------------cost_for_two------------------------------
  
-- Average cost_for_two across all restaurants
select avg(cost_for_two) as avg_cost from zomato where cost_for_two>0  # avg is 529.65, max is 30,000

-- Maximum cost_for_two across the dataset
select max(cost_for_two)as max_cost from zomato 

-- Top 5 expensive restaurants in each city
with cte as
(select id, restaurant, city ,cost_for_two,
 dense_rank() over(partition by city order by cost_for_two desc) as dr
from zomato )
select * from cte where dr <=5;
  
-- avg dining cost_for_two in all cities
select city,round(avg(cost_for_two),0)as avg_cost_for_two
 from zomato group by city order by avg_cost_for_two
 
-- Restaurants where rating is more than the average.
select restaurant,city,area, cost_for_two from zomato where cost_for_two= (select round(avg(cost_for_two),0) from zomato);

-- Cost_for_two between 400 and 1000
select restaurant,city,cost_for_two from zomato where cost_for_two between 400 and 1000;

-- Affordable places 
select city,area,restaurant,cost_for_two,rating from zomato order by rating desc,cost_for_two asc limit 10

  ------------------------------------rating------------------------------

# Rest with highest rating (overall)
select id,restaurant, city ,rating from zomato 
where rating = (select max(rating) from zomato )

# 3 Rest with highest rating in each city 
with cte as
 (select id, restaurant,city, rating,
 dense_rank() over(partition by city order by rating desc) as dn
 from zomato )
select id, restaurant,city,rating,dn from cte where dn < 4	

-- rest w rating less than the avg 
select id,restaurant, city, rating from zomato 
where rating < (select avg(rating) as avg_rating from zomato)

-- Average rating in each city
select city, round(avg(rating),2) as city_avg_rating from zomato group by city

-- Min rating of restaurants in each city
select city, min(rating) as city_min_rating from zomato group by city

-- Restaurants with rating between 3.5 and 4.5
select restaurant,city,rating from zomato where rating => 3.5 and rating <= 4.5;

-- Emerging places with low rating_count but high ratings
select city,area,restaurant,rating from zomato order by rating desc, rating_count asc limit 10


---------------------------------rating_count------------------------------
-- Restaurant with most reviews given.
select max(rating_count) from zomato

1111111111 -- check rat count wrt most rest in each city
-- Average rating count given to restaurants in each city
select city, round(avg(rating_count)) as cities_avg_rating_count from zomato group by city

-- Famous restaurants with high rating as well as high rating_count
select restaurant,city,rating from zomato order by rating desc, rating_count desc limit 10

-- Restaurants needing improvement 
select restaurant,city,rating from zomato order by rating asc, rating_count desc limit 10

------------------------------------------------------------


---------------------- basic queries ----------------------
 select * from zomato
 
-- Rest. where reservation is to be made 
select id,restaurant,city,cost_for_two,table_reservation
from zomato where table_reservation='reservation' order by city 

-- Identify the top-rated restaurants that offer online ordering in each city.(25755 online avail)
select id,city,restaurant,area,cost_for_two,rating,order_type 
from zomato where order_type='Online-Order' 
order by city, rating desc


-- Restaurants with low rating count but high ratings
select id,city,restaurant,cost_for_two,rating_count,rating
from zomato where rating>=3.7 order by rating desc ,rating_count

-- Restaurants in Mumbai and Banglore
select City,restaurant,area, rating from zomato where city in ('Mumbai','Banglore')

-- Restaurants except Chennai
select City,restaurant,area, rating from zomato where city != 'Chennai'

-- Restaurants with rating between 3 and 4.5
select id, City,restaurant,area, rating from zomato where rating between 3 and 4.5

-- most no. of ratings given to a rest
select restaurant,city,rating_count from zomato order by rating_count desc limit 10


# Areas with the Best Value for Money:top 10 best-rated dining for the least amount of money?
select restaurant,city,rating,cost_for_two from zomato order by rating desc,cost_for_two asc limit 10

--11 
select restaurant,city from zomato where famous_food = '%Pizza%' 
