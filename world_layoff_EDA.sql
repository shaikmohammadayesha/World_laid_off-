-- Exploitory Data Analysis (EDA)

-- Dataset Duration
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- (2020-03-11 - 2023-03-06)

-- Most laid offs 
SELECT MAX(total_laid_off)
FROM layoffs_staging2;
-- 12k


SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY  funds_raised_millions desc;
-- 116 rows

-- Company vs layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Industry vs layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Country vs layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Year vs layoffs
SELECT YEAR(`date`) AS `YEAR`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `YEAR`
ORDER BY 1;

-- Stage of company vs layoffs
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 desc;

-- year-month rolling total
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `Month`
ORDER BY 1 asc;

WITH Rolling_total_laid_off AS 
(
SELECT SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) as total
FROM layoffs_staging2
WHERE `date` IS NOT NULL
GROUP BY `Month`
ORDER BY 1 asc
)
SELECT `Month`, total,
	 SUM(total) OVER(ORDER BY `Month`) AS rolling_total
FROM Rolling_total_laid_off;



-- company layoffs each year
SELECT company, YEAR(`date`) AS `Year`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, `Year`
ORDER BY 3 DESC;

WITH company_yr (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
company_yr_ranks AS
(
SELECT *,
		dense_rank() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_yr
WHERE years is not null
)
SELECT *
FROM company_yr_ranks
WHERE ranking <= 5
;