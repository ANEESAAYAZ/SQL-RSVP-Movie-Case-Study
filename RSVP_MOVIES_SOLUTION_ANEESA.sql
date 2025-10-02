USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT table_name, table_rows from INFORMATION_SCHEMA.tables
WHERE TABLE_SCHEMA = 'imdb';

select count(*) from movie;
select count(*) from names;
select count(*) from director_mapping;
select count(*) from role_mapping;
select count(*) from genre;
select count(*) from ratings;



-- Q2. Which columns in the movie table have null values?
-- Type your code below:
desc movie;

select
	SUM(CASE WHEN ID is null THEN 1 ELSE 0 END) ID_NULL,
    SUM(CASE WHEN title is null THEN 1 ELSE 0 END) TITLE_NULL,
    SUM(CASE WHEN year is null THEN 1 ELSE 0 END) YEAR_NULL,
    SUM(CASE WHEN date_published is null THEN 1 ELSE 0 END) date_published_NULL,
    SUM(CASE WHEN country is null THEN 1 ELSE 0 END) country_NULL,
    SUM(CASE WHEN worlwide_gross_income is null THEN 1 ELSE 0 END) worlwide_gross_income_NULL,
    SUM(CASE WHEN languages is null THEN 1 ELSE 0 END) languages_NULL,
    SUM(CASE WHEN production_company is null THEN 1 ELSE 0 END) production_company_NULL
from
	movie;

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- first Part > total number of movies released each year

select 
	year,
    count(*) as no_of_movies
from
	movie
group by
	year;
-- Second Part >  trend look month wise    
select 
	month(date_published) as month,
    count(*) as no_of_movies
from 
	movie
group by 
	month(date_published)
ORDER BY
	month(date_published);








/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
select 
	country,
    year,
    count(*) as no_of_movies
from
	movie
where 	
	country in ('USA','India') 
	and year = 2019
group by country,year;









/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

select distinct genre from genre;









/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
select 
	mov.year,
	gen.genre,
    count(gen.movie_id) as no_of_movies
from
	genre gen
	left outer join 
		movie mov 
	on mov.id = gen.movie_id
group by mov.year,gen.genre
ORDER BY no_of_movies DESC;



/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
select count(*) from (select movie_id, count(*) from genre group by movie_id having count(*) = 1) Temp;

-- OR
with movies_with_one_genre as
(
	select 
		movie_id, 
        count(*) no_of_genres 
	from 
		genre 
	group by movie_id 
    having no_of_genres = 1
)
select 
	count(*) count_of_movies_with_one_genre
from 
	movies_with_one_genre;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

 
/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

select 
	gen.genre,
    avg(mov.duration) avg_duration
from 
	genre gen
    LEFT OUTER JOIN movie mov
    on mov.id = gen.movie_id
group by gen.genre



/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

with genre_rank as
(
	select
		genre,
		count(movie_id) as movie_count,
		RANK() OVER (ORDER BY count(movie_id) DESC) as genre_rank
	from
		genre
	GROUP BY genre
)
select * from genre_rank where genre = 'Thriller'
	
	
/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/

-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

select 
	min(avg_rating) as min_avg_rating,
	max(avg_rating) as max_avg_rating,
    min(total_votes) as min_total_votes,
    max(total_votes) as max_total_votes,
    min(median_rating) as min_median_rating,
    max(median_rating) as min_median_rating
from
	ratings;
    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
select 
	mov.title,
    rat.avg_rating,
    dense_rank() OVER(order by avg_rating DESC) as movie_rank
from
	movie mov
    inner join ratings rat 
		on rat.movie_id = mov.id
limit 10;

-- OR
WITH mobie_rank_avg_rating as
(
	select 
		mov.title,
		rat.avg_rating,
		rank() OVER(order by avg_rating DESC) as movie_rank
	from
		movie mov
		inner join ratings rat 
			on rat.movie_id = mov.id
)
select * from mobie_rank_avg_rating WHERE movie_rank <= 10;

    


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

select 
	median_rating,
    count(movie_id) as movie_count
from 
	ratings
group by 
	median_rating
order by 
	count(movie_id) DESC;


/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

select
	mov.production_company,
    count(rat.movie_id) as movie_count,
    dense_rank() OVER (ORDER BY count(rat.movie_id) DESC) as prod_company_rank
from 
	movie mov
    inner join ratings rat
		on rat.movie_id = mov.id
where 
	rat.avg_rating > 8
    -- I found there are null values in Production Company so adding below condition in where clause
    and mov.production_company is not null
group by 
	mov.production_company;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
select
	gen.genre,
    count(mov.id) as movie_count
from 
	genre gen
    inner join movie mov
		on mov.id = gen.movie_id
    inner join ratings rat
		on rat.movie_id = gen.movie_id
where 
	mov.year = 2017 and
    MONTH(mov.date_published) = 3 and
    mov.country like '%USA%' and
    rat.total_votes > 1000
group by gen.genre
order by count(mov.id) DESC;
    

-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
select 
	mov.title,
    rat.avg_rating,
    gen.genre
from
	movie mov
	inner join ratings rat
		on rat.movie_id = mov.id
	inner join genre gen
		on gen.movie_id = mov.id
where 
	mov.title like 'The%' and
	rat.avg_rating > 8
order by gen.genre;



-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
select * from movie;
with movie_rel_range as
(
	select
		mov.id,
        rat.median_rating
	from
		movie mov
        inner join ratings rat
			on rat.movie_id = mov.id
	where
		-- Date format is in YYYY-MM-DD
		mov.date_published between '2018-04-01' and '2019-04-01'
)
select count(*) as movie_count from movie_rel_range where median_rating = 8;

-- Another solution for 16
select
	rat.median_rating,
    count(mov.id) as movie_release_count
from
	movie mov
    inner join ratings rat
		on rat.movie_id = mov.id
where
	-- Date format is in YYYY-MM-DD
	mov.date_published between '2018-04-01' and '2019-04-01' and
    rat.median_rating = 8
group by 
	rat.median_rating;

-- Answer - 361 movies released between 1 April 2018 and 1 April 2019 with median ratings as 8
    

-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

-- Ricky > Did analysis with language first and answer was no
select 
	mov.languages,
    sum(rat.total_votes) as total_votes
from movie mov
	inner join ratings rat
		on rat.movie_id = mov.id
where 
	mov.languages in ('German','Italian')
group by 
	mov.languages;

-- Ricky > Analysing based on country and answer is yes

select 
	mov.country,
    sum(rat.total_votes) as total_votes
from movie mov
	inner join ratings rat
		on rat.movie_id = mov.id
where 
	mov.country in ('Germany','Italy')
group by 
	mov.country;


-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/


-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

select
    SUM(CASE WHEN name is null THEN 1 ELSE 0 END) name_nulls,
    SUM(CASE WHEN height is null THEN 1 ELSE 0 END) height_nulls,
    SUM(CASE WHEN date_of_birth is null THEN 1 ELSE 0 END) date_of_birth_nulls,
    SUM(CASE WHEN known_for_movies is null THEN 1 ELSE 0 END) known_for_movies_nulls
from
	names;



/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Ricky > From the hint identify top three genres would have the most number of movies with an average rating > 8.


with TOP_THREE_GENRES AS
(
	select 
		gen.genre,
		count(mov.id) as movie_count
	from 
		genre gen
		inner join movie mov
			on mov.id = gen.movie_id
		inner join ratings rat
			on rat.movie_id = mov.id
	where 
		avg_rating > 8
	group by 
		gen.genre
	order by count(mov.id) Desc
	LIMIT 3
)
select
	nam.name as director_name,
    count(mov.id) as movie_count
from
	movie mov
		inner join ratings rat
			on rat.movie_id = mov.id
		inner join genre gen
			on gen.movie_id = mov.id
		inner join director_mapping dir
			on dir.movie_id = mov.id
		inner join names nam
			on nam.id = dir.name_id
where
	rat.avg_rating > 8 and 
	gen.genre in (select genre from TOP_THREE_GENRES)
    
group by 
	nam.name
order by 
	count(mov.id)  DESC
Limit 3;

-- Another Solution for 19 by Aneesa
with top_genre as  
(
	select g.genre,
	count(g.movie_id) as movie_count
	from genre g
	inner join ratings r
	using(movie_id)
	where r.avg_rating>8
	group by g.genre
	order by count(g.movie_id) desc
    limit 3

),
top_director as
(
select n.name,
count(d.movie_id) as movie_count
from names n
inner join director_mapping d
on n.id=d.name_id
inner join ratings r
    using(movie_id)
inner join genre g
 on g.movie_id = d.movie_id,
top_genre
where r.avg_rating>8 and g.genre in (top_genre.genre)
group by n.name
order by count(d.movie_id) desc
)
select * from top_director td limit 3;




/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */

select 
	nam.name as actor_name,
    count(mov.id) as movie_count
from 
	movie mov
		inner join role_mapping rol
			on rol.movie_id = mov.id
		inner join names nam
			on nam.id = rol.name_id
		inner join ratings rat
			on rat.movie_id = mov.id
where
	rat.median_rating >= 8
    and rol.category = 'actor'
group by 
	nam.name
ORDER BY
	count(mov.id) DESC
limit 2;
	


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
select
	mov.production_company,
    sum(rat.total_votes) as vote_count,
	rank() OVER (ORDER BY sum(rat.total_votes) DESC) as prod_comp_rank
from
	movie mov
    inner join ratings rat
		on rat.movie_id = mov.id
group by 
	mov.production_company
order by 
	sum(rat.total_votes) Desc
Limit 3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
select 
	nam.name as actor_name,
    sum(rat.total_votes) as total_votes,
    count(mov.id) as movie_count,
    ROUND(sum(avg_rating * total_votes)/sum(total_votes),2) as actor_avg_rating,
    rank() over(weighted_avg) as actor_rank
from 
	movie mov
    inner join ratings rat
		on rat.movie_id = mov.id
	inner join role_mapping rol
		on rol.movie_id = mov.id
    inner join names nam
		on nam.id = rol.name_id
where
	mov.country = 'India' and
    rol.category = 'actor'
group by nam.name
having count(mov.id) >= 5
window weighted_avg as (order by ROUND(sum(avg_rating * total_votes)/sum(total_votes),2) DESC, sum(rat.total_votes) DESC);



-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
select 
	nam.name as actor_name,
    sum(rat.total_votes) as total_votes,
    count(mov.id) as movie_count,
    ROUND(sum(avg_rating * total_votes)/sum(total_votes),2) as actress_avg_rating,
    rank() over(weighted_avg) as actress_rank
from 
	movie mov
    inner join ratings rat
		on rat.movie_id = mov.id
	inner join role_mapping rol
		on rol.movie_id = mov.id
    inner join names nam
		on nam.id = rol.name_id
where
	mov.country = 'India' and
    rol.category = 'actress' and
    mov.languages like '%Hindi%'
group by nam.name
having count(mov.id) >= 3
window weighted_avg as (order by ROUND(sum(avg_rating * total_votes)/sum(total_votes),2) DESC, sum(rat.total_votes) DESC);


/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 
 
			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

select 
	mov.title movie_title,
    rat.avg_rating,
    Case 
		when rat.avg_rating > 8 then "Superhit movies"
        when rat.avg_rating between 7 and 9 then "Hit movies"
        when rat.avg_rating between 7 and 9 then "One-time-watch movies"
	ELSE
		"Flop movies"
	END as Rating
from movie mov
	inner join ratings rat 
		on rat.movie_id = mov.id
	inner join genre gen
		on gen.movie_id = mov.id
where 
	gen.genre = 'Thriller';
    


/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
select
	gen.genre,
    ROUND(avg(mov.duration),2) as avg_duration,
    SUM(avg(mov.duration)) OVER(ORDER BY gen.genre) AS running_total_duration,
    AVG(AVG(duration)) OVER(ORDER BY genre) AS moving_avg_duration
from 
	movie mov
    inner join genre gen
		on mov.id = gen.movie_id
group by
	gen.genre;

-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
With top_three_genre as
(
	select
		genre,
        count(movie_id) as movie_count
	from
		genre
	group by genre
    order by count(movie_id) Desc
    Limit 3
),
top_5_movie_year as
(
	select 
		gen.genre,
        mov.year,
        mov.title as mvie_name,
        mov.worlwide_gross_income,
        dense_rank() Over(w) as movie_rank
	from
		movie mov
        inner join genre gen
			on gen.movie_id = mov.id
	where
		gen.genre in (select genre from top_three_genre)
	window w as (partition by mov.year order by mov.worlwide_gross_income DESC)
)
select * from top_5_movie_year where movie_rank <=5;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

select 
	mov.production_company,
    count(mov.id) as movie_count,
    rank() over(order by  count(mov.id) DESC) as prod_comp_rank
from movie as mov
	inner join ratings rat
		on rat.movie_id = mov.id
where 
	mov.languages like '%,%' and
	rat.median_rating >= 8 and
    mov.production_company is not null
group by 
	mov.production_company
limit 2;

-- Another Solution

select 
	mov.production_company,
    count(mov.id) as movie_count,
    rank() over(order by  count(mov.id) DESC) as prod_comp_rank
from movie as mov
	inner join ratings rat
		on rat.movie_id = mov.id
where 
	POSITION(',' IN mov.languages)>0 and
	rat.median_rating >= 8 and
    mov.production_company is not null
group by 
	mov.production_company
limit 2;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
select 
	nam.name as actress_name,
	sum(rat.total_votes) as total_votes,
    count(mov.id) as movie_count,
    avg(rat.avg_rating) as actress_avg_rating,
    rank() over(order by count(mov.id) DESC) as actress_rank
from movie mov
	inner join genre gen
		on gen.movie_id = mov.id
	inner join ratings rat
		on rat.movie_id = mov.id
	inner join role_mapping rol
		on rol.movie_id = mov.id
	inner join names nam
		on nam.id = rol.name_id
where
	gen.genre = 'drama' and
    rat.avg_rating >8 and
    rol.category = 'actress'
group by 
	nam.name
limit 3;




/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

with CTE_NEXT_DATE AS
(
	select
		dir.name_id,
        nam.name,
        dir.movie_id,
        mov.duration,
        rat.avg_rating,
        rat.total_votes,
        mov.date_published,
        lead(mov.date_published,1) over(partition by dir.name_id order by mov.date_published,dir.movie_id) as next_date_published
	from
		director_mapping as dir
        inner join names as nam
			on nam.id = dir.name_id
		inner join movie as mov
			on mov.id = dir.movie_id
		inner join ratings as rat
			on rat.movie_id = dir.movie_id
),
CTE_SUMMARY as
(
	select
		*,
		datediff(next_date_published,date_published) as date_difference
	from
		CTE_NEXT_DATE
)
SELECT 
	name_id as director_id,
	name as director_name,
	COUNT(movie_id) AS number_of_movies,
	ROUND(AVG(date_difference),2) AS avg_inter_movie_days,
	ROUND(AVG(avg_rating),2) AS avg_rating,
	SUM(total_votes) AS total_votes,
	MIN(avg_rating) AS min_rating,
	MAX(avg_rating) AS max_rating,
	SUM(duration) AS total_duration
FROM 
	CTE_SUMMARY
GROUP BY 
	director_id
ORDER BY 
	COUNT(movie_id) DESC
limit 9;