
create database zomato

use zomato
create table ztest(restaurant varchar(100) not null primary key, 
    city varchar(20) not null,
    area varchar (50),  rating decimal (2,1) ,   
    rating_count int  ,cusine varchar (30),  
    cost_for_two int ,  address varchar (100),
    online_order varchar (15),table_reservation char (15) , 
    famous_food varchar(100));
    
describe zomato
rename table ztest to zomato;

select* from zomato

-- Desc restautants Z to A  
select *from zomato order by restaurant desc

-- no.of rows
select count(*) as row_count  
from zomato;

-- delete rows with value 0
SET SQL_SAFE_UPDATES = 0;
SELECT * FROM zomato WHERE rating= 0.0;
delete  from zomato where rating=0.0  ;

# total rest. 59
select count(distinct restaurant)as total_restaurants
 from zomato

select distinct city from zomato;

-- How many restaurants are there in each city?
select city,count(restaurant) as no_of_rest from zomato group by city


delete  from zomato where cost_for_two=0


# 1. Most Popular Rest: top 10 rest. with highest avg rating
select restaurant,city, round(avg(rating),1)as highest_avg_rating from zomato
 group by restaurant,city order by highest_avg_rating desc limit 10

select avg(cost_for_two) as avg_cost from zomato  # avg is 443.22 around 450 max is 2000
select max(cost_for_two)as max_cost
 from zomato 


-- Rest. where reservatn is to be made (out of 59 rows in this set)
select restaurant,city,cost_for_two,table_reservation 
from zomato where table_reservation='reservation'

# 4. Identify the top-rated restaurants that offer online ordering in each city.
select city,restaurant,area,cost_for_two,rating,online_order 
from zomato where online_order='Online-Order'and rating>=3.7 
order by city desc

#rest in MUM with offline orders and rating>3.5
select* from zomato where rating>=3.5 and city='Mumbai'and online_order='Offline- Order' order by rating desc


#3.Which areas offer the most affordable dining options based on the average cost for two?
select city,restaurant,area,cost_for_two from zomato
 where cost_for_two <=400 order by cost_for_two asc

-- (for 5 in each city use partition and CTE)

-- avg dining cost_for_two in all cities
select restaurant,city,area,round(avg(cost_for_two),0)as avg_cost
 from zomato group by city order by avg_cost

-- search a specific type of famous food
select city,cusine from zomato
select restaurant,cusine from zomato where cusine like '%Continental%'    #rather than cusine='Chinese'or'Chinese,North Indian' 

#2.Which city offers the most diverse range of cuisines? AND WHAT ARE THOSE CUISINES using Outer query/group concat
select city,count(cusine) as cusine_count from zomato group by city order by cusine_count desc limit 1
 #Delhi offers most diverse cuisine 38
 
select city,cusine from zomato where city= (select city from zomato group by city order by count(distinct cusine) desc limit 1)order by cusine 

select city, group_concat(distinct cusine order by cusine) from zomato where city='Delhi NCR'  


#9.City Comparison of Dining Costs:Avg cost for 2 in each city
select round(avg(cost_for_two),0) as avg_cost_mum from zomato where city='Mumbai'    # lowest 350
select round(avg(cost_for_two),0) as avg_cost_del from zomato where city='Delhi NCR' # highest avg 421
select round(avg(cost_for_two),0) as avg_cost_kol from zomato where city='Kolkata'   #365

######   ######    ######   ######    ######   ######    ######   ######

select* from zomato

-- most no. of ratings given to a rest
select restaurant,area,city,rating_count from zomato order by rating_count desc limit 10

#12.Areas with the Best Value for Money:top 10 best-rated dining for the least amount of money?
select restaurant,area,city,rating,cost_for_two from zomato order by rating desc,cost_for_two asc limit 10

#13.Hidden gems: less rating count high rating
select restaurant,area,city,rating,rating_count from zomato 
where rating>=3.7 order by rating desc,rating_count asc limit 10

# 17th Q in ppt
#15.a)Distributn of rest rating 
#15.b)Which city has the highest average rating #MUM has 4 avg 
select city,rating,count(*)as rating_count from zomato group by city,rating order by city,rating desc #15.a 
select city,round(avg(rating),0)as avg_rat from zomato group by city order by avg_rat desc  #15.b

-- famous foods of each city
select city,group_concat(distinct famous_food order by famous_food asc)as famous_foods_of_each_city
 from zomato where famous_food!='-' group by city order by city

-- famous foods from restaurants
-- famous foods from restaurants
select restaurant,famous_food,city,rating from zomato
 where famous_food!='-' order by rating desc

-- Identify the Most Common Cuisine:
select cusine, count(*) as common_cusine from zomato group by cusine order by common_cusine desc limit 1




#####   ######    #####   #####  ####  #####  ######




#Q. 5,6,7,8,10,11,12,13,14,15
select* from zomato

-- most no. of ratings given to a rest
select restaurant,area,city,rating_count from zomato order by rating_count desc limit 10

#12.Areas with the Best Value for Money:top 10 best-rated dining for the least amount of money?
select restaurant,area,city,rating,cost_for_two from zomato order by rating desc,cost_for_two asc limit 10

#13.Hidden gems: less rating count high rating
select restaurant,area,city,rating,rating_count from zomato 
where rating>=3.7 order by rating desc,rating_count asc limit 10

# 17th Q in ppt
#15.a)Distributn of rest rating 
#15.b)Which city has the highest average rating #MUM has 4 avg 
select city,rating,count(*)as rating_count from zomato group by city,rating order by city,rating desc #15.a 
select city,round(avg(rating),0)as avg_rat from zomato group by city order by avg_rat desc  #15.b

-- famous foods of each city
select city,group_concat(distinct famous_food order by famous_food asc)as famous_foods_of_each_city
 from zomato where famous_food!='-' group by city order by city

-- famous foods from restaurants
-- famous foods from restaurants
select restaurant,famous_food,city,rating from zomato
 where famous_food!='-' order by rating desc

-- Identify the Most Common Cuisine:
select cusine, count(*) as common_cusine from zomato group by cusine order by common_cusine desc limit 1