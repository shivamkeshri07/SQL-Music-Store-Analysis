USE  music_database;

-- Q1: Who is the senior most employee based on job title?

SELECT employee_id,first_name, last_name, levels AS Senior_level
FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2: Which countries have the most Invoices?

SELECT billing_country, COUNT(*) AS Number_of_Invoices
FROM invoice
GROUP BY billing_country
ORDER BY Number_of_Invoices desc
LIMIT 1;

-- Q3: What are top 3 values of total invoice?

SELECT total AS Total_invoice 
FROM invoice
ORDER BY Total_invoice DESC
LIMIT 3;


-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the 
-- most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals


SELECT billing_city, SUM(total) AS invoice_totals 
FROM invoice
GROUP BY billing_city
ORDER BY invoice_totals DESC
LIMIT 1;

-- Q5: Who is the best customer? The customer who has spent the 
-- most money will be declared the best customer. Write a query that returns the person who has spent the most money.

SELECT customer.customer_id, customer.first_name, customer.last_name, SUM(invoice.total) AS total
FROM customer
JOIN invoice
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY total desc
LIMIT 1;

-- Question Set - 2

-- Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A


SELECT DISTINCT
customer.email, customer.first_name, customer.last_name, genre.name AS Genre
FROM customer
JOIN invoice
ON customer.customer_id = invoice.customer_id
JOIN invoice_line
ON invoice.invoice_id = invoice_line.invoice_id
JOIN track
ON invoice_line.track_id = track.track_id
JOIN Genre
ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
ORDER BY customer.email ASC;



-- Q2: Let's invite the artists who have written the most rock music in our dataset
--  Write a query that returns the Artist name and total track count of the top 10 rock bands

SELECT artist.name AS Artist_Name, COUNT(track.track_id) AS Total_track_count
FROM artist
JOIN album
ON artist.artist_id = album.artist_id
JOIN track
ON album.Album_id = track.album_id
JOIN genre
ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.name
ORDER BY Total_track_count DESC
LIMIT 10;

-- Q3: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name, milliseconds AS Song_length FROM Track
WHERE milliseconds > (SELECT avg(milliseconds) FROM Track)
ORDER BY Song_length DESC;


-- Question Set - 3

-- Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.

 
SELECT customer.customer_id, first_name, customer.last_name, artist.name AS Artist_Name, 
ROUND(SUM(invoice_line.unit_price*invoice_line.quantity),2) AS total_spend
FROM customer
JOIN invoice
ON customer.customer_id = invoice.customer_id
JOIN invoice_line
ON invoice.invoice_id = invoice_line.invoice_id
JOIN track
ON invoice_line.track_id = Track.track_id
jOIN album
ON track.album_id = album.Album_Id
JOIN artist
ON album.artist_id = artist.artist_id
GROUP BY customer.first_name, customer.last_name, artist.name,customer.customer_id
ORDER BY total_spend DESC;


-- Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.

-- Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */


WITH popular_genre AS (
SELECT COUNT(invoice_line.quantity) AS purchase, customer.country AS Country, genre.Name, genre.genre_id,
ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Row_No
FROM invoice_line
JOIN invoice
ON invoice_line.invoice_id = invoice.invoice_id
JOIN customer
ON invoice.customer_id = customer.customer_id
JOIN track
ON invoice_line.track_id = track.track_id
JOIN genre
ON track.genre_id = genre.genre_id
GROUP BY customer.country, genre.Name, genre.genre_id
ORDER BY COUNT(invoice_line.quantity) DESC, customer.country ASC
)
SELECT *FROM popular_genre
WHERE Row_No <=1;


-- Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH customer_with_country AS (
SELECT customer.customer_id, customer.first_name, customer.last_name, sum(total) AS Total_spend, 
invoice.billing_country, 
ROW_NUMBER() OVER(PARTITION BY invoice.billing_country ORDER BY SUM(total) desc) AS ROW_NO
FROM invoice
JOIN customer 
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country
ORDER BY SUM(total) DESC
)

SELECT * FROM customer_with_country
WHERE ROW_NO <=1;



