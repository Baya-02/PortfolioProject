select * from covid_data
order by 3, 4;

select * from covidvac
order by 3, 4;

-- Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from covid_data
order by 1, 2;

--Loking at total cases vs total deaths

select location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
from covid_data
where location like 'United%'
order by 1, 2;

-- Looking at Total Case vs Population 
select location, date, total_cases, population, 
(total_cases/population)*100 as "CasePercentage"
from covid_data
where location='Turkey'
order by 1, 2;

-- Looking at countries with high Infection rate compared to Population
select location,population,  max(total_cases) as "HighestInfectionCount",  
max((total_cases/population))*100 as "PercentPopulationInfected"
from covid_data
WHERE 
    total_cases IS NOT NULL AND population IS NOT NULL
group by location,population
order by 4 desc;

-- Showing Countries with highest Death Count Per Population

select location, max(cast(total_deaths as int)) as "TotalDeathCount"
from covid_data
WHERE location IS NOT NULL and continent is not null
group by location
order by "TotalDeathCount" desc;

--LET'S BREAK THIS DOWN BY CONTINENTS
-- Showing Continents with the highest deaths count per population

select location, max(cast(total_deaths as int)) as "TotalDeathCount"
from covid_data
WHERE continent is  null
group by location
order by "TotalDeathCount" desc;


-- Global Numbers
select  sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,  
round(sum(new_deaths)/sum(new_cases)*100, 2) as DeathPercentage
from covid_data
where  continent is not null
order by 1, 2;

-- Looking at total Population vs Total Vaccination

select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location 
                                order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_data dea
left join covidvac vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2 , 3;

-- Use CTE
 with PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location 
                                order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_data dea
left join covidvac vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2 , 3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;


-- Temp Table

Create table PercentPopulationVaccinated
(
continent varchar(250), 
location varchar(250), 
date date, 
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
);


insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location 
                                order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_data dea
left join covidvac vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null;

select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;

-- Creating View for later visualization

create view PercentPopulationVaccinated1
as
select dea.continent, dea.location, dea.date, 
dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location 
                                order by dea.location, dea.date) as RollingPeopleVaccinated
from covid_data dea
left join covidvac vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null



















