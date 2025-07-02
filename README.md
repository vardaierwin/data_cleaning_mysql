# 🧼 Data Cleaning in MySQL – Layoffs Dataset

This project documents the full SQL-based data cleaning workflow for a dataset tracking company layoffs, originally stored in the `layoffs` table. The goal was to standardize, deduplicate, normalize, and prepare the data for accurate analysis.

## 📁 Tables

- **Original source:** `layoffs`
- **Intermediate table (backup):** `modified_layoffs`
- **Cleaned result:** `modified_layoffs2`

---

## ✅ Cleaning Steps

### 1. 🔁 Duplicate Removal

- Created a backup table `modified_layoffs`
- Used `ROW_NUMBER()` to identify exact duplicates based on all key fields
- Deleted rows with `row_num > 1` to retain only the first occurrence
~~~mysql
WITH verify_duplicates AS (
  SELECT *, ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off,
                 percentage_laid_off, `date`, stage, country, funds_raised_millions
  ) AS row_num
  FROM modified_layoffs
)
DELETE FROM verify_duplicates
WHERE row_num > 1; 
~~~
### 2. 🧹 Standardization
Trimming whitespace:
~~~mysql
UPDATE modified_layoffs2
SET company = TRIM(company);
~~~
Unifying industry names:
~~~mysql
UPDATE modified_layoffs2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
~~~
Unifying country names:
~~~mysql UPDATE modified_layoffs2
SET country = 'United States'
WHERE country LIKE 'United States%';
~~~
### 3. ❌ NULL Handling
Replace string placeholders with real NULLs:
~~~mysql
UPDATE modified_layoffs2 SET industry = NULL WHERE industry IN ('NULL', '');
UPDATE modified_layoffs2 SET percentage_laid_off = NULL WHERE percentage_laid_off = 'NULL';
UPDATE modified_layoffs2 SET `date` = NULL WHERE `date` = 'NULL';
UPDATE modified_layoffs2 SET stage = NULL WHERE stage = 'NULL';
~~~
Set funding of 0 to NULL:
~~~mysql
UPDATE modified_layoffs2
SET funds_raised_millions = NULL
WHERE funds_raised_millions = 0;
~~~
### 4. 📆 Date Normalization
- Converted date column from TEXT to DATE using MySQL’s STR_TO_DATE function.
- Then changed the column type:
~~~mysql
UPDATE modified_layoffs2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE modified_layoffs2
MODIFY COLUMN `date` DATE;
~~~
### 5. 🔄 Industry Enrichment via Self-Join
Filled in missing industry values by matching companies with non-null industry entries:
~~~mysql
UPDATE modified_layoffs2 ml
JOIN modified_layoffs2 ml2 ON ml.company = ml2.company
SET ml.industry = ml2.industry
WHERE ml.industry IS NULL AND ml2.industry IS NOT NULL;
~~~
### 6. 🗑️ Data Pruning
Removed rows where both layoff size and percentage were missing:
~~~mysql
DELETE FROM modified_layoffs2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
~~~
Dropped helper column:
~~~mysql
ALTER TABLE modified_layoffs2
DROP COLUMN row_num;
~~~
# 📊 Result
* The cleaned table modified_layoffs2:
* Contains only distinct records
* Has consistent and normalized fields
* Uses proper `NULL` values for missing data
* Stores dates in `DATE` format
* Is ready for downstream analysis or visualization


