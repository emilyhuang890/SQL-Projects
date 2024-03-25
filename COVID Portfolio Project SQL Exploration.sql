/*
COVID 19 Data Exploration

Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--Select data that we are going to be starting with.

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs. Total Deaths by each country. 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Here is the Total Cases vs. Total Deaths in the United States. 
--Shows the likelihood pf dying if you contract COVID in the US. 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at Total Cases vs. Population
--Shows what percentage of population got COVID.

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfection
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population. 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfection
FROM PortfolioProject..CovidDeaths
GROUP BY [location], population
ORDER BY PercentPopulationInfection DESC


--Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
GROUP BY [location]
ORDER BY TotalDeathCount DESC

--In doing this, there are some groupings that are entire continents, not just the country. We need to specify where the continent is NULL. 

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY [location]
ORDER BY TotalDeathCount DESC


--Breaking things down by Continent.
--Showing the continents with the highest death count per population. 

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY [continent]
ORDER BY TotalDeathCount DESC

--The US has the highest total death count. Breaking it down by the countries within North America.

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent = 'North America'
GROUP BY [location]
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY [date]
ORDER BY 1,2

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Population vs. Vaccinations
--Shows Percentage of Population that has received at least one COVID vaccine.

SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.[location] = vac.location 
AND dea.[date] = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3


--Using CTE to perform the calculation on parition By in the previous query.

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.[location] = vac.location 
AND dea.[date] = vac.date 
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac



--Using Temp Table to perform the same calculation as the CTE.

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    LOCATION NVARCHAR(255),
    DATE DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.[location] = vac.location 
AND dea.[date] = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations. 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
ON dea.[location] = vac.location 
AND dea.[date] = vac.date 
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated


CREATE VIEW TotalDeathPrcentageWorld AS
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

SELECT *
FROM TotalDeathPrcentageWorld