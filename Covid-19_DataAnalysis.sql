SELECT * 
FROM covid.`covid death`
ORDER BY 3,4;

SELECT *
FROM covid.`covid vaccinated`
order by 3,4;

select location,date,total_cases,new_cases,total_deaths,population
from covid.`covid death`
order by 1,2;

#Looking at Total Cases Vs Total Deaths
#Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from covid.`covid death`
order by 1,2;

#Looking at Total Cases Vs Population
#show what percetage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as percentPopulationInfected
FROM covid.`covid death`
ORDER BY 1,2;

#Looking at Countries with Highest Infection Rate Compared to population

select location,population,max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as percentPopulationInfected
from covid.`covid death`
group by location,population
order by percentPopulationInfected desc;

#showing Countries with Highest Death Count per Population

SELECT location,MAX(IFNULL(total_deaths, 0)) AS TotalDeathCount
FROM covid.`covid death`
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

#Let's Break Things Down By Continent
#showing continents with the highest death count per population

select continent,max(Total_deaths) AS TotalDeathCount
from covid.`covid death`
where continent is not null
group by continent
order by TotalDeathCount desc;

#GLOBAL NUMBERS

select date,sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from covid.`covid death`
where continent is not null
group by date
order by 1,2;

#Looking Total Population Vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from covid.`covid death` dea
join covid.`covid vaccinated` vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

#Temp table

Drop Table if exists PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255),
    Location VARCHAR(255),
    date DATETIME,
    Population INT,
    New_vaccination INT,
    RollingPeopleVaccinated INT
);
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent,dea.location,STR_TO_DATE(dea.date, '%m/%d/%Y'),dea.population,CAST(vac.new_vaccinations AS SIGNED),
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid.`covid death` dea
JOIN covid.`covid vaccinated` vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE vac.new_vaccinations != '';

select * ,(RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;

 -- Create View to store data for later visualizations
 
create view PercentPopulationVaccinate as
 SELECT dea.continent,dea.location,STR_TO_DATE(dea.date, '%m/%d/%Y'),dea.population,CAST(vac.new_vaccinations AS SIGNED),
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM covid.`covid death` dea
JOIN covid.`covid vaccinated` vac
ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null;

select *
from PercentPopulationVaccinate