Select *
From CovidDeath
where continent is not null
order by 3,4

-- Total Cases vs Total Deaths
SELECT location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPersentage
FROM CovidDeath
where continent is not null
--where location = 'Egypt'
ORDER BY 1,2

-- Total Cases vs Population
SELECT location,date,population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeath
where continent is not null
--where location = 'Egypt'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location,population, MAX(total_cases)as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeath
--where location = 'Egypt'
where continent is not null
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths)as TotalDeathCount
FROM CovidDeath
--where location = 'Egypt'
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
SELECT continent, MAX(total_deaths)as TotalDeathCount
FROM CovidDeath
--where location = 'Egypt'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

---- Global Numbers
--SELECT date,SUM(new_cases ) AS total_cases ,SUM(new_deaths) AS total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
--FROM CovidDeath
--where continent is not null
----where location = 'Egypt'
--GROUP BY date
--ORDER BY 1,2

-- Global Numbers
SELECT SUM(new_cases ) AS total_cases ,SUM(new_deaths) AS total_deaths,(SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeath
where continent is not null
--where location = 'Egypt'
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
SELECT death.continent,death.location,death.date,population,new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location,death.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeath death
JOIN CovidVaccination vaccin
	ON death.location = vaccin.location and death.date = vaccin.date
where death.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac (Continent , Location , Date , Population , New_Vaccinations , RollingPeopleVaccinated)
AS (
SELECT death.continent,death.location,death.date,population,new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location,death.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeath death
JOIN CovidVaccination vaccin
	ON death.location = vaccin.location and death.date = vaccin.date
where death.continent is not null 
--order by 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM PopvsVac 


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT death.continent,death.location,death.date,population,new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location,death.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeath death
JOIN CovidVaccination vaccin
	ON death.location = vaccin.location and death.date = vaccin.date
--where death.continent is not null 
--order by 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated  AS 
SELECT death.continent,death.location,death.date,population,new_vaccinations,
SUM(new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location,death.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeath death
JOIN CovidVaccination vaccin
	ON death.location = vaccin.location and death.date = vaccin.date
where death.continent is not null 
--order by 2,3