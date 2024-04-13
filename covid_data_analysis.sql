SELECT * 
	FROM coviddeaths;
    
SELECT location, date, total_cases, new_cases, total_deaths , population
	FROM coviddeaths
	ORDER BY 1,2;
    
-- The total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
	FROM coviddeaths
	ORDER BY 1,2;
    
    
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
	FROM coviddeaths
    WHERE location LIKE '%states%'
	ORDER BY 1,2;
    
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
	FROM coviddeaths
    WHERE location = 'India'
	ORDER BY 1,2;
    
-- Total cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentpopulationinfected
	FROM coviddeaths
    WHERE location = 'India'
	ORDER BY 1,2;
    
-- Countries with highest infection rate compared to population
SELECT location, MAX(total_cases), population, MAX((total_cases/population)*100) AS max_population_infected
	FROM coviddeaths
    WHERE location = 'India'
    GROUP BY location, population
	ORDER BY max_population_infected DESC;
    
-- Countries with highest death count

SELECT location, MAX(total_deaths) AS total_deathcount
	FROM coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY location
    ORDER BY total_deathcount DESC;
    
-- Continents with highest death count

SELECT continent, MAX(total_deaths) AS total_deathcount
	FROM coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY continent
    ORDER BY total_deathcount DESC;
    
-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS deathpercentage
	FROM coviddeaths
    WHERE continent IS NOT NULL
    GROUP BY date 
	ORDER BY 1,2;
    
SELECT * 
	FROM covidvaccinations;
    
SELECT *
	FROM coviddeaths dea
    join covidvaccinations vac
    on dea.location = vac.location;
    
-- Total population vs vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
    join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    ORDER BY 2,3;
    
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	 SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
    join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    ORDER BY 2,3;

-- population vs vaccinations rolling percentage with CTE

WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	 SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
    join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    ORDER BY 2,3)
SELECT *, (rolling_people_vaccinated/population)*100
FROM popvsvac;

-- Percentage of population vaccinated with temp table
DROP TABLE IF exists percentpopulation_vaccinated ;

CREATE temporary TABLE percentpopulation_vaccinated
(
continent varchar(255),
location varchar (255),
date date,
population numeric,
new_vaccination numeric,
rolling_people_vaccinated numeric
);

INSERT INTO percentpopulation_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	 SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
    join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    ORDER BY 2,3;

SELECT *, (rolling_people_vaccinated/population)*100
FROM percentpopulation_vaccinated;

-- Creating views for later usage

CREATE view percentpopulation_vaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	 SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM coviddeaths dea
    join covidvaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
    WHERE dea.continent IS NOT NULL;
