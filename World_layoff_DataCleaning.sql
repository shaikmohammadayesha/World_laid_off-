-- Data Cleaning

-- Original Dataset (Raw Data)
SELECT * 
FROM layoffs;

-- Data Cleaning Process :
-- 1.Remove Duplicate 
-- 2. Standardize data
-- 3. Null values and Blank values
-- 4. Remove any column

-- Creating a Working Table 
CREATE TABLE layoffs_staging
LIKE layoffs;

-- Inserting the original data into working table
INSERT INTO layoffs_staging
SELECT * 
FROM layoffs; 

-- Giving row number to indentify the duplicate row
WITH duplicate_layoff AS
(
SELECT * ,
	   ROW_NUMBER() OVER(PARTITION BY company, location, industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_layoff
WHERE row_num >1;

-- Creating another table to work on
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` Int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT * ,
	   ROW_NUMBER() OVER(PARTITION BY company, location, industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Deleting Duplicate rows.
DELETE 
FROM layoffs_staging2
WHERE row_num >1;

SELECT *
FROM layoffs_staging2;

--  2. Standardizing data

-- Removing leading and trailing spaces in the company field.
SELECT DISTINCT(COMPANY), TRIM(COMPANY)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET company = TRIM(COMPANY);

-- Generalizing the industry field
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


-- Correcting the Country field by removing the period found
SELECT DISTINCT(COUNTRY), TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET Country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Changing the date field to Date which is originally String
SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN  `date` DATE;

-- Trying to extract the blank cells
SELECT *
FROM layoffs_staging2
WHERE industry is Null or industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- replacing all blank with null
UPDATE layoffs_staging2
SET industry = null
WHERE industry = '';

-- replacing the null cells of industry with the found value of matching company and location
SELECT *
FROM layoffs_staging2 t1
	JOIN layoffs_staging2 t2
    ON t1.company = t2.company
		AND t1.location = t2.location
WHERE t1.industry is NULL
ANd t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
	JOIN layoffs_staging2 t2
    ON t1.company = t2.company
		AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Deleting the rows whith both null in total_laid_off and percetage_laid_off
DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Dropping the row_num column we added to idetify the duplicate rows
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;


