use covid_project; 



LOAD DATA LOCAL INFILE '/Users/tonykim/Downloads/covid_vaccinations.csv '
INTO TABLE covid_vaccinations
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as DeathPercentage
from covid_deaths 
where location like '%states%'
order by 1,2 ;



select location, date, total_cases, total_deaths 
from covid_deaths 
where location like '%states%'
and total_cases = (select max(total_cases) from covid_deaths where location like '%nited states%')
order by 1,2 ;

-- look at total cases vs population 

select location, date, total_cases, population, (total_cases / population) * 100 as cases_per_pop
from covid_deaths 
where location like 'united states' 
order by cases_per_pop asc;

-- looking at countries with highest infection rate compared to population 

select  location, max(total_cases), max(population), (max(total_cases) / max(population) ) * 100 as infection_rate
from covid_deaths
group by location
order by infection_rate desc;


-- showing continents with highest death count per population 

select  continent, max(total_deaths), max(population), (max(total_deaths) / max(population) ) * 100 
as death_rate
from covid_deaths
where continent != ''
group by continent
order by death_rate desc ;


select date, sum(total_deaths) as totalDeath, sum(new_deaths) / sum(new_cases) * 100 as death_rate
from covid_deaths 
group by date 
order by totalDeath desc;

select  sum(total_deaths) as totalDeath, sum(new_deaths) / sum(new_cases) * 100 as death_rate
from covid_deaths; 

select * from covid_deaths as dea join covid_vaccinations as vac 
on    dea.location = vac.location 
 and  dea.date = vac.date ; 

-- looking at total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by 
dea.location, dea.date) as rollingPeopleVaccinated
from covid_deaths as dea join covid_vaccinations as vac 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent != ''
order by 1, 2, 3;

-- cte
 
with popVSVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated ) 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by 
dea.location, dea.date) as rollingPeopleVaccinated
from covid_deaths as dea join covid_vaccinations as vac 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent != '')
select *, rollingPeopleVaccinated/population * 100 from popVsVac where rollingPeopleVaccinated > 0;


-- temp table 

create table #percentPopulationVaccinated (
Continent varchar(50), 
location varchar(50), 
date date, 
population numeric, 
new_vaccinations numeric,
rollingPeopleVaccinated numeric
) 

-- creating view to store data for later visualizations 

create view percentpopulationvaccinated as 
with popVSVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated ) 
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(vac.new_vaccinations) over (partition by dea.location order by 
dea.location, dea.date) as rollingPeopleVaccinated
from covid_deaths as dea join covid_vaccinations as vac 
on dea.location = vac.location 
and dea.date = vac.date 
where dea.continent != '')
select *, rollingPeopleVaccinated/population * 100 from popVsVac where rollingPeopleVaccinated > 0;

select * from percentpopulationvaccinated;




