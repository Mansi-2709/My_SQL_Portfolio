Select *
From PortfolioProject..CovidDeaths$
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like 'India'
order by 1,2

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
--where location like 'India'
order by 1,2

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPercentage
From PortfolioProject..CovidDeaths$
Group by Location, population
order by InfectedPercentage desc

Select Location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location
order by TotalDeathCount desc

Select continent,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER(Partition by dea.location order by dea.location, dea.date) as RollingVaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
order by 2,3


With PopvsVac (continent, location, date, population, new_vaccination, RollingVaccination) as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) 
OVER(Partition by dea.location order by dea.location, dea.date) as RollingVaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
)
Select *, (RollingVaccination/population)*100  
From PopvsVac

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccination numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) 
OVER(Partition by dea.location order by dea.location, dea.date) as RollingVaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 Select *, (RollingVaccination/population)*100 
From #PercentPopulationVaccinated
---------------------------------------
GO
Create View PercentPopulationVaccinatedView as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(cast(vac.new_vaccinations as bigint)) 
OVER(Partition by dea.location order by dea.location, dea.date) as RollingVaccination
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
 On dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 Select *
 From PercentPopulationVaccinatedView