select title
from albums;

select *
from invoices;

--Which countries have the most Invoices? Use the Invoice table to determine the countries that have the most invoices.
select BillingCountry,count(invoiceId)
from invoices
group by 1
order by 2 desc;

--Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns the 1 city that has the highest sum of invoice totals. Return both the city name and the sum of all invoice totals.
select BillingCity, max(total)
from invoices;

--Who is the best customer? The customer who has spent the most money will be declared the best customer. Build a query that returns the person who has spent the most money. 

select FirstName,LastName, invoices.CustomerId, sum(total)
from invoices
join customers
on customers.CustomerId = invoices.CustomerId
group by 3
order by 4 desc;

--Use your query to return the email, first name, last name, and Genre of all Rock Music listeners. Return your list ordered alphabetically by email address starting with A.

select Email, FirstName, LastName
from customers c
join invoices i
on c.CustomerId = i.CustomerId
Join invoice_items ii
on i.InvoiceId = ii.InvoiceId
join tracks t
on ii.TrackId = t.TrackId
join genres g
on t.GenreId = g.GenreId
where t.GenreId = 1
order by 1 asc;


--Who is writing the rock music? Now that we know that our customers love rock music, we can decide which musicians to invite to play at the concert.
---Let’s invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.
--You will need to use the Genre, Track , Album, and Artist tables.

select ar.Name, count(TrackId)
from artists ar
JOIN albums ab
on ab.ArtistId = ar.ArtistId
JOIN tracks t
on ab.AlbumId = t.AlbumId
JOIN genres g
on t.GenreId = g.GenreId
where t.GenreId = 1
order by 2 desc
limit 10;

-- First, find which artist has earned the most according to the InvoiceLines? 
-- Now use this artist to find which customer spent the most on this artist.
-- For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, Album, and Artist tables.
-- Notice, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
-- so you need to use the InvoiceLine table to find out how many of each product was purchased, 
-- and then multiply this by the price for each artist.
with artistandearnings as (
select ar.ArtistId,tr.TrackId,sum(ii.UnitPrice*ii.Quantity) as track_earning
from tracks tr join albums ab on tr.AlbumId = ab.AlbumId 
join artists ar on ab.ArtistId = ar.ArtistId
join invoice_items ii on ii.TrackId = tr.TrackId
group by 1,2
) select ArtistId,sum(track_earning) as total_earnings from artistandearnings group by ArtistId order by 2 desc;

select c.CustomerId, c.FirstName||' '||c.LastName as customer_name, ii.TrackId, sum(ii.UnitPrice*ii.Quantity) as track_spend
from customers c JOIN invoices i on c.CustomerId = i.CustomerId
join invoice_items ii on i.InvoiceId = ii.InvoiceId
group by 1,2,3 order by 4 desc),
arttrack as (
select ar.ArtistId,ar.Name,tr.TrackId
from tracks tr join albums ab on tr.AlbumId = ab.AlbumId 
join artists ar on ab.ArtistId = ar.ArtistId),
artearning as (
select ArtistId, sum(track_earning) as total_earnings from (
select ar.ArtistId,tr.TrackId,sum(ii.UnitPrice*ii.Quantity) as track_earning
from tracks tr join albums ab on tr.AlbumId = ab.AlbumId 
join artists ar on ab.ArtistId = ar.ArtistId
join invoice_items ii on ii.TrackId = tr.TrackId
group by 1,2) group by ArtistId order by 2 desc limit 1)
select cs.CustomerId,cs.customer_name,at.ArtistId,at.name,sum(track_spend) as total_sepnt
from custspending cs join arttrack at on cs.TrackId = at.TrackId
join artearning ae on at.ArtistId=ae.ArtistId
group by 1,2,3,4 order by 5 desc limit 1;

--Count how many songs base on genre does customer 12 bought
select g.name,count(ii.trackid)
from invoices i join invoice_items ii on i.InvoiceId = ii.InvoiceId and  i.CustomerId = 12
join tracks t on ii.TrackId = t.TrackId 
join genres g on t.GenreId = g.GenreId
group by 1
order by 2 desc, 1 asc;

--How much did customer 13 spent across genres?
select g.name, sum(ii.UnitPrice*ii.Quantity) as total_spent
from invoices i join invoice_items ii on i.InvoiceId = ii.InvoiceId and  i.CustomerId = 13
join tracks t on ii.TrackId = t.TrackId 
join genres g on t.GenreId = g.GenreId
group by 1
order by 2 desc ;

--How much did each customers spent per genre
select c.FirstName|| ' ' ||c.LastName as c_name, g.name, sum(ii.UnitPrice*ii.Quantity) as total_spent
from invoices i join invoice_items ii on i.InvoiceId = ii.InvoiceId
join tracks t on ii.TrackId = t.TrackId 
join genres g on t.GenreId = g.GenreId
join customers c on c.CustomerId = i.CustomerId
group by 1,2
order by 1,3 desc,2 ;

-- How much did each customers spent per genre, each customer should be shown once and genres in adjusant columns
select DISTINCT name from genres;
-- Rock, Jazz, Metal, Latin, Blues
select c_name,Rock,Jazz,Metal,Latin,Blues from (

select c.FirstName|| ' ' ||c.LastName as c_name,
CASE when g.name = 'Rock' then sum(ii.UnitPrice*ii.Quantity) End as Rock,
CASE when g.name = 'Jazz' then sum(ii.UnitPrice*ii.Quantity) End as Jazz,
CASE when g.name = 'Metal' then sum(ii.UnitPrice*ii.Quantity) End as Metal,
CASE when g.name = 'Latin' then sum(ii.UnitPrice*ii.Quantity) End as Latin,
CASE when g.name = 'Blues' then sum(ii.UnitPrice*ii.Quantity) End as Blues
from invoices i join invoice_items ii on i.InvoiceId = ii.InvoiceId
left join tracks t on ii.TrackId = t.TrackId 
join genres g on t.GenreId = g.GenreId
join customers c on c.CustomerId = i.CustomerId
--group by 1,2,3,4,5,6 order by 1

) temp
group by 1,2,3,4,5,6;

with invit_gen as(
select c.customerId, g.name as genre ,sum(ii.UnitPrice*ii.Quantity) as cost
from customers c left join invoices i on c.CustomerId = i.CustomerId
left join invoice_items ii on i.InvoiceId = ii.InvoiceId left join tracks t on ii.TrackId = t.TrackId 
left join genres g on t.GenreId = g.GenreId
where c.CustomerId in (1,2,3,12)
group by genre
),
cust_gen as (
select customerid
,CASE when genre = 'Rock' then cost End as Rock
,CASE when genre = 'Jazz' then cost End as Jazz
,CASE when genre = 'Metal' then cost End as Metal
,CASE when genre = 'Latin' then cost  End as Latin
,CASE when genre = 'Blues' then cost End as Blues
from invit_gen)
select * from cust_gen;

--How much did Americans spent total?

select i.BillingCountry, sum(i.total)
from invoices i
where Billingcountry = 'USA';
