-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems

-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1;

-- 2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix
WHERE release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT * 
FROM
(
	SELECT 
		-- country,
		UNNEST(STRING_TO_ARRAY(country, ',')) as country,
		COUNT(*) as total_content
	FROM netflix
	GROUP BY 1
)as t1
WHERE country IS NOT NULL
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie

SELECT*
FROM netflix
WHERE type='Movie'
ORDER BY SPLIT_PART(duration,' ',1)::int DESC;

-- 6. Find content added in the last 5 years
SELECT*
FROM netflix
WHERE TO_DATE(date_added,'month DD,YYYY') >= CURRENT_DATE-INTERVAL '5 years';

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT *
FROM netflix
where director ILIKE '%rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons

SELECT *
FROM netflix
WHERE type= 'TV Show'
AND
SPLIT_PART(duration,' ',1)::INT >5;

-- 9. Count the number of content items in each genre

SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre ,COUNT(show_id)
FROM netflix
GROUP BY genre;

-- 10.Find each year and the average numbers of content release in India on netflix.return top 5 year with highest avg content release! 

SELECT EXTRACT(YEAR FROM TO_DATE(date_added,'MONTH DD,YYYY')) AS year,count(*),
round(count(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%')*100 ,2)AS avg_content
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY year;

-- 11.List all movies that are documentaries

SELECT *
FROM netflix
WHERE type='Movie'
AND listed_in ILIKE '%Documentaries';

-- 12.Find all content without a director

SELECT*
FROM netflix
WHERE director IS NULL;

-- 13.Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%'
AND release_year>= EXTRACT(year FROM CURRENT_DATE) - 10;

-- 14.Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT UNNEST(STRING_TO_ARRAY(casts,',')) AS actor,COUNT(*)
FROM netflix
WHERE type='Movie'
AND country ILIKE '%India%'
GROUP BY actor
ORDER BY 2 DESC
LIMIT 10;

-- 15: Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.

WITH new_table
AS(
	SELECT*,
	CASE 
	WHEN
	description ILIKE '%kill%' OR
	description ILIKE '%violence%' THEN 'bad_content'
	ELSE 'good_content'
	END Category
	FROM netflix 
)
SELECT Category,count(*)
from new_table
GROUP BY 1

WHERE description ILIKE '%kill%' OR description ILIKE '%violence%';
























 


















