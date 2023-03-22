SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePerc FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Countries with highest infection rate vs pop
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  
MAX((total_cases/population))*100 as InfectionPerc FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectionPerc desc

--Showing Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
Order By TotalDeathCount desc

--Continents with highest death count per pop
SELECT location, MAX(cast(total_deaths as int)) as TotalDeaths FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP by location
order by TotalDeaths desc


--Global Numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeath, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPerc FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Total pop vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as VaccCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE Cte to get vaccination Perecentage

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, VaccCount) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as VaccCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

)
SELECT *, (VaccCount/population)*100 as VaccinationPerc FROM PopVsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
VaccCount numeric)

Insert INTO #PercentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as VaccCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT *, (VaccCount/population)*100 as VaccinationPerc FROM #PercentPopVaccinated

--Creating View
CREATE view percentpopvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as VaccCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT * FROM percentpopvaccinated