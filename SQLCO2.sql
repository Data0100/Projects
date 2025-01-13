/*
Exploring CO2 Data  
*/

Select *
From CO2portfolio.dbo.CO2emissionbycountries

-- Select Data that interest us

Select Country, Years, CO2emission,Area, Population2022
From CO2portfolio..CO2emissionbycountries
Where CO2emission is not null 
order by 1,2

-- CO2 Emission vs Area
-- Shows CO2 by area for the UK

Select Country, Years, CO2emission,Area, Population2022, (CO2emission/Area) as CO2bykm2
From CO2portfolio..CO2emissionbycountries
Where Country like '%kingdom%'
and Area is not null 
order by 1,2


-- Countries with Highest CO2 emission compared to the population

Select Country,Population2022 , MAX(CO2emission) as HighestCO2 
,Max((CO2emission/Population2022))*100 as CO2byPercentPopulation
From CO2portfolio..CO2emissionbycountries
Where Population2022 is not null 
Group by Country, Population2022
order by CO2byPercentPopulation desc



-- Global CO2 emission

Select SUM(CO2emission) as totalEmission, Years
From CO2portfolio..CO2emissionbycountries
where CO2emission is not null 
Group By Years
order by 2

-- Global Population  from 1951 to 2020
-- Global CO2 vs global Population from 1951 to 2020
-- skill used: Join

Select SUM(emi.CO2emission) as totalEmission, emi.Years, pop.Population
, SUM(emi.CO2emission)/pop.Population as GlobalCO2byPopulation
From CO2portfolio..CO2emissionbycountries emi
Join CO2portfolio..WorldPopulationGrowth pop
	On emi.Years = pop.Years
Group By emi.Years, pop.Population
order by 2

--Cummulative CO2 emission CO2 by country

Select Country, Years
, SUM(CO2emission) OVER (Partition by Country Order by Country, Years) as CummulativeCO2byCountry
From CO2portfolio..CO2emissionbycountries
where CO2emission is not null 

-- Using CTE to find Global CO2 vs global Population from 1951 to 2020
-- skill used: CTE

With EmiPop (totalEmission, Years, Population)
as
(
Select SUM(emi.CO2emission) as totalEmission, emi.Years, pop.Population
From CO2portfolio..CO2emissionbycountries emi
Join CO2portfolio..WorldPopulationGrowth pop
	On emi.Years = pop.Years
Group By emi.Years, pop.Population
)
Select *, totalEmission/Population as GlobalCO2byPopulation
From EmiPop
order by 2

-- Using Temp Table to find Global CO2 vs global Population from 1951 to 2020
-- skill used: Temp Table

DROP Table if exists #totEmi
Create Table #totEmi
(
totalEmission numeric,
Years numeric,
Population numeric
)

Insert into #totEmi
Select SUM(emi.CO2emission) as totalEmission, emi.Years, pop.Population
From CO2portfolio..CO2emissionbycountries emi
Join CO2portfolio..WorldPopulationGrowth pop
	On emi.Years = pop.Years
Group By emi.Years, pop.Population

Select *, totalEmission/Population*100 as GlobalCO2byPopulationInPercent
From #totEmi


-- Creating View to store data for later visualizations
-- Skill used: Creating View

Create View GlobalCO2byPop as
Select SUM(emi.CO2emission) as totalEmission, emi.Years, pop.Population
, SUM(emi.CO2emission)/pop.Population as GlobalCO2byPopulation
From CO2portfolio..CO2emissionbycountries emi
Join CO2portfolio..WorldPopulationGrowth pop
	On emi.Years = pop.Years
Group By emi.Years, pop.Population
