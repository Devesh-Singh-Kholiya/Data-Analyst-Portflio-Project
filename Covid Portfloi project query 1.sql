select * from PortfolioProject..CovidDeaths
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4


Select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths
---shows the likelihhod of you dying of covid

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--looking at the total cases vs population
--shows what percent of population got covid
Select Location,date,population,total_cases,(total_cases/population)*100 as percentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--country with highest infection rate wrt to population
Select Location,population,max(total_cases) as highestInfection,max((total_cases/population))*100 as percentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
order by percentPopulationInfected desc

--using continents most deaths bt continent
select continent,sum(cast(new_deaths as bigint)) as total_deaths_by_continent
from PortfolioProject..CovidDeaths
 where continent is not null
 group by continent 
 order by total_deaths_by_continent desc

--showing the countries with the highest death count per population
select location ,max(cast(total_deaths as bigint)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathcount desc


--GLOBAL NUMBERS

select  sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercent
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


---------------------------------------------
--Looking a s total population vs vaccination (rolling sum of vaccinations each day)
select dea.continent,dea.location ,dea.date, dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingSumOfPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3


--using CTE
with PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingSumOfPeopleVaccinated)
as
(
select dea.continent,dea.location ,dea.date, dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingSumOfPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingSumOfPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
NEw_vaccinations numeric,
RollingSumOfPeopleVaccinated  numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location ,dea.date, dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingSumOfPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingSumOfPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating view to store data for later visulalization


Create View PercentPopulationVaccinated as
select dea.continent,dea.location ,dea.date, dea.population,vac.new_vaccinations
,sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingSumOfPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3



select * from PercentPopulationVaccinated