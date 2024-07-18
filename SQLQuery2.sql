-- portfolio project
SELECT * FROM portfolio.dbo.Covid_Vaccines
order by 3,4

SELECT * FROM portfolio.dbo.table1_deaths
order by 3,4

-- We need Location , date, new cases total cases, total deaths and population to work on

SELECT location, date, new_cases, total_cases, total_deaths, population
FROM portfolio.dbo.table1_deaths
ORDER BY 1,2

-- Looking at total death vs total cases

SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 AS death_percent
FROM portfolio.dbo.table1_deaths
Where location like 'India'
ORDER BY 1,2

-- looking for total cases vs population

SELECT location, date, total_cases,population, total_deaths, (total_deaths/ total_cases)*100 AS death_percent, (total_cases/ population)*100 AS cases_percentage
FROM portfolio.dbo.table1_deaths
Where location like 'India'
ORDER BY 1,2

-- looking at countries with highest infection rate compared to population

SELECT location, population ,MAX(total_cases) AS Infection_count,  MAX((total_cases/ population))*100 AS cases_percentage
FROM portfolio.dbo.table1_deaths
GROUP BY location,population
ORDER BY cases_percentage DESC

-- countries showing highest death count

SELECT location ,MAX(cast(total_deaths as int)) As Totaldeathcount
FROM portfolio.dbo.table1_deaths
where continent is not null
group by location
order by Totaldeathcount desc

-- let's see by continent

SELECT continent, SUM(cast(total_deaths as int)) As Totaldeathcount
FROM portfolio.dbo.table1_deaths
group by continent
order by Totaldeathcount desc

-- continents with highest death count

SELECT	continent, MAX(cast(total_deaths as int)) As Totaldeathcount
from portfolio.dbo.table1_deaths
where continent is not null
group by continent
order by Totaldeathcount desc

-- global numbers

SELECT  SUM(new_cases) as newcases, SUM(cast(new_deaths as int)) as newdeaths , SUM(cast(new_deaths as int)) /SUM(new_cases) *100 as death_percent--, total_deaths, (total_deaths/ total_cases)*100 AS death_percent
FROM portfolio.dbo.table1_deaths
where continent is not null
--group by date
order by 1,2


select* from portfolio.dbo.Covid_Vaccines

SELECT*
FROM portfolio.dbo.table1_deaths as dea
join portfolio.dbo.Covid_Vaccines as vac
on dea.location=vac.location and dea.date= vac.date

-- looking at total population vs total vaccination

SELECT dea.continent, dea.location ,dea.population, dea.date, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int) ) OVER (partition by dea.location order by dea.location , dea.date) As Total_vaccination
FROM portfolio.dbo.table1_deaths as dea
join portfolio.dbo.Covid_Vaccines as vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null 
 --and dea.location = 'India'
order by 2,3

-- using a CTE

WITH Percent_Vaccinated (Continent , Location, Population, Date, New_Vaccinations, Rolling_vaccinated)
as(
SELECT dea.continent, dea.location ,dea.population, dea.date, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int) ) OVER (partition by dea.location order by dea.location,dea.date) As Total_vaccination
FROM portfolio.dbo.table1_deaths as dea
join portfolio.dbo.Covid_Vaccines as vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null 
 --and dea.location = 'India'

)
SELECT *, (Rolling_vaccinated/ Population)*100 as Percent_vaccinated
from Percent_Vaccinated
where Location ='India'
order by Location, Date

-- usinf temp table

drop table if exists #Temp_Vaccinated
create table #Temp_Vaccinated(
Continent NVARCHAR(50),
Location NVARCHAR(50),
Population int,
Date datetime,
New_Vaccinated INT,
Rolling_Vaccinated INT
);
Insert into #Temp_Vaccinated

SELECT dea.continent, dea.location ,dea.population, dea.date, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int) ) OVER (partition by dea.location order by dea.location,dea.date) As Total_vaccination
FROM portfolio.dbo.table1_deaths as dea
join portfolio.dbo.Covid_Vaccines as vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null 
 --and dea.location = 'India'

 SELECT * ,(Rolling_Vaccinated * 100.0 / NULLIF(Population, 0))as Percent_vaccinated
from #Temp_Vaccinated
where Location ='India'
order by Location, Date

-- creating view for later data visualisation

create view Temp_Vaccinated as
SELECT dea.continent, dea.location ,dea.population, dea.date, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int) ) OVER (partition by dea.location order by dea.location,dea.date) As Total_vaccination
FROM portfolio.dbo.table1_deaths as dea
join portfolio.dbo.Covid_Vaccines as vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null 
 --and dea.location = 'India'

 select * from Temp_Vaccinated