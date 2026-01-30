create database  music_store;

use music_store;

-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT ,
	name VARCHAR(120)
);

ALTER TABLE genre
ADD primary key (genre_id);

-- 2.MediaType
CREATE TABLE MediaType (
	media_type_id INT ,
	name VARCHAR(120)
);

ALTER TABLE MediaType
ADD primary key (media_type_id);


-- 3. Employee
CREATE TABLE Employee (
	employee_id INT ,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to INT ,
  levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);

ALTER TABLE Employee
ADD primary key (employee_id);


-- 4. Customer
CREATE TABLE Customer (
	customer_id INT ,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
);

ALTER TABLE customer
ADD primary key (customer_id);

-- 5. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);

-- 6. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);


-- 7. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);


-- 8. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);

-- 9. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

-- 10. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);

-- 11. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

-- ====== QUERIES ======================================================================================================


USE MUSIC_STORE;

-- 1. Who is the senior most employee based on job title? levelslevels
SELECT * FROM Employee
ORDER BY Levels DESC
LIMIT 1;

-- 2.Which countries have the most Invoices?
SELECT Billing_Country , COUNT(Invoice_Id)
FROM Invoice
GROUP BY Billing_Country
ORDER BY COUNT(Invoice_Id) DESC;

-- 3.What are the top 3 values of total invoice?
SELECT Total FROM Invoice 
ORDER BY Total DESC 
LIMIT 3;

-- 4.Which city has the best customers? - We would like to throw a 
-- promotional Music Festival in the city we made the most money. Write a query that 
-- returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
SELECT Billing_City ,SUM(TOTAL) AS INVOICE_TOTAL FROM invoice
GROUP BY Billing_City
ORDER BY SUM(TOTAL) DESC
LIMIT 1;

-- 5. Who is the best customer? - The customer who has spent the most money will be declared the best customer.
--  Write a query that returns the person who has spent the most money
SELECT Customer.Customer_Id, Customer.First_Name, Customer.Last_Name, SUM(Invoice.Total) AS TOTAL_SPENT
FROM Customer
INNER JOIN Invoice ON Customer.Customer_Id = Invoice.Customer_Id
GROUP BY Customer.Customer_Id
ORDER BY SUM(Invoice.Total) DESC
LIMIT 1
;

-- 6.Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A
SELECT DISTINCT Customer.Email, Customer.First_Name, Customer.Last_Name, Genre.Name AS GENRE
FROM Customer
INNER JOIN Invoice ON Customer.Customer_Id = Invoice.Customer_Id
INNER JOIN InvoiceLine ON Invoice.Invoice_Id = InvoiceLine.Invoice_Id
INNER JOIN Track ON InvoiceLine.Track_Id = Track.Track_Id
INNER JOIN Genre ON Track.Genre_Id = Genre.Genre_Id
WHERE Genre.Name = 'Rock'
ORDER BY Customer.email;

-- 7.  Let's invite the artists who have written the most rock music in our dataset.
--  Write a query that returns the Artist name and total track count of the top 10 rock bands 
SELECT Artist.Artist_Id, Artist.Name , COUNT(Track.Track_Id) AS TRACK_COUNT
FROM Artist
INNER JOIN Album ON Artist.Artist_Id = Album.Artist_Id
INNER JOIN Track ON Album.Album_Id = Track.Album_Id
INNER JOIN Genre ON Track.Genre_Id = Genre.Genre_Id
WHERE Genre.Name = 'Rock'
GROUP BY Artist.Artist_Id
ORDER BY TRACK_COUNT DESC
LIMIT 10;

-- 8. Return all the track names that have a song length longer than the average song length.
-- - Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
SELECT Name , Milliseconds
FROM Track
WHERE Milliseconds > (SELECT AVG(Milliseconds) FROM Track)
ORDER BY Milliseconds DESC;

-- 9. Find how much amount is spent by each customer on artists? Write a query to return customer name,
--  artist name and total spent 
SELECT 

CONCAT(Customer.First_Name, ' ', Customer.Last_Name) AS Customer_Name,
Artist.Name as Artist_Name,
SUM(InvoiceLine.Unit_Price * InvoiceLine.Quantity) AS Expenditure
FROM Customer
JOIN Invoice ON Customer.Customer_Id = Invoice.Customer_Id
JOIN InvoiceLine ON Invoice.Invoice_Id = InvoiceLine.Invoice_Id
JOIN Track ON Track.Track_Id = InvoiceLine.Track_Id
JOIN Album ON Album.Album_Id = Track.Album_Id
JOIN Artist ON Artist.Artist_Id = Album.Artist_Id
GROUP BY Customer.Customer_Id, Artist.Artist_Id
ORDER BY Customer_Name;


--  10.We want to find out the most popular music Genre for each country.
--  We determine the most popular genre as the genre with the highest amount of purchases.
--  Write a query that returns each country along with the top Genre. 
-- For countries where the maximum number of purchases is shared return all Genres
WITH Top_Genre_Per_Country AS (
SELECT 
Invoice.Billing_Country AS Country,
Genre.Name AS GenreName,
SUM(InvoiceLine.Unit_Price * InvoiceLine.Quantity) AS genre_total,
RANK() OVER (PARTITION BY Invoice.Billing_Country
ORDER BY SUM(InvoiceLine.Unit_Price * InvoiceLine.Quantity) DESC) AS rnk
FROM Genre
INNER JOIN Track ON Track.Genre_Id = Genre.Genre_Id
INNER JOIN InvoiceLine ON InvoiceLine.Track_Id = Track.Track_Id
INNER JOIN Invoice ON Invoice.Invoice_Id = InvoiceLine.Invoice_Id
GROUP BY Invoice.Billing_Country, Genre.Name
)
SELECT 
Country,
GenreName AS Most_Popular_Genre
FROM Top_Genre_Per_Country
WHERE rnk = 1
ORDER BY Country;


-- 11. Write a query that determines the customer that has spent the most on music for each country.
--  Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount

WITH Top_Customers_by_Country AS (
SELECT 
CONCAT(Customer.First_Name, ' ', Customer.Last_Name) AS Customer, 
Invoice.Billing_Country AS Country, 
SUM(Invoice.Total) AS Expenditure,
RANK() OVER (PARTITION BY Invoice.Billing_Country
ORDER BY SUM(Invoice.Total) DESC) AS Rnk
FROM Invoice
INNER JOIN Customer ON Customer.Customer_Id = Invoice.Customer_Id
GROUP BY Invoice.Billing_Country, Customer.Customer_Id, Customer
)
SELECT Country, Customer, Expenditure
FROM Top_Customers_by_Country
WHERE Rnk = 1
ORDER BY Country, Customer;
