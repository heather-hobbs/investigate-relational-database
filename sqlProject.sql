/*SLIDE ONE*/
/*QUERY 1: Question 1 - We want to understand more about the movies that families are watching. The following categories are considered family movies: Animation, Children, Classics, Comedy, Family and Music.
Create a query that lists each movie, the film category it is classified in, and the number of times it has been rented out.*/

WITH t1 AS
(SELECT f.title AS movie_title,
      c.name AS category_name,
      COUNT (r.rental_id) AS number_rented
  FROM rental r
    JOIN inventory i
    ON i.inventory_id=r.inventory_id
    JOIN film f
    ON f.film_id=i.film_id
    JOIN film_category fc
    ON f.film_id=fc.film_id
    JOIN category c
    ON c.category_id=fc.category_id
  GROUP BY f.title, c.name)

SELECT
  movie_title,
  category_name,
  number_rented
FROM t1
WHERE
    category_name='Animation' OR
    category_name='Children' OR
    category_name='Classics' OR
    category_name='Comedy' OR
    category_name='Family' OR
    category_name='Music'
ORDER BY 2, 1;

/*QUERY 2: Subsequent analysis to allow for visualization of the most and least popular family movie category. */
WITH t1 AS
(SELECT f.title AS movie_title,
    c.name AS category_name,
    COUNT (r.rental_id) AS number_rented
  FROM rental r
    JOIN inventory i
    ON i.inventory_id=r.inventory_id
    JOIN film f
    ON f.film_id=i.film_id
    JOIN film_category fc
    ON f.film_id=fc.film_id
    JOIN category c
    ON c.category_id=fc.category_id
  GROUP BY f.title, c.name)

SELECT
  category_name,
  SUM (number_rented)
FROM t1
WHERE
    category_name='Animation' OR
    category_name='Children' OR
    category_name='Classics' OR
    category_name='Comedy' OR
    category_name='Family' OR
    category_name='Music'
GROUP BY category_name;

/*SLIDE 2*/
/*QUERY 3: Question 2 - Can you provide a table with the movie titles and divide them into 4 levels (first_quarter, second_quarter, third_quarter, and final_quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies across all categories?*/
WITH t1 AS
(SELECT
    f.title AS movie_title,
    c.name AS category_name,
    f.rental_duration AS rental_duration,
    NTILE(4) OVER (ORDER BY rental_duration) AS quartile
  FROM film f
    JOIN film_category fc
    ON fc.film_id=f.film_id
    JOIN category c
    ON c.category_id=fc.category_id)

SELECT
    movie_title,
    category_name,
    rental_duration,
    quartile
FROM t1
WHERE
    category_name='Animation' OR
    category_name='Children' OR
    category_name='Classics' OR
    category_name='Comedy' OR
    category_name='Family' OR
    category_name='Music';

/*QUERY 4: Additional query to count the number of movies in each quartile*/
WITH t1 AS
(SELECT
    c.name AS category_name,
    f.rental_duration AS rental_duration,
    NTILE(4) OVER (ORDER BY rental_duration) AS quartile
  FROM film f
    JOIN film_category fc
    ON fc.film_id=f.film_id
    JOIN category c
    ON c.category_id=fc.category_id)

SELECT
      quartile,
      COUNT(quartile) AS number_in_quartile
FROM t1
WHERE
    category_name='Animation' OR
    category_name='Children' OR
    category_name='Classics' OR
    category_name='Comedy' OR
    category_name='Family' OR
    category_name='Music'
GROUP BY quartile;

/*SLIDE 3*/
/*QUERY 5: Question 3 - We want to find out how the two stores compare in their count of rental orders during every month for all the years we have data for*/
SELECT DATE_PART ('month', r.rental_date) AS month,
      DATE_TRUNC ('year', r.rental_date) AS year,
      s.store_id AS store_id,
      COUNT (r.rental_id)
FROM rental r
  JOIN staff s
  ON r.staff_id=s.staff_id
GROUP BY 1,2,3
ORDER BY 4 DESC;

/*SLIDE 4*/
/*QUERY 6: Question 4 - Who were the top 10 customers and how many monthly payments were made on a monthly basis in 2007 and what was the amount?*/
WITH t1 AS
(SELECT c.first_name || ' ' || c.last_name AS customer_name,
  SUM(p.amount) as total_payments
FROM customer c
  JOIN payment p
  ON p.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10)

SELECT DATE_TRUNC ('month', p.payment_date) AS payment_date,
      c.first_name || ' ' || c.last_name AS customer_name,
      COUNT(p.amount) AS payment_count,
      SUM(p.amount) AS payment_total
  FROM customer c
  JOIN payment p
  ON p.customer_id = c.customer_id
WHERE c.first_name || ' ' || c.last_name IN
(SELECT customer_name
  FROM t1) AND (p.payment_date BETWEEN '2007-01-01' AND '2008-01-01')
GROUP BY 2, 1
ORDER BY 2, 1, 3;

/*QUERY 7:Subsequent Analysis for the top 10 customers with total payments*/
SELECT c.first_name || ' ' || c.last_name AS customer_name,
  SUM(p.amount) as total_payments
FROM customer c
  JOIN payment p
  ON p.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
