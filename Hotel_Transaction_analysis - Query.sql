
-- Is hotel revenue increasing year on year?
-- What market segment are major contributors of the revenue per year? In there a change year on year?
-- When is the hotel at maximum occupancy? Is the period consistent across the years?
-- When are people cancelling the most?
-- Are families with kids more likely to cancel the hotel booking?



-- Exploring the tables
Select * from hotel2018;
Select * from hotel2019;
Select * from hotel2020;
Select * from market_segment;
Select * from meal_cost;


-- Explore Data
SELECT Distinct(hotel) from hotel2018;

-- TWO type of hotels
-- City Hotel: 13682
-- Resort Hotel: 8314
SELECT hotel, count(*) from hotel2018 group by 1;

-- TWO type of is_canceled
-- 0 : 13854
-- 1 : 8142
SELECT is_canceled, count(*) from hotel2018 group by 1;

-- Year 2018: 21996
SELECT arrival_date_year, count(*) from hotel2018 group by 1;

-- Two type of cancelations: Canceled, No-Show
SELECT is_canceled, reservation_status, count(*) from hotel2018 group by 1,2;


-- **************************
-- Revenue Calculation for 2018
-- **************************

-- 1. Room Booking
-- 2. Meal Cost
-- 3. Discount


-- ** 1st Component: Total Nights + adr
Select (stays_in_weekend_nights + stays_in_week_nights) as total_night 
from hotel2018;

Select (stays_in_weekend_nights + stays_in_week_nights) as total_night, adr
from hotel2018;

Select 
(stays_in_weekend_nights + stays_in_week_nights) as total_night, adr, 
(stays_in_weekend_nights + stays_in_week_nights) * adr as per_booking_room_cost
from hotel2018;

-- Only for confirmed stays
Select 
(stays_in_weekend_nights + stays_in_week_nights) as total_night, adr, 
(stays_in_weekend_nights + stays_in_week_nights) * adr as per_booking_room_cost
from hotel2018 where is_canceled = 0;

-- Total Room Cost for 2018: 4511559.10
Select 
sum((stays_in_weekend_nights + stays_in_week_nights) * adr) as room_cost
from hotel2018 where is_canceled = 0;


-- ** 2nd Component: Meal Cost: number of people * number of night * meal_charger

Select * from hotel2018;

Select 
	(stays_in_weekend_nights + stays_in_week_nights) as total_night,
    (adults + children + babies) as total_people,
    meal
 from hotel2018;
Select * from meal_cost;


Select 
	(h.stays_in_weekend_nights + h.stays_in_week_nights) as total_night,
    (h.adults + h.children + h.babies) as total_people,
    h.meal, m.cost
 from hotel2018 as h inner join meal_cost as m on h.meal = m.meal;
 
 
Select 
	(h.stays_in_weekend_nights + h.stays_in_week_nights) as total_night,
    (h.adults + h.children + h.babies) as total_people,
    h.meal, 
    m.cost,
    (h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children + h.babies) * m.cost 
    as meal_cost_per_booking,
	(h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr as per_booking_room_cost
from hotel2018 as h inner join meal_cost as m on h.meal = m.meal
 where h.is_canceled = 0;



 
Select 
    ((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children + h.babies) * m.cost)
    +
	((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr) as rev_per_booking_with_discount
from hotel2018 as h inner join meal_cost as m on h.meal = m.meal
 where h.is_canceled = 0;

 
-- ** 3rd Component: Discount



Select * from hotel2018;
Select * from market_segment;

SELECT * FROM hotel2018 as h inner join market_segment as seg 
on seg.market_segment = h.market_segment;



Select 
    ((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children + h.babies) * m.cost)
    +
	((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr) as rev_per_booking_with_discount,
    seg.discount
from hotel2018 as h inner join meal_cost as m on h.meal = m.meal
inner join market_segment as seg 
on seg.market_segment = h.market_segment
 where h.is_canceled = 0;



Select 
    ((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children + h.babies) * m.cost)
    +
	((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr) as rev_per_booking_with_discount,
    (1 - seg.discount)
from hotel2018 as h inner join meal_cost as m on h.meal = m.meal
inner join market_segment as seg 
on seg.market_segment = h.market_segment
 where h.is_canceled = 0;
 
 
 
 Select 
    ((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children + h.babies) * m.cost)
    +
	((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr) as rev_per_booking_with_discount,
    (1 - seg.discount),
    
    (
    
		((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children + h.babies) * m.cost)
		+
		((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr)
        
    ) * (1 - seg.discount) as per_booking_payment
    
    
from hotel2018 as h inner join meal_cost as m on h.meal = m.meal
inner join market_segment as seg 
on seg.market_segment = h.market_segment
 where h.is_canceled = 0;
 
 
 select 
	sum (yearly_rev) from 
 (
	 Select arrival_date_year as year,
		(((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children + h.babies) * m.cost)
			+
			((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr)
		) * (1 - seg.discount) as yearly_rev
		
	from hotel2018 as h inner join meal_cost as m on h.meal = m.meal
	inner join market_segment as seg 
	on seg.market_segment = h.market_segment
	 where h.is_canceled = 0
 ) as temp;

Select h.arrival_date_year as year,
		sum((((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children + h.babies) * m.cost)
			+
			((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr)
		) * (1 - seg.discount)) as yearly_rev
		
	from hotel2018 as h inner join meal_cost as m on h.meal = m.meal
	inner join market_segment as seg 
	on seg.market_segment = h.market_segment
	 where h.is_canceled = 0
group by 1;



-- ********************
-- 1st Question: Revenue by Year
-- ********************
Select h.arrival_date_year as year,
		sum(
        (
			((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children) * m.cost)
			+
			((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr)
        ) * (1 - seg.discount)
        ) as yearly_rev
	from 
    (
		SELECT * FROM hotel2018
        union
        SELECT * FROM hotel2019
        union
        SELECT * FROM hotel2020
    )
    as h inner join meal_cost as m on h.meal = m.meal
	inner join market_segment as seg 
	on seg.market_segment = h.market_segment
	 where h.is_canceled = 0
group by 1;


-- ********************
-- 2nd Question: Market Segment
-- ********************
SELECT market_segment, max(year2018) as year2018, max(year2019) as year2019 , max(year2020) as year2020 FROM 

(SELECT 
 market_segment, 
CASE 
	WHEN year = 2018 THEN yearly_rev
    ELSE 0
END as year2018,
CASE 
	WHEN year = 2019 THEN yearly_rev
    ELSE 0
END as year2019,
CASE 
	WHEN year = 2020 THEN yearly_rev
    ELSE 0
END as year2020
FROM (
Select h.arrival_date_year as year, seg.market_segment,
		sum((((h.stays_in_weekend_nights + h.stays_in_week_nights) * (h.adults + h.children + h.babies) * m.cost)
			+
			((h.stays_in_weekend_nights + h.stays_in_week_nights) * h.adr)
		) * (1 - seg.discount)) as yearly_rev
	from 
    (
		SELECT * FROM hotel2018
        union
        SELECT * FROM hotel2019
        union
        SELECT * FROM hotel2020
    )
    as h inner join meal_cost as m on h.meal = m.meal
	inner join market_segment as seg 
	on seg.market_segment = h.market_segment
	 where h.is_canceled = 0
group by 1,2) as temp) as temp2 GROUP BY 1;


-- ********************
-- 3rd Question: When is the hotel at maximum occupancy? Is the period consistent across the years? 
-- ********************

SELECT arrival_date_month, max(count2018) as count2018, max(count2019) as count2019 , max(count2020) as count2020, max(week_num) as week_num  FROM 

(SELECT 
 arrival_date_month, week_num, 
CASE 
	WHEN year = 2018 THEN cnt
    ELSE 0
END as count2018,
CASE 
	WHEN year = 2019 THEN cnt
    ELSE 0
END as count2019,
CASE 
	WHEN year = 2020 THEN cnt
    ELSE 0
END as count2020
FROM (
Select arrival_date_year as year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2018 group by 1,2
UNION
Select arrival_date_year as year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2019 group by 1,2
UNION
Select arrival_date_year as year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2020 group by 1,2) as temp) as temp2 
GROUP BY 1 ORDER BY 5;


-- ********************
-- 4th Question: When are people cancelling the most?
-- ********************

SELECT arrival_date_month,max(count2018) as count2018, max(count2019) as count2019 , max(count2020) as count2020, max(week_num) as week_num 
FROM 
(SELECT 
 arrival_date_month, week_num,
CASE 
	WHEN arrival_date_year = 2018 THEN cnt
    ELSE 0
END as count2018,
CASE 
	WHEN arrival_date_year = 2019 THEN cnt
    ELSE 0
END as count2019,
CASE 
	WHEN arrival_date_year = 2020 THEN cnt
    ELSE 0
END as count2020
FROM (
Select arrival_date_year, arrival_date_month, max(arrival_date_week_number) as week_num,count(*) as cnt from hotel2018 WHERE is_canceled = 1 group by 1,2 
UNION
Select arrival_date_year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2019 WHERE is_canceled = 1 group by 1,2
UNION
Select arrival_date_year, arrival_date_month, max(arrival_date_week_number) as week_num, count(*) as cnt from hotel2020 WHERE is_canceled = 1 group by 1,2) as temp) as temp2 
GROUP BY 1 ORDER BY 5;






-- ********************
-- 5th Question: Are families with kids more likely to cancel the hotel booking?
-- ********************

-- ADDING FAMILY and NON-FAMILY Flag
Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2018;
 
 -- FINDING total bookings by family flag
 SELECT family_flag, count(*) as total_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2018) as temp GROUP BY 1;
 
 -- FINDING total cancellation by family flag
  SELECT family_flag, count(*) as canceled_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2018) as temp WHERE is_canceled = 1 GROUP BY 1;
 
 
 -- FINDING % cancellation by Family Type
 SELECT 2018 as year_, totb.family_flag,  (canceled_bookings / total_bookings)*100 as percentage_cancel
 FROM 
 (SELECT family_flag, count(*) as total_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2018) as temp GROUP BY 1) as totb
 inner join 
 (
  SELECT family_flag, count(*) as canceled_bookings
 FROM (
 Select *, 
	CASE 
		WHEN (children + babies) > 0 THEN 'FAMILY'
		ELSE 'NON-FAMILY'
    END as family_flag
 from hotel2018) as temp WHERE is_canceled = 1 GROUP BY 1
 ) as cancelb ON totb.family_flag = cancelb.family_flag;
 
 
 