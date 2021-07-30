select *
From PortfolioProject..C19D
WHERE continent is not null
Order by 3,4

--select *
--From PortfolioProject..C19Vaccine
--Order by 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ..C19D
Order by 1,2

-- Looking at total cases vs total deaths
-- Likelihood of dying if you contract COVID-19 in location
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as deathperc
FROM ..C19D
WHERE location like '%states%'
and continent is not null
Order by 1,2

--Looking at Total Cases vs Population
--Showing what % of people got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as populationperc
FROM ..C19D
WHERE location like '%states%'
Order by 1,2

-- Looking at country w/ highest infection rate compare to populations
SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as infectionperc
FROM ..C19D
--WHERE location like '%states%'--
Group by location,population
Order by infectionperc desc

-- Showing the countries with Highest death count/population 
SELECT location,Max(cast(total_deaths as int)) as TotalDeathCount	
FROM ..C19D
--WHERE location like '%states%'--
WHERE continent is not null
Group by location
Order by TotalDeathCount desc

--Break things down by continent 


--Showing continents with the highest death count per population
SELECT location,Max(cast(total_deaths as int)) as TotalDeathCount	
FROM ..C19D
--WHERE location like '%states%'--
WHERE continent is null
Group by location
Order by TotalDeathCount desc

--Global numbers 

SELECT date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death,sum(cast(new_deaths as int))/Sum(new_cases)*100 deathperc
FROM ..C19D
--WHERE location like '%states%'
where continent is not null
Group by date
Order by 1,2

SELECT sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death,sum(cast(new_deaths as int))/Sum(new_cases)*100 deathperc
FROM ..C19D
--WHERE location like '%states%'
where continent is not null
Order by 1,2


-- Looking at Total population vs Vaccinations 

Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM..C19D dea
Join PortfolioProject..C19Vaccine vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--CTE

WITH PopVsVac(continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM..C19D dea
Join PortfolioProject..C19Vaccine vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (rollingpeoplevaccinated/population)*100 
From PopVsVac

--Creating view for Tableau 

Create view percentpeoplevaccinated as 
Select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
FROM..C19D dea
Join PortfolioProject..C19Vaccine vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
