use covid_19_data_analysis
select * from cdeaths

-- Firstly, I am converting the date column into the 'date' datatype because it has currently 'text' datatype .

alter table cdeaths 
modify date date ;

-- Now its showing error because actually date in the table is in the format of dd/mm/yyyy
-- but in mysql the default setting for the date is yyyy/mm/dd 
-- So firtly I should convert the format into yyyy/mm/dd and then I will change the dataytype.

UPDATE cdeaths 
SET date = str_to_date(date,'%d-%m-%Y');  -- str_to_date convert any format to yyyy//mm/dd format  

alter table cdeaths 
modify date date ;

describe cdeaths

-- Now the date column has the datatype 'date'.

-- Q. What is the lilkelihood of a person dying if he/she got infected with covid_19 in India ?


 -- Selecting the data that we'll be using.  

select Location , date , total_cases , new_cases, total_deaths , population 
from Cdeaths 

-- Total cases vs Total deaths
-- Now we wil be looking at the  total cases vs total deaths (divide the total deaths by the total cases and then *100 for percentage)

select Location , date , total_cases ,total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from Cdeaths  order by date ; 

-- This shows the likelihood of a person dying if he/she get covid in the respective country.

-- Analysing the data for India. 

select Location , date , total_cases ,total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from Cdeaths 
where Location like 'India'
order by date ;
-- Observation - There would be 1.1% chance of a person dying if he/she get covid in India around April-2021 .  


-- Q. What percentage of population got covid in the India with respect to the date ? 
-- Now we will look at the total cases vs population , which we will show that what percentage of population got covid in the India.   

select Location , date , Population , total_cases , (total_cases/population)*100 as percentagepopulationinfected 
from Cdeaths 
where Location like 'India'

-- Observation - So currently (2021-04-30) almost 1.3% of the total population of India got infected by covid-19 .  




-- Highest infection rate
-- Q. Which country has the highest infection rate as compared to the population of the country? 

select Location , Population , MAX(total_cases) as highestinfectioncount ,max((total_cases/population))*100 as percentagepopulationinfected 
from Cdeaths 
group by Location , Population
order by percentagepopulationinfected desc

-- Observation - Andorra Country has the highest infection rate as compared to the population of the country.


-- Q. What is the total death count of every country? 

select Location ,max(Total_deaths) as Totaldeathcount  
from Cdeaths 
group by Location
order by Totaldeathcount desc

-- Actually the above query is not giving the correct results because the type of total_deaths is 'text'.

describe cdeaths

-- Changing the datatype of this coloumn.
-- (the CAST() function converts a value (of any type) into a specified datatype.)

Select Location, max(cast(Total_deaths as signed)) as totaldeathcount -- used signed to change the data type to integer 
from Cdeaths 
group by Location
order by Totaldeathcount desc

-- Changed the datatype and the query is working.
-- But now there is a another issue which is in the location column, there are some locations which are not countires
-- for example there is a location named as 'world' and also there are some locations which do not have any value for the continent column, 
--  actully this problem is in the table where the continent value is null and the location is actually the whole continent.
-- That is why some of the locations are named as 'Asia'.
 -- You can have a look from the table.
  
select * from cdeaths

 -- So to solve this issue we will now only focous on the data where continent value is not null,
-- for that we will use 'continent !='' ' in the every query we need.

Select Location, max(cast(Total_deaths as signed )) as totaldeathcount 
from Cdeaths 
where continent != '' 
group by Location 
order by Totaldeathcount desc

-- Observation- United States, Brazil, Mexico, India are the countries with the highest Death Counts . 


-- Now let's break the things with respect to the Global numbers. 
-- Q. How many new number of cases were listed across the world each day?
 
 
Select date, sum(new_cases)
from Cdeaths 
where continent != '' 
group by date 
order by 1

-- Observation : Significant number of cases started around lately in Jan-2020 . 


-- Q. Check out the number of new cases , new deaths and the death percentage with respect to the dates on a global level. 
-- To check this out ,firstly we have to convert the new_deaths into 'int' datatype as the new_cases is already in the 'int' datatype format. 

Select date, sum(new_cases) , sum(cast(new_deaths as signed))
from Cdeaths 
where continent != '' 
group by date 
order by 1 


-- Calculating the death percentage 
  
Select date, sum(new_cases) , sum(new_deaths) , sum(new_deaths) / sum(new_cases) as deathpercentage  
from Cdeaths 
where continent != '' 
group by date 
order by 1 


-- Calculate the chance of a person dying according the global data and compare it with the results got in the Country data. 

Select sum(new_cases) , sum(new_deaths) , sum(new_deaths) / sum(new_cases) as deathpercentage  
from Cdeaths 
where continent != '' 

-- Observation : According to world data the chance of a person dying is about 0.02% while if we have a look onto the 
-- Indian data the the chance are about 1.1% . So the risk for a person dying living in India is more as compared to global level. 


-- Covid vaccinations  

select * from cvaccinations

UPDATE cvaccinations -- Changing the datatype of the date column. 
SET date = str_to_date(date,'%d-%m-%Y'); 

alter table cvaccinations 
modify date date ;

describe cvaccinations


-- Now lets join the cdeaths and cvaccinations tables together.

select * from cdeaths dea 
join cvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 


-- Q. Calculate the Total number of new vaccination with respect to the total population of each country.

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations from cdeaths dea 
join cvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent != '' 

-- Observation : Vaccinations started in India on 16 Jan 2021 and around 1.9 lakh people were vaccinated on the 1st day. 

-- Calculate the total no of new vaccinations wrt to date and the location. 

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations , sum(cast(vac.new_vaccinations as signed )) 
over(partition by dea.location)  from cdeaths dea 
join cvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent != '' 
order by 2,3 
-- (partition by location means the sum(vac.new_vaccination) will run wrt to the location , means it will display the count wrt to the location.)

-- Actually here the total no of vaccinations are displayed wrt to the location but what I actually wanted is the total vaccinations should be displayed 
-- by adding the data of the previous dates.
-- For that we will order partition by location and date.

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, sum(cast(vac.new_vaccinations as signed ))
over(partition by dea.location order by dea.location, dea.date ) as rollingpeoplevaccinated  from cdeaths dea 
join cvaccinations vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent != '' 
order by 2,3 

-- Observation : We got the rolling people vacciantion i.e number of people vaccinated by adding the data of the pervious dates. 


Results :
-- Chances of person dying in India due to coivd: 1.1% chance of a person dying if he/she get covid in India around April-2021
-- Percentage of population got covid in the India with respect to the date :So currently (2021-04-30) almost 1.3% 
-- of the total population of India got infected by covid-19 . 
-- Country with the highest infection rate as compared to its population : Andorra Country has the highest infection rate as compared to its population
-- Total death count of every country :United States, Brazil, Mexico, India are the countries with the highest Death Counts . 
-- New number of cases listed across the world each day: Significant number of cases started around lately in Jan-2020 . 
-- Number of cases, deaths and the death percentage on a global level : According to world data the chance of a person dying is about 0.02% while if we have a look onto the 
-- Indian data the the chance are about 1.1% . So the risk for a person dying living in India is more as compared to global level. 
-- Total number of new vaccination with respect to the total population of each country: Vaccinations started in India on 16 Jan 2021 and 
-- around 1.9 lakh people were vaccinated on the 1st day. 
-- Total no of new vaccinations wrt to date and the location: We got the rolling people vacciantion i.e number of people vaccinated by adding the 
--  data of the pervious dates. 


