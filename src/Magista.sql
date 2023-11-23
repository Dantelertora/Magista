use magist;

#How many orders are there in the dataset?
SELECT 
    COUNT(order_id)
FROM
    orders;
    
#Are orders actually delivered? 
SELECT 
    order_status, COUNT(order_id) AS quantity
FROM
    orders
GROUP BY
order_status;

#Is Magist having user growth?

SELECT YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp), (COUNT(order_id)) FROM orders
GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
ORDER BY YEAR(order_purchase_timestamp) ASC, MONTH(order_purchase_timestamp) ASC;

#How many products are there on the products table? 
SELECT COUNT(DISTINCT product_id) FROM products;

#Which are the categories with the most products?
SELECT COUNT(DISTINCT product_id), product_category_name FROM products
GROUP BY product_category_name
ORDER BY COUNT(product_ID) DESC;

#How many of those products were present in actual transactions?
SELECT COUNT(DISTINCT product_id) FROM order_items;


SELECT 
	count(DISTINCT product_id) AS n_products
FROM
	order_items;
    
#What’s the price for the most expensive and cheapest products?
SELECT o.price, p.product_id FROM order_items AS o
LEFT JOIN
products as p USING (product_id)
ORDER BY price DESC
LIMIT 1;

SELECT 
    MIN(price) AS cheapest, 
    MAX(price) AS most_expensive
FROM 
	order_items;
    
#What are the highest and lowest payment values? 
SELECT SUM(payment_value) FROM order_payments
GROUP BY order_id
ORDER BY SUM(payment_value) ASC
LIMIT 10;


SELECT payment_value FROM order_payments
ORDER BY payment_value DESC
LIMIT 1;

SELECT * FROM order_payments
ORDER BY order_id DESC;

#What categories of tech products does Magist have? 13
SELECT COUNT(DISTINCT p.product_id) AS "quantity per category", pc.product_category_name_english AS category FROM products AS p
LEFT JOIN
product_category_name_translation AS pc USING (product_category_name)
GROUP BY product_category_name_english
HAVING category IN ("computers", "computers_accesories", "electronics", "fixed_telephony", "tablets_printing_image", "telephony","watches_gifts");

#How many products of these tech categories have been sold
SELECT COUNT(DISTINCT o.product_id) FROM order_items AS o
LEFT JOIN
products AS p USING (product_id)
LEFT JOIN
product_category_name_translation AS pt USING(product_category_name)
WHERE pt.product_category_name_english IN ("computers", "computers_accesories", "electronics", "fixed_telephony", "tablets_printing_image", "telephony","watches_gifts")
;
SELECT COUNT(o.product_id) FROM order_items AS o;

#What’s the average price of the products being sold?
SELECT AVG(price) FROM order_items AS o
LEFT JOIN
products AS p USING (product_id)
LEFT JOIN
product_category_name_translation AS pt USING(product_category_name)
WHERE pt.product_category_name_english IN ("computers", "computers_accesories", "electronics", "fixed_telephony", "tablets_printing_image", "telephony","watches_gifts")
;

SELECT * FROM order_items;
#Are expensive tech products popular? 
SELECT COUNT(o.product_id) AS 'Product Count',
CASE
	WHEN price > 700 THEN 'Very expensive (>700 Eur)'
	WHEN price BETWEEN 500 AND 700 THEN 'Expensive (500 - 700 Eur)'
	WHEN price BETWEEN 300 AND 500 THEN 'Medium expensive (300 - 500 Eur)'
	WHEN price < 300 THEN 'Low price (< 300 Eur)'
END AS 'Price_category',
CASE
WHEN pt.product_category_name_english IN ("computers", "computers_accesories", "electronics", "fixed_telephony", "tablets_printing_image", "telephony") THEN 'Tech'
END AS 'Aux'
FROM order_items AS o
LEFT JOIN
products AS p USING (product_id)
LEFT JOIN
product_category_name_translation AS pt USING(product_category_name)
GROUP BY Price_category, Aux
HAVING AUX = 'Tech'
ORDER BY COUNT(o.product_id) DESC;

## In relation to the sellers:##
##How many months of data are included in the magist database?## 25
SELECT COUNT(DISTINCT MONTH(order_purchase_timestamp)) AS mes, YEAR(order_purchase_timestamp) AS año FROM orders
GROUP BY año;

#How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
(SELECT COUNT(s.seller_id) FROM sellers AS s
LEFT JOIN
order_items AS o USING (seller_id)
LEFT JOIN
products AS p USING (product_id)
LEFT JOIN
product_category_name_translation as pt USING (product_category_name)
WHERE pt.product_category_name_english IN ("audio", "cine_photo", "computers", "computers_accesories", "consoles_games", "electronics", "fixed_telephony", "music", "pc_gamer", "tablets_printing_image", "telephony","watches_gifts"))
UNION
(SELECT COUNT(s.seller_id) FROM sellers AS s
LEFT JOIN
order_items AS o USING (seller_id)
LEFT JOIN
products AS p USING (product_id)
LEFT JOIN
product_category_name_translation as pt USING (product_category_name));

#What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
SET @tech_sellers = (SELECT SUM(op.payment_value) AS earnings FROM order_payments AS op
LEFT JOIN
order_items AS oi USING (order_id)
LEFT JOIN
products AS p USING (product_id)
LEFT JOIN
product_category_name_translation as pt USING (product_category_name)
WHERE pt.product_category_name_english IN ("audio", "cine_photo", "computers", "computers_accesories", "consoles_games", "electronics", "fixed_telephony", "music", "pc_gamer", "tablets_printing_image", "telephony","watches_gifts"));

SET @total_sellers = (SELECT SUM(op.payment_value) AS earnings FROM order_payments AS op
INNER JOIN
order_items AS oi USING (order_id)
INNER JOIN
products AS p USING (product_id)
INNER JOIN
product_category_name_translation as pt USING (product_category_name));

SELECT @total_sellers, @tech_sellers, @tech_sellers / @total_sellers * 100 AS percentage;
;

#Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?;
SELECT SUM(o.price) FROM order_items AS o
LEFT JOIN
products AS p USING (product_id)
LEFT JOIN
product_category_name_translation AS pc USING(product_category_name)
WHERE pc.product_category_name_english IN ("audio", "cine_photo", "computers", "computers_accesories", "consoles_games", "electronics", "fixed_telephony", "music", "pc_gamer", "tablets_printing_image", "telephony","watches_gifts")
;

SELECT SUM(payment_value)/25 AS Sold_sum FROM order_payments
LEFT JOIN
order_items AS oi USING (order_id)
LEFT JOIN
sellers AS s USING (seller_id)
LEFT JOIN
products AS p USING (product_id)
LEFT JOIN
product_category_name_translation AS pt USING(product_category_name)
WHERE pt.product_category_name_english IN ("audio", "cine_photo", "computers", "computers_accesories", "consoles_games", "electronics", "fixed_telephony", "music", "pc_gamer", "tablets_printing_image", "telephony","watches_gifts")
GROUP BY s.seller_id
ORDER BY (SUM(payment_value)/25) DESC;
;

#In relation to the delivery time:
#What’s the average time between the order being placed and the product being delivered?
SELECT (SUM(DATEDIFF(order_delivered_customer_date , order_purchase_timestamp))/COUNT(order_id)) AS 'average days' FROM orders
;
#How many orders are delivered on time vs orders delivered with a delay?
(SELECT COUNT(order_id) FROM orders
WHERE order_estimated_delivery_date > order_delivered_customer_date)
UNION
(SELECT COUNT(order_id) FROM orders);

#Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT COUNT(order_id) FROM orders
WHERE order_estimated_delivery_date < order_delivered_customer_date
;

SELECT AVG(product_length_cm) * AVG(product_height_cm) * AVG(product_width_cm) FROM products
;

SELECT COUNT(p.product_id),
CASE
WHEN (p.product_length_cm * p.product_height_cm * p.product_width_cm) > 16000 THEN 'Big size'
WHEN (p.product_length_cm * p.product_height_cm * p.product_width_cm) BETWEEN 10000 AND 16000 THEN 'Medium size'
WHEN (p.product_length_cm * p.product_height_cm * p.product_width_cm) < 10000 THEN 'Small size'
END AS Product_size
FROM products AS p
LEFT JOIN
order_items AS oi USING (product_id)
LEFT JOIN
orders AS o USING (order_id)
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY Product_size;

SELECT COUNT(p.product_id),
CASE
WHEN p.product_weight_g > 3000 THEN 'Heavy product'
WHEN p.product_weight_g BETWEEN 1000 AND 3000 THEN 'Medium weight'
WHEN p.product_weight_g < 1000 THEN 'Light product'
END AS Product_weight
FROM products AS p
LEFT JOIN
order_items AS oi USING (product_id)
LEFT JOIN
orders AS o USING (order_id)
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY Product_weight;

SELECT AVG(product_weight_g) FROM products;
SELECT COUNT(order_id), order_status FROM orders
GROUP BY order_status
;

# ORDER REVIEWS
SELECT AVG(review_score) FROm order_reviews as ore
LEFT JOIN
order_items as oi USING (order_id)
LEFT JOIN
products as p USING (product_id)
LEFT JOIN
product_category_name_translation AS pc USING(product_category_name)
;
SELECT COUNT(DISTINCT order_id) FROM orders