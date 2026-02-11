create schema customers;
__customers table__
CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(10),
    age INT,
    city VARCHAR(50),
    countrycustomers VARCHAR(50)
);

INSERT INTO customers VALUES
(1,'Aarav Sharma','Male',29,'Delhi','India'),
(2,'Neha Singh','Female',34,'Mumbai','India'),
(3,'Rahul Mehta','Male',41,'Bangalore','India'),
(4,'Priya Verma','Female',26,'Pune','India'),
(5,'Ankit Patel','Male',38,'Ahmedabad','India');

 __product table__
 
 CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

INSERT INTO products VALUES
(101,'iPhone 14','Electronics'),
(102,'Laptop','Electronics'),
(103,'Running Shoes','Fashion'),
(104,'Office Chair','Home'),
(105,'Smart Watch','Electronics');

order table

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders VALUES
(1001,1,'2024-01-05',75000),
(1002,2,'2024-01-12',45000),
(1003,1,'2024-02-10',32000),
(1004,3,'2024-02-18',90000),
(1005,4,'2024-03-01',15000),
(1006,1,'2024-03-15',52000),
(1007,2,'2024-03-20',28000);


orders item table

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items VALUES
(1,1001,101,1,75000),
(2,1002,102,1,45000),
(3,1003,105,1,32000),
(4,1004,101,1,75000),
(5,1004,104,1,15000),
(6,1005,103,1,15000),
(7,1006,102,1,52000),
(8,1007,105,1,28000);

revenue by month

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    SUM(total_amount) AS monthly_revenue
FROM orders
GROUP BY order_month
ORDER BY order_month;

top10 customers by lifetime value

SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS lifetime_value
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY 1,2
ORDER BY lifetime_value DESC
LIMIT 10;

repeat vs 1 time customers

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM orders
    GROUP BY customer_id
)
SELECT
    CASE 
        WHEN order_count > 1 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY 1;

average order value 

SELECT
    ROUND(SUM(total_amount) / COUNT(order_id), 2) AS avg_order_value
FROM orders;

revenue vy product category(joins+group)

SELECT
    p.category,
    SUM(oi.quantity * oi.price) AS category_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

customer retention rate 

WITH order_counts AS (
    SELECT
        customer_id,
        COUNT(order_id) AS orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    ROUND(
        COUNT(CASE WHEN orders > 1 THEN 1 END) * 100.0
        / COUNT(*), 2
    ) AS retention_rate_percentage
FROM order_counts;

Month-over-Month Revenue Growth (WINDOW FUNCTION)

WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY month
)
SELECT 
    month,
    revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) 
        / LAG(revenue) OVER (ORDER BY month) * 100, 
        2
    ) AS growth_percentage
FROM monthly_sales;

Rank Customers by Spend (RANK vs DENSE_RANK)

SELECT
    c.customer_name,
    SUM(o.total_amount) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS rank_by_spend,
    DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS dense_rank_by_spend
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name;

Pareto Analysis (Top 20% Customers → Revenue %)

WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(total_amount) AS revenue
    FROM orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY revenue DESC) AS revenue_bucket
    FROM customer_revenue
)
SELECT
    CASE 
        WHEN revenue_bucket = 1 THEN 'Top 20% Customers'
        ELSE 'Bottom 80% Customers'
    END AS customer_group,
    SUM(revenue) AS total_revenue
FROM ranked_customers
GROUP BY 1;

10 New vs Repeat Customers by Month (Advanced)

WITH first_order AS (
    SELECT
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
)
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    CASE
        WHEN o.order_date = f.first_order_date THEN 'New Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(DISTINCT o.customer_id) AS customer_count
FROM orders o
JOIN first_order f
    ON o.customer_id = f.customer_id
GROUP BY order_month, customer_type
ORDER BY order_month;







