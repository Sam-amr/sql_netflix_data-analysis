DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
( 
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(300),
casts VARCHAR(1000),
country VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(20),
listed_in VARCHAR(150),
description VARCHAR(300)
);
SELECT*FROM netflix;

SELECT COUNT(*) as total_content
FROM netflix;

SELECT
   DISTINCT type
FROM netflix;

---Find null values and remove them----
SELECT*FROM netflix WHERE show_id IS NULL;
SELECT*FROM netflix WHERE type IS NULL;
SELECT*FROM netflix WHERE title IS NULL;
SELECT*FROM netflix WHERE director IS NULL;
SELECT*FROM netflix WHERE casts IS NULL;
SELECT*FROM netflix WHERE country IS NULL;
SELECT*FROM netflix WHERE date_added IS NULL;
SELECT*FROM netflix WHERE release_year IS NULL;
SELECT*FROM netflix WHERE rating IS NULL;
SELECT*FROM netflix WHERE duration IS NULL;
SELECT*FROM netflix WHERE listed_in IS NULL;
SELECT*FROM netflix WHERE description IS NULL;

DELETE FROM netflix 
WHERE show_id IS NULL
   OR type IS NULL
   OR title IS NULL
   OR director IS NULL
   OR casts IS NULL
   OR country IS NULL
   OR date_added IS NULL
   OR release_year IS NULL
   OR rating IS NULL
   OR duration IS NULL
   OR listed_in IS NULL
   OR description IS NULL;

---To see how many shows and movies we have---
SELECT COUNT(*) AS total_content FROM netflix;

---Q1. COUNT THE NO. OF TV SHOWS AND MOVIES---
SELECT 
    type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type;

---Q2. Find the most common rating for movies and TV shows----
SELECT
    type, 
	rating
FROM 
(
SELECT
     type,
     rating,
     COUNT(*) AS cnt,
     RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
     --MAX(rating)
FROM netflix
GROUP BY 1,2
)
WHERE 
    ranking = 1

---Q3. List all movies released in a specific year (e.g., 2020)---
SELECT* FROM netflix
WHERE 
    type='Movie'
	AND
    release_year= 2020
	
---Q4. Find the top 5 countries with the most content on Netflix---
SELECT
	  UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	  COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

---Q5. Identify the longest movie---
SELECT*FROM netflix
WHERE 
   type='Movie'
   AND
   duration = (SELECT MAX(duration) FROM netflix)
   
---Q6. Find content added in the last 5 years---
SELECT
*,
     TO_DATE(date_added, 'Month DD , YYYY') >= CURRENT_DATE- INTERVAL '5 years'
FROM netflix
 
---Q7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'

---Q8. List all TV shows with more than 5 seasons---
SELECT
*
---SPLIT_PART(duration, ' ', 1) as season
FROM netflix
WHERE 
    type = 'TV Show'
	AND
     SPLIT_PART(duration, ' ', 1):: numeric > 5 
	 
---Q9. Count the number of content items in each genre---
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
    COUNT(show_id)
FROM netflix
GROUP BY 1

---Q10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!---
SELECT 
   EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
   COUNT(*) AS yearly_content,
   ROUND(
   COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India' )::numeric * 100 
   ,2) as avg_content_py
   FROM netflix
WHERE country = 'India'
GROUP BY 1

---Q11. List all movies that are documentaries---
SELECT * FROM netflix
WHERE
listed_in ILIKE '%Documentaries%'

---Q12. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT * FROM netflix
WHERE 
     casts ILIKE '%Salman Khan%' 
	 AND
	 release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

---Q13. Find the top 10 actors who have appeared in the highest number of movies produced in India.---
SELECT 
--show_id,
--casts,
UNNEST(STRING_TO_ARRAY(casts, ',')) AS actors,
COUNT(*) AS total_content
FROM netflix
WHERE 
country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 10
      
---Q14. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category. ---
WITH new_table 
AS
(
SELECT 
*,
CASE 
WHEN  description ILIKE '%kill%' OR
	  description ILIKE '%violencel%' THEN 'Bad_Content'
ELSE 'Good_Content'
END category
FROM netflix
)
SELECT 
category,
COUNT(*) as total_content

FROM new_table 
GROUP BY 1