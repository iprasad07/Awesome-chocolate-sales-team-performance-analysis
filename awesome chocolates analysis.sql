USE awesomechocolates;
-- which category made the highest sales 
CREATE VIEW _sales_by_category AS
SELECT 
    pd.category AS product_category,
    SUM(s.amount) AS total_amount
FROM products AS pd
JOIN sales AS s ON s.pid = pd.pid
GROUP BY product_category
ORDER BY total_amount DESC;

-- total amount by each sales person 
CREATE VIEW _sales_by_salesperson AS
select pe.salesperson as salesperson, sum(s.amount) as total_amount from sales as s
join people as pe on pe.SPID=s.SPID
group by salesperson
order by total_amount desc;

-- which region has the heighest total sales 
create view sales_per_region as 
select g.region as region, sum(s.amount) as total_amount from sales as s
join geo as g on G.geoiD = s.GeoID
group by region
order by total_amount desc;

-- top 5 products 
create view top_5_products as
select pr.product as products, sum(s.amount) as total_amount from sales as s
join products as pr on pr.pid = s.pid
group by pr.Product
order by total_amount desc
limit 5;

-- total no of boxes per category 
create view no_of_boxes_by_category as 
select pr.category as category, count(s.boxes) as no_of_boxes from sales as s
join products as pr on pr.pid = s.pid
group by category
order by no_of_boxes desc;

-- which product category perfrom best in each region 
create view best_performed_product_category as 
WITH ranked_sales AS (
    SELECT 
        g.region,
        pr.category,
        SUM(s.amount) AS total_amount,
        RANK() OVER (PARTITION BY g.region ORDER BY SUM(s.amount) DESC) AS rnk
    FROM sales AS s
    JOIN products AS pr ON pr.pid = s.pid
    JOIN geo AS g ON g.geoid = s.geoid
    GROUP BY g.region, pr.category
)
SELECT 
    region,
    category AS best_category,
    total_amount AS highest_sales
FROM ranked_sales
WHERE rnk = 1
ORDER BY region;

-- remaining amount after expenses (amount - ( boxes * cost per box )) 
create view remaining_money as 
select pr.category as category, sum(s.amount) as total_amount, round((sum(s.amount)-(sum(s.boxes*pr.cost_per_box))),2) as remaining_amount from sales as s
join products as pr on pr.pid=s.pid
group by category
order by remaining_amount desc;

-- list the top 3 products sizes in terms of boxes sold
create view top_3_products_by_boxes_sold as 
select pr.Product as products, pr.Size as product_size ,sum(s.boxes) as total_box_sales from sales as s
join products as pr on pr.pid = s.pid
group by products, product_size
order by total_box_sales desc
limit 3;

-- which sales person generated the highest returns 
create view top_5_salespersons as
select pe.salesperson as salesperson, sum(s.amount) as total_amount from sales as s 
join people as pe on pe.spid = s.spid
group by salesperson 
order by total_amount desc 
limit 5;

-- top 10 salesperson who made more than the average boxes per location 
create view 10_salespeersons_made_more_money_then_avg as 
SELECT 
    pe.salesperson AS salesperson, 
    g.geo AS location, 
    SUM(s.boxes) AS total_boxes
FROM sales AS s
JOIN people AS pe ON pe.spid = s.spid
JOIN geo AS g ON g.GeoID = s.GeoID
GROUP BY pe.spid, g.GeoID
HAVING total_boxes > (
    SELECT AVG(s1.boxes)
    FROM sales AS s1
    WHERE s1.GeoID = g.GeoID
)
ORDER BY g.geo, total_boxes DESC
limit 10;

-- which region has highest no of customer served 
create view highest_customers_per_regin as 
select g.region as region, sum(s.customers) as customers from sales as s
join geo as g on g.GeoID=s.GeoID
group by region 
order by customers desc ;




