SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- SELECT DATA THAT WE WILL BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- LOOKNG AT TOTAL CASES VS TOTAL DEATHS
-- SHOWS THE LIKELYHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


-- LOOKING AT THE TOTAL CASES VS THE POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID

SELECT location, date,population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
ORDER BY 1,2


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases), MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNTS PER POPULATION

SELECT location,  MAX(cast (total_deaths as int)) AS TotalDeathCounts
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCounts  DESC


-- BREAKING THINGS DOWN BY CONTINENT



-- SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent,  MAX(cast (total_deaths as int)) AS TotalDeathCounts
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCounts  DESC




-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- LOOKING AT TOTAL POPULATION VS VACCINATION

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent IS NOT NULL
	 ORDER BY 2,3


--USING CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
--, Rollingpeoplevaccinated*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent IS NOT NULL
	 --ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255), 
Location nvarchar (255), 
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
--, Rollingpeoplevaccinated*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 --WHERE dea.continent IS NOT NULL
	 --ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated






--CREATING VIEW TO STORE DATA FOR VISUALIZATUIONS

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
--, Rollingpeoplevaccinated*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
	 WHERE dea.continent IS NOT NULL
	 --ORDER BY 2,3



SELECT * 
FROM PercentPopulationVaccinated 

