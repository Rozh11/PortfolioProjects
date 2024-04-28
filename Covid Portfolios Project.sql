-- Covid data from 2020 - 2024 to explore and organise for later visualization in TableAU

USE PortfolioProject;

SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4;

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2


-- Looking at total Cases vs Total Deaths 
-- convert both values column to integer

-- ALTER TABLE PortfolioProject..CovidDeaths
-- ALTER COLUMN total_deaths INT

-- shows possiblities of dying in the country if contracted covid 
SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100
as Death_Percentage
FROM PortfolioProject..CovidDeaths 
WHERE location like '%states%'
and continent is not null
order by 1,2


-- Looking at total cases vs population
-- shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100
as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
WHERE location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/MAX(population) )*100
as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths 
--WHERE location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Deaths Count per Popultion

SELECT Location, MAX(total_deaths) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths 
-- WHERE location like '%states%'
WHERE continent is not null
Group by location, population
order by TotalDeathsCount desc

-- NOW TIME TO BREAK DOWN BY CONTINENT


-- showing continent with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths 
-- WHERE location like '%states%'
WHERE continent is not null
Group by continent
order by TotalDeathsCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths
FROM PortfolioProject..CovidDeaths 
where continent is not null
Group by date
order by 1,2



SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0  -- Return 0 if total_cases is 0
        ELSE (SUM(new_deaths)) / SUM(new_cases)*100 
    END AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- 
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths) /SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths 
WHERE continent IS NOT NULL;

---------- Covid Vaccinations Table with Covid Death Table ---------

-- Looking at total population vs vaccincations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date = vac.date
Where dea.continent is not null
 order by 2,3


 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date = vac.date
Where dea.continent is not null
 order by 2,3


 -- Population vs Vacination --
 -- USE CTE  Method 
 
 With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
 as (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date = vac.date
Where dea.continent is not null
 )
 SELECT *, ( RollingPeopleVaccinated/population)*100  as PopvsVac
 FROM PopvsVac


 -- TEMP TABLE method

 Drop Table if exists #PercentPopulationVaccinated
 Create table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date = vac.date
Where dea.continent is not null

SELECT *, ( RollingPeopleVaccinated/population)*100  as PopvsVac
 FROM #PercentPopulationVaccinated



 -- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location 
 and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select * 
From PercentPopulationVaccinated



Create View ContinentWithHighestDeath as

SELECT continent, MAX(total_deaths) as TotalDeathsCount
FROM PortfolioProject..CovidDeaths 
-- WHERE location like '%states%'
WHERE continent is not null
Group by continent
--order by TotalDeathsCount desc
