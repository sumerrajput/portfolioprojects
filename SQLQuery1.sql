--SELECT * FROM portfolio_tutorial..CovidDeaths$
--ORDER BY 3,4


--SELECT * FROM portfolio_tutorial..CovidVaccinations$
--ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
from portfolio_tutorial..CovidDeaths$

--total cases vs population affected
 SELECT Location, date, total_cases, population, (total_cases/population)*100 as totalpopulation
from portfolio_tutorial..CovidDeaths$
where location like 'India' 

-- countries with highest infection rate
SELECT Location, population, Max(total_cases) as highinfection, Max((total_cases/population)) *100 
as percntpopulationinfected
from portfolio_tutorial..CovidDeaths$
--where location like 'India'
Group by location, population
order by percntpopulationinfected desc

-- countries with highest death rate

SELECT Location, Max(cast(total_deaths as int)) as deathrate 
from portfolio_tutorial..CovidDeaths$
where continent is not null
Group by location
order by deathrate  desc

--breaking down through contiment
SELECT continent, Max(cast(total_deaths as int)) as deathrate 
from portfolio_tutorial..CovidDeaths$
where continent is not null
Group by continent
order by deathrate  desc

--global breakdown


SELECT date, sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as deathrate , sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercnt
from portfolio_tutorial..CovidDeaths$
where continent is not null
Group by date

SELECT  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as deathrate , sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercnt
from portfolio_tutorial..CovidDeaths$
where continent is not null




-- now for vaccination data

select * 
from portfolio_tutorial..CovidVaccinations$


--looking at total population vs vaccination


select * 
from portfolio_tutorial..CovidDeaths$ dea
join portfolio_tutorial..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as people_vaccinated
--(people_vaccinated/population)

from portfolio_tutorial..CovidDeaths$ dea
join portfolio_tutorial..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--using cte

with popvsvac (continent, location,date,population,new_vaccinations,people_vaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as people_vaccinated
--(people_vaccinated/population)

from portfolio_tutorial..CovidDeaths$ dea
join portfolio_tutorial..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

)
select *,(people_vaccinated/population)*100
from popvsvac

-- temp table

drop table if exists #percntpeoplevaccinated
create table #percntpeoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
people_vaccinated numeric
)

insert into #percntpeoplevaccinated
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as people_vaccinated
--(people_vaccinated/population)

from portfolio_tutorial..CovidDeaths$ dea
join portfolio_tutorial..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *,(people_vaccinated/population)*100
from #percntpeoplevaccinated



-- creating view for further use

create view percntpeoplevaccinated as
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location
,dea.date) as people_vaccinated
--(people_vaccinated/population)

from portfolio_tutorial..CovidDeaths$ dea
join portfolio_tutorial..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from percntpeoplevaccinated