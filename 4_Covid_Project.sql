-- Update column date from text to date for table coviddeaths_01

SELECT `date`
FROM coviddeaths_01;

SELECT `date`,
STR_TO_DATE(`date`, '%d.%m.%Y')
FROM coviddeaths_01;

UPDATE coviddeaths_01
SET `date` = STR_TO_DATE(`date`, '%d.%m.%Y');

-- Update column date from text to date for table covidvaccinations_01

SELECT `date`
FROM covidvaccinations_01;

SELECT `date`,
STR_TO_DATE(`date`, '%d.%m.%Y')
FROM covidvaccinations_01;

UPDATE covidvaccinations_01
SET `date` = STR_TO_DATE(`date`, '%d.%m.%Y');

-- First I check if the table is complete

SELECT * 
FROM coviddeaths_01
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * 
FROM covidvaccinations_01
ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT location, `date`, total_cases, new_cases, total_deaths, `population`
FROM coviddeaths_01
ORDER BY 1,2;

-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT location, `date`, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM coviddeaths_01
WHERE location like '%Argentina'
ORDER BY 1,2
;

-- Looking at total cases vs population
-- Shows what percentage of Population got covid

SELECT location, `date`, total_cases, population, (total_cases/population)*100 AS PercentPositiveCases
FROM coviddeaths_01
WHERE location like '%Argentina'
ORDER BY 1,2
;

-- Looking at countries with highest infection rates compared to population
-- Chart N 3 Tableau

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPositiveCases
FROM coviddeaths_01
GROUP BY population, location
ORDER BY PercentPositiveCases DESC
;

--

SELECT location, population, `date`, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths_01
GROUP BY location, population, `date`
ORDER BY PercentPopulationInfected DESC;





-- Showing the countries with the highest death count per Population
-- The datatype of total_deaths is text, therefore I casted it as SIGNED (INT)

SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths_01
WHERE continent <> ''
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Deaths per Continent -> Chart N2 Tableau

SELECT location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths_01
WHERE continent = ''
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global Numbers --> Chart N1 Tableau

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS SIGNED)) AS Total_Deaths, SUM(CAST(new_deaths AS SIGNED))/SUM(new_cases)*100 AS Death_Percentage
FROM coviddeaths_01
WHERE continent <> ''
-- GROUP BY `date`
ORDER BY 1,2;

-- Covid Vaccination
SELECT *
FROM covidvaccinations_01;

-- Transform datatype of date

SELECT `date`,
STR_TO_DATE(`date`, '%d.%m.%Y')
FROM covidvaccinations_01;

UPDATE covidvaccinations_01
SET `date` = STR_TO_DATE(`date`, '%d.%m.%Y');


-- Join both tables

SELECT *
FROM portfolioproject_covid.coviddeaths_01 dea
JOIN portfolioproject_covid.covidvaccinations_01 vac
	ON dea.location = vac.location
    AND dea.`date` = vac.`date`;

-- Looking at total Population vs Vaccination

SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.`date`)
AS RollingPeopleVaccinated
FROM portfolioproject_covid.coviddeaths_01 dea
JOIN portfolioproject_covid.covidvaccinations_01 vac
	ON dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE dea.continent <> ''
ORDER BY 2,3;

-- USE of CTE's

WITH PopVsVac (continent, location, `date`, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.`date`)
AS RollingPeopleVaccinated
FROM portfolioproject_covid.coviddeaths_01 dea
JOIN portfolioproject_covid.covidvaccinations_01 vac
	ON dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE dea.continent <> ''
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac;

-- Temporal Table

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
`date` datetime,
Population numeric, 
New_vaccinations bigint, 
RollingPeopleVaccinated numeric
);
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.`date`)
AS RollingPeopleVaccinated
FROM portfolioproject_covid.coviddeaths_01 dea
JOIN portfolioproject_covid.covidvaccinations_01 vac
	ON dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE dea.continent <> '';
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated;

-- Create View to store data for later Visualizations

CREATE VIEW Percentpercentpopulationvaccinated AS 
SELECT dea.continent, dea.location, dea.`date`, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.`date`)
AS RollingPeopleVaccinated
FROM portfolioproject_covid.coviddeaths_01 dea
JOIN portfolioproject_covid.covidvaccinations_01 vac
	ON dea.location = vac.location
    AND dea.`date` = vac.`date`
WHERE dea.continent <> '';

-- Looking at the view

SELECT *
FROM `percentpopulationvaccinated`;


