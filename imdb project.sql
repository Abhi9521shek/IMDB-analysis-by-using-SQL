
-- Segment 1: Database - Tables, Columns, Relationships
-- A. What are the different tables in the database and how are they connected to each other in the database?
use imdb;
SHOW tables; -- 6 different tables and connection is many to one by observing ER diagrams

-- B. Find the total number of rows in each table of the schema.
select count(*) as total_row from director_mapping; -- 3867
select count(*) as total_row from genre; -- 14663
select count(*) as total_row from movie; -- 7997
select count(*) as total_row from names; -- 25735
select count(*) as total_row from ratings; -- 7997
select count(*) as total_row from role_mapping; -- 15615

-- C. Identify which columns in the movie table have null values.
SELECT 
  COUNT(CASE WHEN id IS NUll THEN 1 END) AS id_null_check,
  COUNT(CASE WHEN title IS NULL then 1 END) AS title_null_check,
  COUNT(CASE WHEN year is null THEN 1 END) AS year_null_check,
  COUNT(CASE WHEN date_published is null THEN 1 END) AS dp_null_check,
  COUNT(CASE WHEN duration is null THEN 1 END) AS duration_null_check,
  COUNT(CASE WHEN country is null THEN 1 END) AS country_null_check,
  COUNT(CASE WHEN worlwide_gross_income is null THEN 1 END) AS wgi_null_check,
  COUNT(CASE WHEN languages is null THEN 1 END) AS languages_null_check,
  COUNT(CASE WHEN production_company is null THEN 1 END) AS pc_null_check
FROM movie;

-- ---------------------------------------------------------------------------------------------------------------------------------------

-- Segment 2: Movie Release Trends

-- A. Determine the total number of movies released each year and analyse the month-wise trend.
SELECT 
    YEAR(date_published) AS release_year,
    MONTH(date_published) AS release_month,
    COUNT(*) AS movie_count
FROM
    movie
GROUP BY
    release_year, release_month
ORDER BY
    release_year, release_month;

-- OR 

SELECT year,
SUM(title) total_movie 
FROM movie 
group by year;

SELECT month(date_published) as month_wise, 
sum(title) AS total_movie 
FROM movie 
GROUP BY month_wise 
ORDER BY total_movie desc;

-- B. Calculate the number of movies produced in the USA or India in the year 2019.
SELECT COUNT(title) as total_movies
 FROM movie WHERE (year = '2019') 
 AND 
 (country = 'India' OR country = 'USA');

-- ----------------------------------------------------------------------------------------------------------------------------------------

-- Segment 3: Production Statistics and Genre Analysis
-- A. Retrieve the unique list of genres present in the dataset.
SELECT DISTINCT(genre) 
FROM genre;

-- B. Identify the genre with the highest number of movies produced overall.
SELECT g.genre ,
COUNT(m.title) as movie_count 
from movie m 
join genre g 
on m.id= g.movie_id 
GROUP BY g.genre
ORDER BY movie_count DESC LIMIT 1;

-- C. Determine the count of movies that belong to only one genre.
WITH count_info as
( 
	SELECT m.title, 
	count(g.genre) as genre_count 
	from movie m 
	join genre g 
	on m.id= g.movie_id 
	group by m.title  
	having genre_count = 1
)
SELECT COUNT(*) AS movie_count 
FROM count_info; 

-- D. Calculate the average duration of movies in each genre.
SELECT genre, AVG(duration) AS average_duration
FROM movie
JOIN genre ON movie.id = genre.movie_id
GROUP BY genre;

-- E. Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
WITH info AS
(
	SELECT g.genre , 
	COUNT(m.title) as movie_count,
    row_number() over(order by COUNT(m.title) DESC) as n_rank 
	from movie m 
	join genre g 
	on m.id= g.movie_id 
	GROUP BY g.genre
)
SELECT *
FROM info
WHERE genre = 'Thriller';

--             OR
WITH info AS 
(
	SELECT GENRE,COUNT(MOVIE_ID) as MOVIE_COUNT,
	DENSE_RANK() OVER (ORDER BY COUNT(genre.movie_id) DESC) AS genre_rank
	FROM movie
	JOIN genre ON movie.id = genre.movie_id
	GROUP BY genre
)
SELECT *
FROM info 
WHERE GENRE = 'Thriller';
-- -----------------------------------------------------------------------------------------------------------------------------------------
-- Segment 4: Ratings Analysis and Crew Members
-- A. Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
SELECT MIN(avg_rating) AS min_avg_rating,
MAX(avg_rating) AS max_avg_rating,
MIN(total_votes) AS min_total_votes,
MAX(total_votes) AS max_total_votes,
MIN(median_rating) AS min_median_rating,
MAX(median_rating) AS max_median_rating 
FROM ratings;

-- B. Identify the top 10 movies based on average rating.
SELECT m.title,r.avg_rating 
FROM movie m 
JOIN ratings r 
ON m.id=r.movie_id 
ORDER BY r.avg_rating DESC LIMIT 10;

-- C. Summarise the ratings table based on movie counts by median ratings.
SELECT r.median_rating , 
COUNT(m.title) AS movie_count 
FROM movie m 
JOIN ratings r 
ON m.id=r.movie_id 
GROUP BY r.median_rating
ORDER BY movie_count DESC;

--               OR
SELECT median_rating, COUNT(movie_id) AS movie_count
FROM ratings
GROUP BY median_rating
ORDER BY movie_count DESC;

-- D. Identify the production house that has produced the most number of hit movies (average rating > 8).
SELECT m.production_company, 
COUNT(m.title) as movie_count 
FROM movie m 
JOIN ratings r 
ON m.id=r.movie_id 
WHERE r.avg_rating > 8
GROUP BY m.production_company
ORDER BY movie_count DESC;

-- E. Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.
SELECT g.genre,
COUNT(m.title) as movie_count 
from movie m 
join genre g 
on m.id = movie_id
join ratings r 
on m.id =  r.movie_id 
WHERE 	(m.date_published BETWEEN '2017-03-01' AND '2017-03-31')
		AND (m.country = 'USA') 
        AND (r.total_votes > 1000)
GROUP BY genre
ORDER BY movie_count DESC;

-- OR 

SELECT genre.genre, COUNT(movie.id) AS movie_count
FROM movie
JOIN genre ON movie.id = genre.movie_id
JOIN ratings ON movie.id = ratings.movie_id
WHERE movie.country = 'USA'
  AND YEAR(movie.date_published) = 2017
  AND MONTH(movie.date_published) = 3
  AND ratings.total_votes > 1000
GROUP BY genre.genre
ORDER BY movie_count DESC;

-- F. Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.
SELECT g.genre,
COUNT(m.title) as movie_count 
from movie m 
join genre g 
on m.id = movie_id
join ratings r 
on m.id =  r.movie_id 
WHERE (m.title LIKE 'The%') AND r.avg_rating>8
GROUP BY genre;



-- ---------------------------------------------------------------------------------------------------------------------------------------

-- Segment 5: Crew Analysis
-- A. Identify the columns in the names table that have null values.
SELECT 
  COUNT(CASE WHEN id IS NUll THEN 1 END) AS id_null_check,
  COUNT(CASE WHEN name IS NULL then 1 END) AS name_null_check,
  COUNT(CASE WHEN height is null THEN 1 END) AS height_null_check,
  COUNT(CASE WHEN date_of_birth is null THEN 1 END) AS dob_null_check,
  COUNT(CASE WHEN known_for_movies is null THEN 1 END) AS kfm_null_check
  FROM names;
  
  
-- B.Determine the top three directors in the top three genres with movies having an average rating > 8.
SELECT genre.genre AS top_genre, avg(ratings.avg_rating) AS highest_rated, names.name AS director_name
FROM movie
INNER JOIN ratings ON movie.id = ratings.movie_id
INNER JOIN genre ON genre.movie_id = movie.id
INNER JOIN director_mapping ON movie.id = director_mapping.movie_id
INNER JOIN names ON names.id = director_mapping.name_id
WHERE ratings.avg_rating > 8
GROUP BY top_genre, director_name
ORDER BY highest_rated DESC
LIMIT 3;


-- C. Find the top two actors whose movies have a median rating >= 8.
select rm.name_id 
from role_mapping rm 
JOIN ratings r 
ON rm.movie_id= r.movie_id 
WHERE r.median_rating>=8
ORDER BY median_rating DESC 
LIMIT 2;

-- D. Identify the top three production houses based on the number of votes received by their movies.
SELECT m.production_company
FROM movie m 
JOIN ratings r 
ON m.id = r.movie_id
ORDER BY r.total_votes DESC 
LIMIT 3;
 
-- E. Rank actors based on their average ratings in Indian movies released in India.

SELECT rm.name_id,
ROW_NUMBER() OVER(ORDER BY r.avg_rating DESC) AS actors_ranking
FROM role_mapping rm
JOIN movie m 
ON m.id=rm.movie_id
JOIN ratings r 
ON r.movie_id = m.id
WHERE m.country = 'India';

-- F. Identify the top five actresses in Hindi movies released in India based on their average ratings
SELECT rm.name_id
FROM role_mapping rm
JOIN movie m 
ON m.id=rm.movie_id
JOIN ratings r 
ON r.movie_id = m.id
WHERE m.country = 'India'
AND rm.category='actress'
ORDER BY r.avg_rating DESC LIMIT 5;

-- ----------------------------------------------------------------------------------------------------------------------------------------
-- Segment 6: Broader Understanding of Data

-- A. Classify thriller movies based on average ratings into different categories.
SELECT g.movie_id,
CASE 
WHEN r.avg_rating >8.5 THEN 'Excellent movie'
WHEN r.avg_rating >7.5 THEN 'Very Good movie'  
WHEN r.avg_rating > 6.5 THEN 'Good movie' 
ELSE 'Average or Below'
END as movie_category
    
FROM genre g 
JOIN ratings r
ON g.movie_id= r.movie_id 
WHERE g.genre = 'Thriller';

-- B. analyse the genre-wise running total and moving average of the average movie duration.
							-- CONCEPT USED
							-- select *,	
							-- sum(age) 	over (partition by name order by name) as new_sum,
							-- avg(age)	over (partition by name order by name) as new_age
							-- from t20;
select g.genre,	
sum(m.duration)	over (partition by g.genre order by m.title) as new_duration,
avg(m.duration)  over(partition by g.genre order by m.title) as new_avg
FROM movie m 
JOIN genre g
ON m.id = g.movie_id;	





-- C. Identify the five highest-grossing movies of each year that belong to the top three genres.
WITH top_three_genres AS (
    SELECT genre, COUNT(*) AS movie_count
    FROM genre
    GROUP BY genre
    ORDER BY movie_count DESC
    LIMIT 3
),
highest_grossing_movies AS (
    SELECT m.year, m.title, m.worlwide_gross_income, g.genre,
           ROW_NUMBER() OVER (PARTITION BY m.year, g.genre ORDER BY m.worlwide_gross_income DESC) AS `rank`
    FROM movie m
    INNER JOIN genre g ON m.id = g.movie_id
    INNER JOIN top_three_genres t ON g.genre = t.genre
)
SELECT year, genre, title, worlwide_gross_income
FROM highest_grossing_movies
WHERE `rank` <= 5
ORDER BY year, genre, `rank`;

-- D. Determine the top two production houses that have produced the highest number of hits among multilingual movies.
WITH hit_movies AS (
    SELECT m.production_company, COUNT(*) AS hit_count
    FROM movie m
    INNER JOIN ratings r ON m.id = r.movie_id
    WHERE r.avg_rating >= 7.0
    AND m.production_company IS NOT NULL
    GROUP BY m.production_company
),
top_production_houses AS (
    SELECT production_company, hit_count
    FROM hit_movies
    ORDER BY hit_count DESC
    LIMIT 2
)
SELECT production_company, hit_count
FROM top_production_houses;

-- E. Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.
SELECT name 
FROM names
WHERE id IN
(
	SELECT rm.name_id 
	FROM role_mapping rm
	JOIN ratings r
	ON r.movie_id = rm.movie_id 
	JOIN genre g 
	ON g.movie_id = rm.movie_id
	WHERE (r.avg_rating > 8) AND (g.genre = 'drama') AND rm.category = 'actress'
	ORDER BY r.avg_rating DESC 
)LIMIT 2;

-- F. Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.
WITH director_movie_count AS (
    SELECT dm.name_id, nm.name, COUNT(*) AS movie_count
    FROM director_mapping dm
    INNER JOIN names nm ON dm.name_id = nm.id
    GROUP BY dm.name_id, nm.name
),
director_average_duration AS (
    SELECT dm.name_id, AVG(m.duration) AS average_duration
    FROM director_mapping dm
    INNER JOIN movie m ON dm.movie_id = m.id
    GROUP BY dm.name_id
),
director_total_ratings AS (
    SELECT dm.name_id, SUM(r.total_votes) AS total_votes
    FROM director_mapping dm
    INNER JOIN ratings r ON dm.movie_id = r.movie_id
    GROUP BY dm.name_id
),
ranked_directors AS (
    SELECT dmc.name_id, dmc.name, dmc.movie_count, ad.average_duration, tr.total_votes,
           ROW_NUMBER() OVER (ORDER BY dmc.movie_count DESC) AS `rank`
    FROM director_movie_count dmc
    LEFT JOIN director_average_duration ad ON dmc.name_id = ad.name_id
    LEFT JOIN director_total_ratings tr ON dmc.name_id = tr.name_id
)
SELECT name, movie_count, average_duration, total_votes
FROM ranked_directors
WHERE `rank` <= 9;
--   OR
SELECT  NM.NAME AS DIRECTOR_NAME,
COUNT(*) AS TOTAL_MOVIE,
AVG(M.DURATION) AS AVG_DURATION, 
AVG(R.AVG_RATING) AS AVGR,
SUM(R.TOTAL_VOTES) AS TOTAL_VOTES

FROM DIRECTOR_MAPPING DM
JOIN NAMES NM ON DM.NAME_ID = NM.ID
JOIN RATINGS R ON DM.MOVIE_ID = R.MOVIE_ID
JOIN MOVIE M ON DM.MOVIE_ID = M.ID
GROUP BY NAME
ORDER BY TOTAL_MOVIE DESC 
LIMIT 9;


/*  Segment 7: Recommendations
Based on the analysis, provide recommendations for the types of content Bolly Movies should focus on producing.
*/

/* Ans: Based on the Analysis of the IMBd Movies, the recommendations for the types of content Bolly Movies should focus on producing is:-

          1. The 'Triller' genre has caught the highest attention and interest amongst the audience as the amount of 'Thriller' movies watched is good,
	         so the Bollywood movie production houses should keep their interest towards producing more 'Thriller' genre movies. 
       
          2. The 'Drama' genre has gained the overall average highest IMDb rating by the audience, so the Bollywood movies production houses 
             should focus more on producing quality content movies in the 'Drama' genre as they have been doing.
       
          3. The Bollywood movie production houses should also focus on producing good quality movies in other genres as well for the 
             growth of the bollywood movie industry.
*/

------- Extra Questions:

----- Q1. Determine the average duration of movies released by Bolly Movies compared to the industry average.

WITH hindi_movies_average_duration AS (
    SELECT AVG(duration) AS hindi_average
    FROM movie
    WHERE languages LIKE '%Hindi%'
),
other_languages_average_duration AS (
    SELECT AVG(duration) AS other_languages_average
    FROM movie
    WHERE languages NOT LIKE '%Hindi%'
)
SELECT hindi_average, other_languages_average
FROM hindi_movies_average_duration, other_languages_average_duration;

----- option 2

SELECT
    AVG(CASE WHEN languages LIKE '%Hindi%' THEN duration END) AS hindi_average,
    AVG(CASE WHEN languages NOT LIKE '%Hindi%' THEN duration END) AS other_languages_average
FROM movie
WHERE duration IS NOT NULL;


----- Q2. Query to analyze the correlation between the number of votes and the average rating for movies produced in Hindi
WITH hindi_movie_stats AS (
    SELECT
        AVG(r.total_votes) AS avg_votes,
        AVG(r.avg_rating) AS avg_rating
    FROM movie m
    INNER JOIN ratings r ON m.id = r.movie_id
    WHERE m.languages LIKE '%Hindi%'
    AND r.total_votes IS NOT NULL
    AND r.avg_rating IS NOT NULL
)
SELECT
    avg_votes AS average_votes,
    avg_rating AS average_rating,
    (SUM((r.total_votes - avg_votes) * (r.avg_rating - avg_rating)) / COUNT(*)) /
    (SQRT(SUM(POW(r.total_votes - avg_votes, 2)) / COUNT(*)) * SQRT(SUM(POW(r.avg_rating - avg_rating, 2)) / COUNT(*))) AS correlation
FROM movie m
INNER JOIN ratings r ON m.id = r.movie_id
CROSS JOIN hindi_movie_stats;

----- Q3. Find the production house that has consistently produced movies with high ratings over the past three years.
WITH high_ratings_movies AS (
    SELECT m.production_company, r.avg_rating
    FROM movie m
    INNER JOIN ratings r ON m.id = r.movie_id
    WHERE m.date_published >= '2017-01-01' AND m.date_published <= '2019-12-31'
    AND r.avg_rating >= 8.0
    AND m.production_company IS NOT NULL
    AND r.avg_rating IS NOT NULL
),
production_house_ratings AS (
    SELECT production_company, COUNT(*) AS num_high_ratings
    FROM high_ratings_movies
    WHERE production_company IS NOT NULL
    GROUP BY production_company
),
consistent_high_ratings AS (
    SELECT production_company
    FROM production_house_ratings
    WHERE num_high_ratings = 3
    AND production_company IS NOT NULL
)
SELECT production_company
FROM consistent_high_ratings;

----- Option 2: 
SELECT m.production_company
FROM movie m
INNER JOIN ratings r ON m.id = r.movie_id
WHERE m.date_published >= '2017-01-01' AND m.date_published <= '2019-12-31'
AND r.avg_rating >= 8.0
AND m.production_company IS NOT NULL
AND r.avg_rating IS NOT NULL
GROUP BY m.production_company
HAVING COUNT(*) = 3;



----- Q4. Identify the top three directors who have successfully delivered commercially successful movies with high ratings.

WITH commercially_successful_movies AS (
    SELECT m.id, m.production_company, r.avg_rating, m.worlwide_gross_income
    FROM movie m
    INNER JOIN ratings r ON m.id = r.movie_id
    WHERE m.worlwide_gross_income IS NOT NULL
    AND r.avg_rating >= 8.0
    AND m.production_company IS NOT NULL
),
director_success_counts AS (
    SELECT dm.name_id, COUNT(*) AS success_count
    FROM commercially_successful_movies csm
    INNER JOIN director_mapping dm ON csm.id = dm.movie_id
    GROUP BY dm.name_id
),
directors_commercial_ratings AS (
    SELECT dm.name_id, COUNT(*) AS total_movies, MAX(success_count) AS max_success_count
    FROM commercially_successful_movies csm
    INNER JOIN director_mapping dm ON csm.id = dm.movie_id
    INNER JOIN director_success_counts dsc ON dm.name_id = dsc.name_id
    GROUP BY dm.name_id
    HAVING COUNT(*) >= 1
    AND MAX(success_count) >= 1
    ORDER BY MAX(success_count) DESC
    LIMIT 3
)
SELECT n.name AS director_name, dcr.total_movies, dcr.max_success_count
FROM directors_commercial_ratings dcr
INNER JOIN names n ON dcr.name_id = n.id
ORDER BY dcr.max_success_count DESC;
