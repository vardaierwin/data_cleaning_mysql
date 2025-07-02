-- Data Cleaning

select * from layoffs

/* 
1. REMOVE duplicates if there are any
2. Standardize the Data (e.g. spelling problems)
3. NULL / blank values (populate, remove)
4. Remove unnecessary columns
*/

-- Copy original table
create table modified_layoffs like layoffs;

insert modified_layoffs 
select * 
from layoffs;

select count(*) from modified_layoffs;

# drop table modified_layoffs;

select *,
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from modified_layoffs ml
order by row_num desc;

-- Detect duplicates using ROW_NUMBER
with verify_duplicates as (
	select *,
	row_number() over(
	partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
	from modified_layoffs 
)
select *
from verify_duplicates
where row_num > 1;

select * from modified_layoffs;

select * from modified_layoffs ml 
where company like 'Casper';

with verify_duplicates as (
	select *,
	row_number() over(
	partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
	from modified_layoffs 
)
delete
from verify_duplicates
where row_num > 1;

CREATE TABLE `modified_layoffs2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT null,
  `row_num` int
);

select * from modified_layoffs;

SELECT total_laid_off, COUNT(*) 
FROM modified_layoffs 
GROUP BY total_laid_off 
ORDER BY 1;

# drop table modified_layoffs2;

INSERT INTO modified_layoffs2 
SELECT 
  company,
  location,
  industry,
  CASE 
    WHEN total_laid_off REGEXP '^[0-9]+$' THEN CAST(total_laid_off AS UNSIGNED)
    ELSE NULL
  END AS total_laid_off,
  percentage_laid_off,
  `date`,
  stage,
  country,
  CASE 
    WHEN funds_raised_millions REGEXP '^[0-9]+$' THEN CAST(funds_raised_millions AS UNSIGNED)
    ELSE NULL
  END AS funds_raised_millions,
  ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, 
                 total_laid_off, percentage_laid_off, 
                 `date`, stage, country, funds_raised_millions
  ) AS row_num
FROM modified_layoffs;

delete 
from modified_layoffs2
where row_num > 1;

select *
from modified_layoffs2;

-- Standadrizing data

select company, trim(company)
from modified_layoffs2;

update modified_layoffs2 
set company = trim(company);

select *
from modified_layoffs2
where industry like "crypto%";

update modified_layoffs2 
set industry = 'Crypto'
where industry like "Crypto%";

select distinct(industry) from modified_layoffs2
where industry like 'null';

update modified_layoffs2 
set industry = null
where industry = 'NULL';

select * from modified_layoffs2;
select * from modified_layoffs2
where percentage_laid_off = 'NULL';

update modified_layoffs2 
set percentage_laid_off = null
where percentage_laid_off = 'NULL';

select * from modified_layoffs2
where `date` = 'NULL';

update modified_layoffs2 
set `date` = null
where `date` = 'NULL';

select * from modified_layoffs2;
select * from modified_layoffs2
where stage = 'NULL';

update modified_layoffs2 
set stage = null
where stage = 'NULL';

select * from modified_layoffs2
order by 9;
  
update modified_layoffs2 
set funds_raised_millions = null
where funds_raised_millions = 0;

-- 

select distinct(country) 
from modified_layoffs2 
where country like 'United States%'  
order by country;

update modified_layoffs2 
set country = 'United States' # or trim(trailing '.' from country)
where country like 'United States%';

select `date`, 
str_to_date(`date`, '%m/%d/%Y')
from modified_layoffs2;

update modified_layoffs2 ml 
set `date` = str_to_date(`date`, '%m/%d/%Y');

select `date` from modified_layoffs2 ml;

alter table modified_layoffs2
modify column `date` date;

select * from modified_layoffs2
where total_laid_off is null
and percentage_laid_off is null;

select * from modified_layoffs2 ml 
where ml.industry is null;

select * from modified_layoffs2 ml 
where ml.company like 'Bally\'s Interactive';

select industry, count(*) as count
from modified_layoffs2
where industry is null or industry = ''
group by industry;

update modified_layoffs2 ml 
set industry = null
where ml.industry = '';

select * from modified_layoffs2 ml 
where company like "%Juul%";

select ml.company, ml.industry, ml2.industry
from modified_layoffs2 ml 
join modified_layoffs2 ml2 
on ml.company = ml2.company
where ml.industry is null
and ml2.industry is not null;

update modified_layoffs2 ml 
join modified_layoffs2 ml2 
on ml.company = ml2.company
set ml.industry = ml2.industry
where ml.industry is null
and ml2.industry is not null;

select *
from modified_layoffs2 ml;

select * from modified_layoffs2
where total_laid_off is null
and percentage_laid_off is null;

delete from modified_layoffs2
where total_laid_off is null
and percentage_laid_off is null;

alter table modified_layoffs2 
drop column row_num;






















