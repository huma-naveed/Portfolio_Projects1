/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From Portfolio_project..CovidDeaths
Where continent is not null 
order by 3,4

Select *
From Portfolio_project..CovidVaccinations
Where continent is not null 
order by 3,4


--------           1) select specfic columns Location, date, total_cases, new_cases, total_deaths, population

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_project..CovidDeaths
Where continent is not null 
order by 1,2


--                 2) Total Cases vs Total Deaths , percentage of people died
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
where continent is not null 
order by 1,2

--                  2.1) Shows likelihood of dying if you contract covid in UNited states

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2
 --               2.2) Shows likelihood of dying if you contract covid in PAKISTAN

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
Where location like '%Pakistan%'
and continent is not null 
order by 1,2


--                                          3) Total Cases vs Population
                  
				  -- 3.1) Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Portfolio_project..CovidDeaths
--Where location like '%states%'
order by 1,2


               -- 3.2 Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio_project..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


                                   -- 4)Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



--                                  5) BREAKING THINGS DOWN BY CONTINENT

--               5.1) Showing contintents with the highest death count per population in continets

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--            5.2) Showing contintents along with locationwith the highest death count per population 
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio_project..CovidDeaths
Where continent is  null 
Group by location
order by TotalDeathCount desc


--                                                6) GLOBAL NUMBERS

--               6.1) total cases, total death and death percentage by date

Select date,  total_cases,  total_deaths, ( total_deaths/ total_cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
where continent is not null 
order by 1,2

--               6.2 ) sum of new cases as per date

Select date, SUM(new_cases) as total_cases
From Portfolio_project..CovidDeaths
where continent is not null 
group by date
order by 1,2

--               6.3) sum of new cases , new deaths and death percenatge across the world

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
where continent is not null 
order by 1,2

--               6.4) sum of new cases , new deaths and death percenatge across the world per date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio_project..CovidDeaths
where continent is not null 
group by date
order by 1,2


--                                 7)  Total Population vs Vaccinations

--                       7.1) joining covid death table with covid vaccination table 
Select *
From 
Portfolio_project..CovidDeaths dea
Join 
Portfolio_project..CovidVaccinations vac
	On 
	dea.location = vac.location
	and 
	dea.date = vac.date

	                   -- 7.2) looking into total population vs vaccination

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From 
Portfolio_project..CovidDeaths dea
Join 
Portfolio_project..CovidVaccinations vac
	On 
	dea.location = vac.location
	and 
	dea.date = vac.date
	where dea.continent is not Null
	order by 1,2 ,3

--                    7.3 )Shows Percentage of Population that has recieved at least one Covid Vaccine

--7.3.1 Percentage of Population that has recieved at least one Covid Vaccine by location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ) as ppl_vacinated_per_location

From 
Portfolio_project..CovidDeaths dea
Join 
Portfolio_project..CovidVaccinations vac
	On 
	dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null 
order by 2,3

--- 7.3.2  Percentage of Population that has recieved at least one Covid Vaccine by location and oder by date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From 
Portfolio_project..CovidDeaths dea
Join 
Portfolio_project..CovidVaccinations vac
	On 
	dea.location = vac.location
	and 
	dea.date = vac.date
where dea.continent is not null 
order by 2,3


--                            8)  Using CTE to perform Calculation on Partition By in previous query


---          8.1) creating a temporay table 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *
From PopvsVac

-- 8.2) perfromimg calucation in temporay table

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




--                     9 drop temporay table 
DROP Table if exists #PercentPopulationVaccinated

-- Using Temp Table to perform Calculation on Partition By in previous query
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--                             11) Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
