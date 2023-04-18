USE covid_project; 



LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/covid_vaccinations.csv '
INTO TABLE covid_vaccinations
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM covid_deaths 
WHERE location LIKE '%states%'
ORDER BY 1,2 ;



SELECT location, date, total_cases, total_deaths 
FROM covid_deaths 
WHERE location LIKE '%states%'
AND total_cases = (SELECT max(total_cases) FROM covid_deaths WHERE location LIKE '%nited states%')
ORDER BY 1,2 ;

-- look at total cases vs population 

SELECT location, date, total_cases, population, (total_cases / population) * 100 AS cases_per_pop
FROM covid_deaths 
WHERE location LIKE 'united states' 
ORDER BY cases_per_pop ASC;

-- looking at countries with highest infection rate compared to population 

SELECT  location, max(total_cases), max(population), (max(total_cases) / max(population) ) * 100 AS infection_rate
FROM covid_deaths
GROUP BY location
ORDER BY infection_rate DESC;


-- showing continents with highest death count per population 

SELECT  continent, max(total_deaths), max(population), (max(total_deaths) / max(population) ) * 100 
AS death_rate
FROM covid_deaths
WHERE continent != ''
GROUP BY continent
ORDER BY death_rate DESC ;


SELECT date, sum(total_deaths) AS totalDeath, sum(new_deaths) / sum(new_cases) * 100 AS death_rate
FROM covid_deaths 
GROUP BY date 
ORDER BY totalDeath DESC;

SELECT  sum(total_deaths) AS totalDeath, sum(new_deaths) / sum(new_cases) * 100 AS death_rate
FROM covid_deaths; 

SELECT * FROM covid_deaths AS dea JOIN covid_vaccinations AS vac 
ON    dea.location = vac.location 
 AND  dea.date = vac.date ; 

-- looking at total population vs vaccination 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition BY dea.location ORDER BY
dea.location, dea.date) AS rollingPeopleVaccinated
FROM covid_deaths AS dea JOIN covid_vaccinations AS vac 
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent != ''
ORDER BY 1, 2, 3;

-- cte
 
WITH popVSVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated ) 
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition BY dea.location ORDER BY
dea.location, dea.date) AS rollingPeopleVaccinated
FROM covid_deaths AS dea JOIN covid_vaccinations AS vac 
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent != '')
SELECT *, rollingPeopleVaccinated/population * 100 FROM popVsVac WHERE rollingPeopleVaccinated > 0;


-- temp table 

CREATE TABLE #percentPopulationVaccinated (
Continent varchar(50), 
location varchar(50), 
date date, 
population numeric, 
new_vaccinations numeric,
rollingPeopleVaccinated numeric
) 

-- creating view to store data for later visualizations 

CREATE VIEW percentpopulationvaccinated AS 
WITH popVSVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated ) 
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition BY dea.location ORDER BY 
dea.location, dea.date) AS rollingPeopleVaccinated
FROM covid_deaths AS dea JOIN covid_vaccinations AS vac 
ON dea.location = vac.location 
AND dea.date = vac.date 
WHERE dea.continent != '')
SELECT *, rollingPeopleVaccinated/population * 100 FROM popVsVac WHERE rollingPeopleVaccinated > 0;

SELECT * FROM percentpopulationvaccinated;




