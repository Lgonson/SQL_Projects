-- Copiamos los headers de la tabla original, en este caso de layoffs

CREATE TABLE layoffs_staging
LIKE layoffs;

-- Seleccionamos todo de layoffs_staging para ver que efectivamente copiamos los headers.

SELECT *
FROM layoffs_staging;

-- Copiamos los valores de layoffs en layoffs_staging:

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Controlamos que se hayan copiado:

SELECT *
FROM layoffs_staging;

-- Identificar duplicados:

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- revisar los casos duplicados:
SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo';

-- Eliminar duplicados: Para eso vamos a tener que crear una tabla nueva con una columna extra row_num

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
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Controlamos los headers que acabamos de copiar:

SELECT *
FROM layoffs_staging2;

-- Insertamos los datos del CTE en nuestra nueva tabla:

INSERT INTO layoffs_staging2 
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Controlamos si la informacion se copio bien:

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Borramos los duplicados:

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing Data (Findinx Issues in the data and fixing it)
-- Encontramos que en la columna company hay algunos espacios incorrectos
-- Comprobamos esto con el siguiente comando:
SELECT company, TRIM(company)
FROM layoffs_staging2;

-- borramos los espacios:
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Revisamos la 2da columna (industry):

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

-- Ver todas las empresas bajo insignia crypto:

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Update industry Crypto:

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Control 1 de 2
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

-- Control 2 de 2

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry DESC;

-- Revisamos la 3era columna (location): esta ok
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

-- Revisamos country: y encontramos problema en USA, hay 2.
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Ver todas las empresas bajo country United States:

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%';

-- Update country USA:

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Revisamos country: a ver si solucionamos el problema.
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Empezamos con la columna date

SELECT `date`
FROM layoffs_sdatetaging2;

-- Queremos ver como quedaria la columna date con el cambio

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

-- Como vemos que esta todo ok, pasamos a hacer el cambio (de la estructura de la columna):

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Una vez modificada la estructura de la columna 'date' podemos cambiar el tipo de dato:

ALTER TABLE layoffs_staging2 
MODIFY COLUMN `date` DATE;

-- Eliminacion de NULL y Blanks from industry column. Primero seleccionamos cuales tenemos:

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

-- Vamos a revisar si AIRBNB tiene otra linea donde figure su industria.

SELECT * 
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Vamos a hacer un JOIN para ver si es posible completar los datos

SELECT t1.company, t1.location, t1.industry, t2.company, t2.location, t2.industry 
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Update blanks to NULL

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Vamos a hacer un JOIN para completar los datos:

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Vamos a ver que valores no se pudieron actualizar:

SELECT * 
FROM layoffs_staging2
WHERE (industry IS NULL OR industry = '')
;

-- DELETE COLUMNS where total_laid_off & percentage_laid_off = Null

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Vamos a borrar la columna row_num, porque ya no la necesitamos.

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;










