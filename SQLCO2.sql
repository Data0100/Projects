Select *
From CO2portfolio.dbo.CO2emissionbycountries


Select Country, Years, CO2emission,Area, Population2022
From CO2portfolio..CO2emissionbycountries
Where CO2emission is not null 
order by 1,2


Select Country, Years, CO2emission,Area, Population2022, (CO2emission/Area) as CO2bykm2
From CO2portfolio..CO2emissionbycountries
Where Country like '%kingdom%'
and Area is not null 
order by 1,2


-- Countries with Highest CO2emission compared to Population

Select Country,Population2022 , MAX(CO2emission) as HighestCO2 
,Max((CO2emission/Population2022))*100 as CO2byPercentPopulation
From CO2portfolio..CO2emissionbycountries
Where Population2022 is not null 
Group by Country, Population2022
order by CO2byPercentPopulation desc



-- GLOBAL NUMBERS

Select SUM(CO2emission) as totalEmission, Years
--, SUM(totalEmission)/SUM(totalPopulation)*100 as GlobalCO2byPopulationInPercent
From CO2portfolio..CO2emissionbycountries
where CO2emission is not null 
Group By Years
order by 2

-- Total Population vs CO2 from 1951 to 2020
--Global CO2 by Population In Percent from 1951 to 2020

Select SUM(emi.CO2emission) as totalEmission, emi.Years, pop.Population
, SUM(emi.CO2emission)/pop.Population as GlobalCO2byPopulation
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
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
--order by 1,2

-- Using CTE to perform Calculation on Partition By in previous query

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

-- Using Temp Table to perform Calculation on Partition By in previous query

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

Create View GlobalCO2byPop as
Select SUM(emi.CO2emission) as totalEmission, emi.Years, pop.Population
, SUM(emi.CO2emission)/pop.Population as GlobalCO2byPopulation
--, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CO2portfolio..CO2emissionbycountries emi
Join CO2portfolio..WorldPopulationGrowth pop
	On emi.Years = pop.Years
Group By emi.Years, pop.Population
