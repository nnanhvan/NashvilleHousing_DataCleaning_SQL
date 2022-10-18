/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT * 
FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
ORDER BY 3,4

-- Select Data that we are going to be starting with

SELECT location, date, population, total_cases, new_cases, total_deaths
FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
ORDER BY 1,2


-- [TOTAL CASES VS TOTAL DEATHS]

-- Shows likelihood of dying if you contract covid in VietNam

SELECT 
	location, 
	date, 
	population, 
	total_cases, 
	new_cases, total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..Covid_Deaths$
WHERE 
	location ='Vietnam'
	AND continent is not null
ORDER BY 2,7



-- [TOTAL CASES VS POPULATION]

-- Shows what percentage of VietNam's population infected with Covid 

SELECT 
	location, 
	date, 
	population, 
	total_cases,  
	(total_cases/population)*100 AS percent_population_infected
FROM PortfolioProject..Covid_Deaths$
WHERE 
	location ='Vietnam'
	AND continent is not null
ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population

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



-- Countries with Highest Death Count per Population

SELECT 
	location, 
	MAX (CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
GROUP BY
	Location
ORDER BY total_death_count DESC



-- [BREAKING THINGS DOWN BY CONTINENT]

-- Showing contintents with the highest death count per population

SELECT 
	continent, 
	MAX (CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC



-- [GLOBAL NUMBERS]

-- Showing global death percentage
SELECT 
	date,
	SUM (new_cases) AS total_cases,
	SUM (CAST (new_deaths as int)) AS total_deaths, 
	(SUM (CAST (new_deaths as int))/SUM (new_cases))*100 AS death_percentage
FROM PortfolioProject..Covid_Deaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2




-- [TOTAL POPULATION VS VACCINATIONS] 

-- Showing Percentage of Population that has recieved at least one Covid Vaccine

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM (CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM 
	PortfolioProject..Covid_Deaths$ dea
	JOIN PortfolioProject..Covid_Vaccinations$ vac
		ON
		dea.location = vac.location
		AND dea.date = vac.date
WHERE 
	dea.continent is not null
ORDER BY 2,3



-- Using CTE to perform Calculation on Partition By in previous query

WITH pop_vs_vac
	( continent, location, date, population, new_vaccinations, rolling_people_vaccinated )
AS (
	SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM (CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM 
		PortfolioProject..Covid_Deaths$ dea
		JOIN PortfolioProject..Covid_Vaccinations$ vac
			ON
			dea.location = vac.location
			AND dea.date = vac.date
	WHERE 
		dea.continent is not null
	)
SELECT 
	*,
	(rolling_people_vaccinated/population)*100 AS percent_population_vaccinated
FROM pop_vs_vac
ORDER BY location, date



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PopulationVaccinatedPercent
CREATE TABLE #PopulationVaccinatedPercent
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

INSERT INTO #PopulationVaccinatedPercent
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations, 
	SUM (CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM PortfolioProject..Covid_Deaths$ dea
JOIN PortfolioProject..Covid_Vaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

SELECT 
	*, 
	(RollingPeopleVaccinated/Population)*100 AS percent_population_vaccinated
FROM #PopulationVaccinatedPercent



-- Creating View to store data for later visualizations

CREATE VIEW population_vaccinated_percent AS 
	SELECT
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM (CONVERT (bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
	FROM 
		PortfolioProject..Covid_Deaths$ dea
		JOIN PortfolioProject..Covid_Vaccinations$ vac
			ON
			dea.location = vac.location
			AND dea.date = vac.date
	WHERE 
		dea.continent is not null

SELECT * 
FROM population_vaccinated_percent
