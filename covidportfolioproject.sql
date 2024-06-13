--select *
--from PortfolioProject.dbo.CovidDeaths
--order by 3,4

--select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--selecting useful data

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths
order by 1,2

--total cases vs total deaths(death ratio)(likelihood of dying if u have covid)
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject.dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--total cases vs population(shows what percentage of population got covid)
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

-- country with highest infection rate with resepct to population
select location,population,max(total_cases) as hghestinfectioncount,max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population 
order by PercentPopulationInfected desc

--showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

--breaking things down by continent

--showing continents with highest death count per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--global numbers

select date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

--total death percentage grouped by date
select date,sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2

--total death percentage
select sum(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

--looking at total population vs vaccinations

select *
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date

--CUMMULATIVE SUM OF NEW VACCINAIONS FOR EACH LOCATION ORDERED BY LOCATION AND DATA
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)

SELECT *,( RollingPeopleVaccinated/Population)*100
from PopvsVac


--temp table


drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Loaction nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

SELECT *,( RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for vizualisation


create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast (vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3 order by clause is invalid in views

select *
from PercentPopulationVaccinated