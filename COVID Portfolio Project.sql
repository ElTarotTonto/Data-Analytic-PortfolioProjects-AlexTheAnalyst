select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


--Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- Looking at Total Cases Vs Total Deaths
--Shows the likelihood of dying if you contract Covid in your country. My country is United States
  
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
order by 1,2

---Above is not correct. Nulls are interfering with selected data
--Furthermore, Datatype of Deathpercentage is shown as Integer. 
--Needs to be displayed as a Float to ensure realistic percentages
--Last, I need to set a command to select data only in US.


--***ADJUSTMENT BELOW*****
  
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where location like '%states%'
and continent is not null
order by 1,2



-- Looking at Total Cases vs population 
--Shows what percentage of Population got Covid

Select location, date, total_cases, population, (NULLIF(CONVERT(float, total_cases),0)/population)*100 as InfectionPercentage
from PortfolioProject..covidDeaths
Where location like '%states%'
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

Select location, Max(total_cases) as HighestInfectionCount, population, (Max(NULLIF(CONVERT(float, total_cases),0)/population))*100 as InfectionPercentage
from PortfolioProject..covidDeaths
--Where location like '%states%'
group by location, population
order by InfectionPercentage Desc

-- Showing Countries with Highest Death Count per Population

Select location, Max(Total_deaths) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
--Where location like '%states%'
group by location
order by TotalDeathCount Desc

--Continent with highest death count per population

Select continent, Max(Total_deaths) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
--Where location like '%states%'
group by continent
order by TotalDeathCount Desc

--Countries with highest death count per population

Select location, Max(Total_deaths) as TotalDeathCount
from PortfolioProject..covidDeaths
where continent is not null
--Where location like '%states%'
group by location
order by TotalDeathCount Desc

-- GLOBAL NUMBERs

Select  date, sum(new_cases) as totalcasesperdate, sum(new_deaths) as totaldeathsperdate
,(CONVERT(float, sum(new_deaths)) / NULLIF(CONVERT(float, sum(new_cases)), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
group by date
order by 1,2

Select sum(new_cases) as totalcasesperdate, sum(new_deaths) as totaldeathsperdate
,(CONVERT(float, sum(new_deaths)) / NULLIF(CONVERT(float, sum(new_cases)), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
order by 1,2


select *
from PortfolioProject..CovidVaccinations



--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Use CTE

with PopvsVac (Continent,Location,Date,Population, New_Vaccinations,
RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
select *, (Convert(float,RollingPeopleVaccinated)/nullif(convert(float,Population),0))*100
from PopvsVac


----TEMP TABLE
drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *, (Convert(float,RollingPeopleVaccinated)/nullif(convert(float,Population),0))*100
from #PercentPopulationVaccinated


--Creating View to Store data for later visualizations


create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

select *
from PercentPopulationVaccinated
