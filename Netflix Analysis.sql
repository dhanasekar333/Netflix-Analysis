DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix

-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(type) as total_content FROM netflix
GROUP BY type


--2. Find the most common rating for movies and TV shows
SELECT
	type,
	ranking
FROM
(
SELECT
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1,2
) as t1
WHERE ranking = 1

--3. List all movies released in a specific year (e.g., 2020)

SELECT 
	title,
	release_year
FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020
	
--4. Find the top 5 countries with the most content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--5. Identify the longest movie
SELECT * FROM netflix
WHERE
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix)


--6. Find content added in the last 5 years

SELECT * FROM netflix
WHERE
	TO_DATE(date_added,'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'


--8. List all TV shows with more than 5 seasons

SELECT * FROM netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration,' ',1) >= '5 Seasons'
	
--9. Count the number of content items in each genre

SELECT
	COUNT(*),
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre
FROM netflix
GROUP BY genre
ORDER BY COUNT(*) DESC
	


--10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!
-- total_content = 333/972
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) as year,
	COUNT(*) as yearly_content,
	ROUND(
	COUNT(*)::numeric / (SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100
	,2) as avg_content_per_year
FROM netflix
WHERE country = 'India'
GROUP BY 1

--11. List all movies that are documentaries

SELECT
	UNNEST(STRING_TO_ARRAY(listed_in,',')),
	type,
	title
FROM netflix
WHERE
	type = 'Movie'
	AND
	listed_in = 'Documentaries'
GROUP BY listed_in,type,title

SELECT * FROM netflix
WHERE 
	listed_in ILIKE '%documentaries%'

--12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL OR director = '' 

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE
	casts ILIKE '%salman khan%'
	AND
	release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT 
	UNNEST(STRING_TO_ARRAY(casts,',')), as actors
	COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
WITH Content_table
AS
(
SELECT
*,
	CASE
	WHEN 
		description ILIKE '%kill%' OR 
		description ILIKE '%violence%' THEN 'Bad_Content'
		ELSE 'Good_Content'
	END category
FROM netflix
)
SELECT 
	category,
	COUNT(*)
FROM Content_table
GROUP BY category