-- [GLOBAL NUMBERS]
-- Showing global death percentage
SELECT 
	--date,
	SUM (new_cases) AS total_cases,
	SUM (CAST (new_deaths as int)) AS total_deaths, 
	(SUM (CAST (new_deaths as int))/SUM (new_cases))*100 AS death_percentage
FROM PortfolioProject..Covid_Deaths$
--WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- [BREAKING THINGS DOWN BY CONTINENT]
-- Showing contintents with the highest death count per population

SELECT 
	location, 
	SUM (CAST(new_deaths AS bigint)) AS total_death_count
FROM PortfolioProject..Covid_Deaths$
WHERE 
	continent is null
	AND location not in ('World', 'European Union', 'International')
	AND location not like '%income' -- -- We take these out as they are not inluded in the above queries and want to stay consistent (European Union is part of Europe)
GROUP BY location
ORDER BY total_death_count DESC

-- Countries with Highest Infection Rate compared to Population
-- Without date
SELECT 
	location, 
	population, 
	MAX (total_cases) AS highest_infection_count,
	MAX ((total_cases/population)*100) AS population_infected_percent
FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
GROUP BY
	location,
	population
ORDER BY 4 DESC

-- With date
SELECT 
	location, 
	population, 
	date,
	MAX (total_cases) AS highest_infection_count,
	MAX ((total_cases/population)*100) AS population_infected_percent
FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
GROUP BY
	location,
	population,
	date
ORDER BY 4 DESC