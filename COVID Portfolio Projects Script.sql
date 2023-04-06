SELECT				*
FROM				PortfolioProject..CovidDeaths$
WHERE				continent is not NULL
ORDER BY			3,4


--SELECT				*
--FROM				PortfolioProject..CovidVaccination$
--WHERE				continent is not NULL
--ORDER BY			3,4

SELECT				Location,
					date,
					total_cases,
					new_cases,
					total_deaths,
					population
FROM				PortfolioProject..CovidDeaths$
ORDER BY			1,2

-- Looking at the total cases vs total Deaths
-- Shows the likelihood of dying if you contact Covid


SELECT				Location,
					date,
					total_cases,
					total_deaths,
					(total_deaths/total_cases)*100 DeathPercentage
					--population
FROM				PortfolioProject..CovidDeaths$
WHERE				Location Like '%States%'
WHERE				continent is not NULL
ORDER BY			1,2


--SELECT				Location,
--					date,
--					total_cases,
--					total_deaths,
--					(total_deaths/total_cases)*100 DeathPercentage
--					--population
--FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like 'CANA%'
--WHERE				continent is not NULL
--ORDER BY			1,2


-- Looking at the Total Cases VS Population

SELECT				Location,
					date,
					population,
					total_cases,
					(total_cases/population)*100 PercentageInfected
FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like '%States%'
WHERE				continent is not NULL
ORDER BY			1,2


--SELECT				Location,
--					date,
--					total_cases,
--					population,
--					(total_cases/population)*100 PercentageInfected
--FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like 'CANA%'
--WHERE				continent is not NULL
--ORDER BY			1,2



-- Looking at Countries with Highest Infection Rate compared to Population

SELECT				continent,
					MAX(total_cases) HighestInfectionCount,
					MAX((total_cases/population))*100 PercentPoluationInfected
FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like '%States%'
WHERE				continent is not NULL
GROUP BY			continent
ORDER BY			1,2

SELECT				Location,
					population,
					MAX(total_cases) HighestInfectionCount,
					MAX((total_cases/population))*100 PercentPoluationInfected
FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like '%States%'
WHERE				continent is not NULL
GROUP BY			continent
ORDER BY			PercentPoluationInfected DESC


--SELECT				Location,
--					population,
--					MAX(total_cases) HighestInfectionCount,
--					MAX((total_cases/population))*100 PercentPoluationInfected
--FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like 'CANA%'
--WHERE				continent is not NULL
--GROUP BY			Location, population
--ORDER BY			PercentPoluationInfected


-- Showing the Countries The Highest Death Count per Polpulation

SELECT				location,
					MAX(cast(total_deaths AS INT)) TotalDeathCount
FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like '%States%'
WHERE				continent is not NULL
GROUP BY			location
ORDER BY			TotalDeathCount DESC

--SELECT				location,
--					MAX(total_deaths) TotalDeathCount
--FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like 'CANA%'
--WHERE				continent is not NULL
--GROUP BY			location
--ORDER BY			TotalDeathCount DESC



--LETS BREAK THINGS DOWN BY CONTINENT

SELECT				continent,
					MAX(cast(total_deaths AS INT)) TotalDeathCount
FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like '%States%'
WHERE				continent is NULL
GROUP BY			continent
ORDER BY			TotalDeathCount DESC

--SELECT				continent,
--					MAX(cast(total_deaths AS INT)) TotalDeathCount
--FROM				PortfolioProject..CovidDeaths$
----WHERE				Location Like 'CANA%'
--WHERE				continent is NULL
--GROUP BY			continent
--ORDER BY			TotalDeathCount DESC


--- Showing Continents with the Highest Deaths per Population

SELECT				continent,
					MAX(cast(total_deaths AS INT)) TotalDeathCount
FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like '%States%'
WHERE				continent is NULL
GROUP BY			continent
ORDER BY			TotalDeathCount DESC

-- Global Numbers

SELECT				date,
					SUM(new_cases) Total_Cases,
					SUM(cast(new_deaths as INT)) Total_Deaths,
					SUM(cast(new_deaths as INT))/ SUM(new_cases)*100 DeathPercentage
					--population
FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like '%States%'
WHERE				continent is not NULL
GROUP BY			date
ORDER BY			1,2


SELECT				--date,
					SUM(new_cases) Total_Cases,
					SUM(cast(new_deaths as INT)) Total_Deaths,
					SUM(cast(new_deaths as INT))/ SUM(new_cases)*100 DeathPercentage
					--population
FROM				PortfolioProject..CovidDeaths$
--WHERE				Location Like '%States%'
WHERE				continent is not NULL
---GROUP BY			date
ORDER BY			1,2


----WORKING WITH BOTH DBO...
--- JOINING BOTH TABLES

SELECT				*
FROM				PortfolioProject..CovidDeaths$ DEA
JOIN				PortfolioProject..CovidVaccination$ VAC
ON					DEA.location = VAC.location
AND					DEA.date = VAC.date


---- lOOKING AT TOTAL POPULATION VS VACCINATIONS

--JOIN TABLES FIRST
SELECT				DEA.continent,
					DEA.location,
					DEA.date,
					DEA.population,
					VAC.new_vaccinations
FROM				PortfolioProject..CovidDeaths$ DEA
JOIN				PortfolioProject..CovidVaccination$ VAC
ON					DEA.location = VAC.location
AND					DEA.date = VAC.date
WHERE				DEA.continent is not NULL
ORDER BY			2,3


----TOTAL POPULATION VS VACCINATIONS

SELECT				DEA.continent,
					DEA.location,
					DEA.date,
					DEA.population,
					VAC.new_vaccinations,
					SUM(CAST(new_vaccinations as INT)) OVER (Partition by DEA.Location)
FROM				PortfolioProject..CovidDeaths$ DEA
JOIN				PortfolioProject..CovidVaccination$ VAC
ON					DEA.location = VAC.location
AND					DEA.date = VAC.date
WHERE				DEA.continent is not NULL
ORDER BY			2,3

-- OR

SELECT				DEA.continent,
					DEA.location,
					DEA.date,
					DEA.population,
					VAC.new_vaccinations,
					SUM(CONVERT(INT,new_vaccinations)) 
					OVER 
					(
					Partition by DEA.Location
					Order By DEA.location, DEA.date
					) RollingPeopleVaccinated
FROM				PortfolioProject..CovidDeaths$ DEA
JOIN				PortfolioProject..CovidVaccination$ VAC
ON					DEA.location = VAC.location
AND					DEA.date = VAC.date
WHERE				DEA.continent is not NULL
ORDER BY			2,3


--- We have to use CTE here

---CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT				DEA.continent,
					DEA.location,
					DEA.date,
					DEA.population,
					VAC.new_vaccinations,
					SUM(CONVERT(INT,new_vaccinations)) 
					OVER 
					(
					Partition by DEA.Location
					Order By DEA.location, DEA.date
					) RollingPeopleVaccinated
					---, (RollingPeopleVaccinated/population)*100
FROM				PortfolioProject..CovidDeaths$ DEA
JOIN				PortfolioProject..CovidVaccination$ VAC
ON					DEA.location = VAC.location
AND					DEA.date = VAC.date
WHERE				DEA.continent is not NULL
--ORDER BY			2,3
)

SELECT				*,
					(RollingPeopleVaccinated/population)*100 PercentPopulationVaccinated
FROM				PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table IF EXISTS	 #PercentPopulationVaccinated
CREATE TABLE			 #PercentPopulationVaccinated
			(
						 Continent nvarchar(255),
						 Location nvarchar(255),
						 Date datetime,
						 Population numeric,
						 New_vaccinations numeric,
						 RollingPeopleVaccinated numeric
			)

INSERT INTO				#PercentPopulationVaccinated
SELECT					DEA.continent,
						DEA.location,
						DEA.date,
						DEA.population,
						VAC.new_vaccinations,
						SUM(CONVERT(INT,new_vaccinations)) 
						OVER 
						(
						Partition by DEA.Location
						Order By DEA.location, DEA.date
						) RollingPeopleVaccinated
						---, (RollingPeopleVaccinated/population)*100
FROM					PortfolioProject..CovidDeaths$ DEA
JOIN					PortfolioProject..CovidVaccination$ VAC
ON						DEA.location = VAC.location
AND						DEA.date = VAC.date
WHERE					DEA.continent is not NULL
--ORDER BY				2,3

SELECT				   *,
					   (RollingPeopleVaccinated/population)*100 PercentPopulationVaccinated
FROM				   #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW				PercentPopulationVaccinated
AS
SELECT					DEA.continent,
						DEA.location,
						DEA.date,
						DEA.population,
						VAC.new_vaccinations,
						SUM(CONVERT(INT,new_vaccinations)) 
						OVER 
						(
						Partition by DEA.Location
						Order By DEA.location, DEA.date
						) RollingPeopleVaccinated
						---, (RollingPeopleVaccinated/population)*100
FROM					PortfolioProject..CovidDeaths$ DEA
JOIN					PortfolioProject..CovidVaccination$ VAC
ON						DEA.location = VAC.location
AND						DEA.date = VAC.date
WHERE					DEA.continent is not NULL
--ORDER BY				2,3


SELECT				   *
FROM				   #PercentPopulationVaccinated