-- who is the senior most employee based on job title?

select * from employee
order by levels desc

-- which countries have the most invoices?

select count(invoice.invoice_id)as count_of_invoices, invoice.billing_country
from invoice
group by invoice.billing_country
order by count_of_invoices desc

--what are top 3 values of total invoice

select invoice.total as top_3 from invoice
order by top_3 desc
limit 3



--which city have the best customers we would like to throw a promotional music festival in the city we made the 
--most money write a query that returns one city that has the highest sum of invoice totals return both the city name
--&sum of invoice totals return both the city name & sum of all invoice totals

select billing_city,sum (total) as invoice_total from invoice
group by billing_city
order by sum(total) desc
limit 1


--who is the best customer the customer who has spent the most money will be declared the best customer write a query
--that returns the person who has spent the most money

select customer.customer_id,customer.first_name, customer.last_name,sum (invoice.total) as total_spend
from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2,3
order by 4 desc
limit 1


--Q.1 Write query to return the email, first name, last name & Genre of all Rock Music
--listners Return your list ordered alphabetically by email starting with A

select distinct email, first_name, last_name
from customer
Join invoice on customer.customer_id = invoice.customer_id
Join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name like 'Rock'
)
order by email;

--let's invite the artist who have written the most rock music in our dataset
--write a query that returns the artist name and total track count of the top 10 rock bands

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_songs
from track
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

--Return all the track names that have a song length longer than the average song length
--Return the name and miliseconds for each track. Order by the song length with the longest
--song listed first

select track.name, track.milliseconds 
from track
where milliseconds >(
	select avg(milliseconds) as avg_track_length
	from track)
order by milliseconds desc

--Q1. find how much amount spent by each customer on best selling artist write a query to return 
---customer name, artist name and total spend

with best_selling_artist as(
	select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spend
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

--We want to find out the most popular music genre for each country
--we determine the most popular genre as the genre with the highest amount of purchases

with popular_genre as
(
	select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
	Row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where rowno <= 1

--write the query that determine the customer that has spent the most on music for each country
--write a query that returns the country along with the top customer and how much they spend
--for countries where the top amount spent is shared, provide all customer who spent this amount

with recursive
	customer_with_country as(
		select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 1,5 desc
	),
	
	country_max_spending as(
		select billing_country,max(total_spending) as max_spending
		from customer_with_country
		group by billing_country)
select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
order by 1
	
