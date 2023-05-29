SELECT *
FROM coviddeaths
order by 2,3

select *
from CovidVaccinations
order by 2,3

select continent, location, date, total_cases, new_cases, total_deaths, new_deaths, population
from CovidDeaths
order by 2,3

--percentage of total death with respect to total daily cases 
--likelihood of dying if you contracted covid
--view

select location, date, total_cases, total_deaths, round((convert(int,total_deaths)/total_cases),4) *100 as deathpercent
from CovidDeaths
where continent is not null
---where location like '%Nigeria%'
order by 1,2

--percentage of populaton had covid

select location, date, population, total_cases, total_cases/population *100 as deathpercent
from CovidDeaths
where continent is not null
--And location like '%Nigeria%'
order by 1,2

--location with highest infection count per population
--view

select location, population, max(total_cases) as totalcases, max(total_cases)/population * 100 as highestpercentageinfected
from CovidDeaths
where continent is not null
group by location, population 
order by highestpercentageinfected desc


--percentage of the total population that died
-- total death by location

select 
	location, 
	population, 
	max(cast(total_deaths as int)) as totaldeathcount
	--max(cast(total_deaths as int))/population *100 as totaldeathpercent
from CovidDeaths
where continent is not null
group by location, population
order by totaldeathcount desc


-- LOOKING AT THE CONTINENT
-- Total infected by continent 

select 
	cd.location, 
	population, 
	max(cast(total_deaths as int)) as totaldeathcount,
	max(total_cases) as totalcases,
	max(cv.total_vaccinations) as total_vaccinations
	--max(cast(total_deaths as int))/population *100 as totaldeathpercent
FROM CovidDeaths cd
INNER JOIN CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is null
and cd.location not in ('World', 'European Union', 'International')
group by cd.location, population
order by totaldeathcount desc


--GLOBAL numbers
--daily deaths and cases
--view

SELECT 
	cd.date, 
	sum(new_cases) as totalcases, 
	sum(cast(new_deaths as int)) as totaldeaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage,
	sum(convert(int, cv.new_vaccinations)) as total_vaccinations
FROM CovidDeaths cd
INNER JOIN CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
group by cd.date
order by cd.date


--world total cases vs total deaths



--Total world population

--SELECT  
--	sum(totalpopulation) as worldpopulation
--from (SELECT  
--		location,
--		max(population) as totalpopulation
--	from CovidDeaths
--	where continent is not null
--	and location not in ('World', 'European Union', 'International')
--	group by location) as sub


--Joining the vaccination table to see the number of people vaccinated each day
with PopVac as (
SELECT 
	cd.continent,
	cd.location,
	cd.date, 
	population,
	cv.new_vaccinations,
	--cv.total_vaccinations,
	sum(convert(int, cv.new_vaccinations)) over(partition by cd.location order by cd.location, cd.date) as rollingvaccinations
FROM CovidDeaths cd
INNER JOIN CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null)
--order by 2,3

--percentage of populaton that got vaccinated per location
-- view

select
	location,
	max(population) as population,
	max(rollingvaccinations) as totalvaccinated,
	max(rollingvaccinations)/max(population) * 100 as percentagevaccinated
from PopVac
group by location
order by percentagevaccinated desc

--create views
-- statistics of world data
-- view1

create view globaldata as
select 
	sum(distinct population) as worldpopulation, 
	sum(new_cases) as totalcases, 
	sum(new_cases)/sum(distinct population)*100 as percentageofworldcases,
	sum(cast(new_deaths as int)) as totaldeaths, 
	sum(cast(new_deaths as int))/sum(distinct population) * 100 as percentageworlddeaths,
	sum(convert(int,cv.new_vaccinations)) as worldvaccinated,
	sum(convert(int,cv.new_vaccinations))/sum(distinct population)*100 as percentworldvaccinated,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentagebycases
from CovidDeaths cd
join CovidVaccinations cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent is not null
--and cd.location not in ('World', 'European Union', 'International')
--order by 2 desc

--view2

create view dailystatistics1 as
SELECT 
	cd.date, 
	sum(new_cases) as totalcases, 
	sum(cast(new_deaths as int)) as totaldeaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage,
	sum(cast(cv.new_vaccinations as int)) as total_vaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location =cv.location
and cd.date = cv.date
where cd.continent is not null
group by cd.date
order by date

--view3

create view locationNumbers as
select 
	cd.location, 
	population, 
	max(cast(total_deaths as int)) as totaldeathcount,
	max(total_cases) as totalcases,
	sum(convert(int,cv.new_vaccinations)) as total_vaccinations
	--max(cast(total_deaths as int))/population *100 as totaldeathpercent
FROM CovidDeaths cd
INNER JOIN CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--and cd.location not in ('World', 'European Union', 'International')
group by cd.location, population
--order by totaldeathcount desc
