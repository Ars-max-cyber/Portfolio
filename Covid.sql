SELECT 
    location, date, total_cases, new_cases, population
FROM
    portfolio.death
ORDER BY 1 , 2

---Total cases vs total deaths
---chance of death if get effect by covid

SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS death_percentage
FROM
    portfolio.death
WHERE
    location LIKE '%india%'
ORDER BY 1 , 2

---Total cases vs population
---percentage of population got covid

SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS population_percentage
FROM
    portfolio.death
WHERE
    location LIKE '%india%'
ORDER BY 1 , 2

---looking at countries with highest infectioncounts

select location, 
       population, 
       max(total_cases) as HighestInfection, 
       max((total_cases/population))*100 as Infected_Population_Percentage
from portfolio.death
group by location, population
order by Infected_Population_Percentage desc

---total no.of death by covid of each continents

select continent,
	   sum(cast(total_deaths as unsigned)) as deaths
from portfolio.death
where continent is not null 
group by continent
order by deaths desc

---maximun deaths by covid of each countries   

select location,
	   max(cast(total_deaths as unsigned)) as deaths
from portfolio.death
where continent is not null 
group by location
order by deaths desc


select sum(new_cases) as totalcases, 
	   sum(cast(new_deaths as unsigned)) as totaldeaths, 
       sum(cast(new_deaths as unsigned)) / sum(new_cases)*100 as deathPercentage
from 
     portfolio.death
where 
	 continent is not null
order by 1,2


SET SESSION wait_timeout = 28800;
SET SESSION interactive_timeout = 28800;
with popVSvac (continent, location, date, population, new_vaccinations, rollingvaccinate)
as
(
select dt.continent, 
       dt.location, 
       dt.date, 
       dt.population, 
       vc.new_vaccinations,
       sum(cast(vc.new_vaccinations as unsigned)) over (partition by dt.location, dt.date) as rollingvaccinate
from vaccines vc
join death dt
     on vc.location = dt.location
     where dt.continent is not null
    )
    select * from popVSvac


drop table if exists popVSvac0;

create temporary tabel popVSvac0
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacinnation numeric,
rollingvaccinate numeric
);

insert into popVSvac0(continent, location, date, population, new_vaccinations, rollingvaccinate)
select dt.continent, 
       dt.location, 
       dt.date, 
       dt.population, 
       vc.new_vaccinations,
       sum(cast(vc.new_vaccinations as unsigned)) over (partition by dt.location, dt.date) as rollingvaccinate
from vaccines vc
join death dt
     on vc.location = dt.location
     where dt.continent is not null


DROP TABLE IF EXISTS popVSvac0;

CREATE TEMPORARY TABLE popVSvac0 (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingvaccinate NUMERIC
);

INSERT INTO popVSvac0 (continent, location, date, population, new_vaccinations, rollingvaccinate)
SELECT 
    dt.continent, 
    dt.location, 
    dt.date, 
    dt.population, 
    vc.new_vaccinations,
    rollingvaccinate_sum.rollingvaccinate
FROM 
    death dt
JOIN 
    vaccines vc
    ON vc.location = dt.location
JOIN (
    SELECT 
        dt.location, 
        dt.date,
        SUM(CAST(vc.new_vaccinations AS UNSIGNED)) AS rollingvaccinate
    FROM 
        vaccines vc
    JOIN 
        death dt
        ON vc.location = dt.location
    WHERE 
        dt.continent IS NOT NULL
    GROUP BY 
        dt.location, dt.date
) AS rollingvaccinate_sum 
ON rollingvaccinate_sum.location = dt.location AND rollingvaccinate_sum.date = dt.date;



SET @start_date = '2020-01-01';
SET @end_date = '2020-02-30';

DROP TABLE IF EXISTS popVSvac0;

CREATE TEMPORARY TABLE popVSvac0 (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingvaccinate NUMERIC
);

INSERT INTO popVSvac0 (continent, location, date, population, new_vaccinations, rollingvaccinate)
SELECT 
    dt.continent, 
    dt.location, 
    dt.date, 
    dt.population, 
    vc.new_vaccinations,
    SUM(CAST(vc.new_vaccinations AS UNSIGNED)) over (partition by dt.location order by dt.location, dt.date) AS rollingvaccinate
FROM 
    death dt
JOIN 
    vaccines vc 
    ON vc.location = dt.location
WHERE 
    dt.continent IS NOT NULL 
    AND dt.date BETWEEN @start_date AND @end_date
GROUP BY 
    dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations;
    
    select *,(rollingvaccinate/population)*100
    from popVSvac0

  ---creating --view
create view popVSvsac0 as 
select
      dt.continent,
      dt.location,
      dt.date,
      dt.population,
      vc.new_vaccinations,
      sum(cast(vc.new_vaccinations as unsigned)) over (partition by dt.location order by dt.date) as RollingVaccinate
      from death dt
      join vaccines vc 
      on dt.location = vc.location
      where dt.continent is not null;
      





    
   
     





 




