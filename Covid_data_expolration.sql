/** carrying out exploratory data analysis on the covid data set between 2021 and
2022**/


select cd.location, date,population, total_deaths,new_deaths
from covid_deaths cd
order by 1,2

-- death rate 
select location, population, total_deaths, ROUND((total_deaths/population),5) as death_rate
from covid_deaths cd
where total_deaths  notnull 
order by death_rate desc;

--death rate in each continent
select location, population,sum(new_deaths) as total_deaths,(sum(new_deaths)/cast(population as decimal))*100 death_rate
from covid_deaths
where continent is null and location not in('High income', 'Lower middle income', 'Low income', 'Upper middle income', 'European Union', 'World')
group by location, population
order by death_rate desc;

-- fatalty rate in each continents
select location,
sum(new_cases) as total_cases,
sum(new_deaths) as total_deaths,
(sum(new_deaths)/sum(new_cases))*100 fatality_rate
from covid_deaths
where continent is null and location not in('High income', 'Lower middle income', 'Low income', 'Upper middle income', 'European Union', 'World')
group by location, population
order by fatality_rate desc;

-- death percentage
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths cd
 order by 1,2 

--death percentage in india
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covid_deaths cd
where location = 'India' 
order by 1,2 

-- infection percentage 
select location,date, population, total_cases, (total_cases/population)*100 as death_percentage
from covid_deaths cd
where location = 'India' 
order by 1,2 

-- death percent
select location,max(total_deaths) as total_deaths, (max(total_deaths)/population)*100 as death_percent
from covid_deaths cd
where continent notnull and total_deaths notnull
group by location, population
order by total_deaths desc

--infection percent
select location,max(total_cases) as total_cases, (max(total_cases)/population)*100 as infection_percent
from covid_deaths cd
where continent notnull and total_cases notnull
group by location, population
order by total_cases desc

-- most cases and deaths in a single day for each country

select location,max(new_cases) as most_cases, max(new_deaths)as most_deaths
from covid_deaths cd
where continent notnull and new_cases notnull
group by location
order by most_cases desc

--percent of people vaccinated from total population
SELECT
    cd.location,
    cv.population,
    SUM(cv.new_vaccinations) AS total_new_vaccinations,
    (cast(SUM(cv.new_vaccinations)as decimal) / cv.population)*100 AS percent_vaccinated
FROM covid_deaths AS cd
JOIN covid_vaccines AS cv
ON cd.date = cv.date
AND cd.location = cv.location
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, cv.population
ORDER BY cd.location;

-- finding the no of new vaccination and then find the percent of perople vaccinated

WITH new_vac(location, date, population,new_vaccinations, rolling_vacc) 
AS (
    SELECT 
        cd.location, 
        cd.date,
		cd.population,
		cv.new_vaccinations,
        SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vacc
    FROM 
        covid_deaths AS cd
    JOIN 
        covid_vaccines AS cv
    ON 
        cd.date = cv.date
        AND cd.location = cv.location
    WHERE 
        cd.continent IS NOT NULL and cd.population !=0
)
SELECT 
   *, (rolling_vacc / cast(population as numeric))*100 AS vaccination_percent
FROM 
    new_vac;

-- lets take a look at the cases and death and the attributes of these people tested positive
select cd.location, cd.date,cd.new_cases, cd.new_deaths, 
cv.female_smokers,
cv.male_smokers, cv.median_age,cv.aged_65_older,cv.aged_70_older
from covid_deaths cd
join covid_vaccines cv
on cd.location = cv.location and
cd.date = cv.date
where cd.continent is not null

-- fatality rate, infection rate and vaccination coverage for each countries


select cd.location,
(sum(cd.new_deaths)/sum(cd.new_cases))*100 fatality_rate,
(sum(cd.new_cases)/cast(cd.population as decimal))*100 infection_rate,
(sum(cv.new_vaccinations)/cast(cd.population as decimal)) vaccinaction_coverage
from covid_deaths cd
join covid_vaccines cv
on cd.location = cv.location and
cd.date = cv.date
where cd.continent notnull and cd.population>0 and cd.new_cases>0
group by cd.location, cd.population
