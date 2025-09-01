# Netflix Movies and TV Shows Data Analysis Using SQL

##Overview:-
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Tool Used
PostgreSQL

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

``` sql
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
```

### Find and remove Null Values

``` sql
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
```

## Business Problems and Solutions:-

### 1. Count the Number of Movies vs TV Shows

``` sql
SELECT 
    type,
	COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

### 2. Find the Most Common Rating for Movies and TV Shows

``` sql
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
```

### 3. List all movies released in a specific year (e.g., 2020)

``` sql
SELECT* FROM netflix
WHERE 
    type='Movie'
	AND
    release_year= 2020
```
### 4. Find the top 5 countries with the most content on Netflix

``` sql
SELECT
	  UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	  COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

### 5. Identify the longest movie
``` sql
SELECT*FROM netflix
WHERE 
   type='Movie'
   AND
   duration = (SELECT MAX(duration) FROM netflix)
```

### 6. Find content added in the last 5 years
``` sql
SELECT
*,
     TO_DATE(date_added, 'Month DD , YYYY') >= CURRENT_DATE- INTERVAL '5 years'
FROM netflix
```

### 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
``` sql
SELECT * FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'
```
### 8. List all TV shows with more than 5 seasons
``` sql
SELECT
*
---SPLIT_PART(duration, ' ', 1) as season
FROM netflix
WHERE 
    type = 'TV Show'
	AND
     SPLIT_PART(duration, ' ', 1):: numeric > 5 
```

### 9. . Count the number of content items in each genre

``` sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
    COUNT(show_id)
FROM netflix
GROUP BY 1
```

### 10. Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!

``` sql
SELECT 
   EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
   COUNT(*) AS yearly_content,
   ROUND(
   COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India' )::numeric * 100 
   ,2) as avg_content_py
   FROM netflix
WHERE country = 'India'
GROUP BY 1
```

### 11. List all movies that are documentaries

``` sql
SELECT * FROM netflix
WHERE
listed_in ILIKE '%Documentaries%'
```

### 12. Find how many movies actor 'Salman Khan' appeared in last 10 years!

``` sql
SELECT * FROM netflix
WHERE 
     casts ILIKE '%Salman Khan%' 
	 AND
	 release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
```

### 13. Find the top 10 actors who have appeared in the highest number of movies produced in India.

``` sql
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
```

### 14. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.

``` sql
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
```
## Key Insiights
1. The dataset contains a mix of TV shows and movies, allowing analysis of content distribution by type.

2. After cleaning, we ensured that all null or missing values were removed for accurate analysis.

3. Analysis of content by type shows the total number of movies versus TV shows, giving an overview of the platform’s offerings.

4. The most common ratings for movies and TV shows were identified, helping understand target audiences and content suitability.

5. We examined movies released in specific years (e.g., 2020) to understand annual content trends.

6. The top countries with the most content on Netflix were identified, highlighting regions contributing most to the catalog.

7. The longest movie in the dataset was determined, showing extremes in content duration.

8. Content added in the last 5 years was extracted, giving insights into recent additions and trends.

9. Analysis of directors (e.g., Rajiv Chilaka) and actors (e.g., Salman Khan) shows popular contributors and their presence on Netflix.

10. TV shows with more than 5 seasons were identified, revealing long-running series.

11. Content was analyzed by genre, showing which categories are most common across the platform.

12. The average number of content releases per year in India was calculated, showing yearly trends in regional content production.

13. Movies categorized as Documentaries were listed to identify educational or informational content.

14. Actors with the highest number of appearances in Indian content were identified, highlighting prolific contributors.

15. Content was classified based on keywords in descriptions (e.g., “kill” or “violence”) into Good or Bad content, providing insights into content tone and appropriateness.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.




