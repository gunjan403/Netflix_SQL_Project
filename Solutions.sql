---NETFLIX PROJECT
DROP TABLE IF EXIXTS netflix;
CREATE TABLE  netflix
(
	show_id	VARCHAR(6),
	type	VARCHAR(10),
	title	VARCHAR(150),
	director VARCHAR(208),	
	castS	VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(20),
	listed_in	VARCHAR(79),
	description VARCHAR(250)
);

SELECT * FROM netflix;

--TOTAL COUNT
SELECT COUNT(*) AS TOTAL_CONTENT
FROM netflix;

--TYPES
SELECT
	DISTINCT type
FROM netflix;

--15 BUSINESS PROBLEMS:

--1. Count the number of Movies vs TV Shows
SELECT 
	type,
	COUNT (*) as total_content
FROM netflix
GROUP BY type;

--2. Find the most common rating for movies and TV shows
SELECT 
	type,
	rating
FROM
(
	SELECT
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
) 
WHERE ranking=1

--3. List all movies released in a specific year (e.g., 2020)
SELECT * FROM netflix 
WHERE 
	type='Movie'
	AND 
	release_year=2020
	
---4. Find the top 5 countries with the most content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) AS new_country,
	COUNT(show_id) as total_content
	
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--Seprated each country in a new row
--UNNEST(STRING_TO_ARRAY(country,',')) AS new_country

--5. Identify the longest movie

SELECT * FROM netflix
WHERE
	type ='Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)

--6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE 
	TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT 
FROM NETFLIX 
WHERE 
	director ILIKE '%Rajiv Chilaka%'
	
--8. List all TV shows with more than 5 seasons

--*,
--SPLIT_PART(duration, ' ' ,1)as seasons
SELECT *
FROM netflix
WHERE 
	TYPE = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::INT > 5

--9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ','))as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

--10.Find each year and the average numbers of content release in India on netflix. 
     --return top 5 year with highest avg content release!
SELECT 
	
	EXTRACT(YEAR FROM TO_DATE(date_added,'Month DD,YYYY')) as Year,
	COUNT(*) as yearly_content,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country='India')::numeric *100 ,2)
	as avrg_content_per_year
FROM netflix
WHERE country='India'
GROUP BY 1
ORDER BY avrg_content_per_year DESC
LIMIT 5
   
--11. List all movies that are documentaries

SELECT * FROM netflix
	WHERE type='Movie'
	and
	listed_in ILIKE'%Documentaries%'

--12. Find all content without a director
SELECT * FROM netflix
where director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * FROM netflix
WHERE
	casts LIKE '%Salman Khan%'
	AND
	release_year >= EXTRACT(YEAR FROM(CURRENT_DATE)) -10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
	UNNEST(STRING_TO_ARRAY(casts, ',')) as actor,
	COUNT(*)
FROM netflix
WHERE country ILIKE '%India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
    the description field. Label content containing these keywords as 'Bad' and all other 
    content as 'Good'. Count how many items fall into each category.

WITH new_table
AS

(
SELECT *,

	CASE
	WHEN 
		description ILIKE '%kill%' 
		OR
		description ILIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good_Content'
	END Category
FROM netflix
)

SELECT 
	category,
	COUNT(*) as total_content
FROM new_table
GROUP BY 1
ORDER BY 2 DESC
	