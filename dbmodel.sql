/*
Are admin1_code, admin2_code, ... redundant with other data in the database?
    These columns are not necessarily needed to find information on the queries 
    we are running, but as they are real codes that are assigned to places on 
    the planet, I think it is useful to store these attributes in the larger 
    geoname database. 

Is it true for every place (P), that it's neighbors' neighbors include P? 
(Thinking of neighbor data as a graph, is it undirected? Is neighbor 
data complete? Or can I be a neighbor to you but you not be a neighbor to me?)
    There are a few exceptions to this rule, like how ‘Serbia and Montenegro’ 
    had many neighbors associated with it but no countries had this as their 
    neighbor. However, Serbia and Montenegro individually existed in the 
    database and were recorded as neighbors to their neighbors.


Which N countries have the lowest population? */
select geoname_country.name, geoname_country.isocode, population from geoname_country join geoname_geoname using(isocode) group by geoname_country.isocode, population order by population limit N;


--Which places have a population greater than X and no country? 
select name, population from geoname_geoname where isocode is null and population > X;

--How many and what kinds of places exist in countries but are not within any smaller administrative area?

with types as (select geoname_feature.feature, description
from geoname_geoname join geoname_feature using(feature)
where regcode is null and discode is null and geoname_feature.feature not like 'ADM%')
select feature as fcode, description, count(feature) from types group by feature, description order by count desc;


--Which N timezones have the most cities/states/countries/continents?
with area as (select continent, timezone
from geoname_geoname join geoname_country using(isocode)
where continent is not null and timezone is not null group by timezone, continent)
select count(continent), timezone from area group by timezone order by count desc limit 10;
--for continents, countries, states, and cities, switch out X for continent,  regcode, discode, or isocode


--What are the N highest points in each state/country/....?
select name, location, isocode, regcode, discode, elevation from geoname_geoname where elevation is not null and regcode = 'ZH' order by elevation desc limit 10;

--Switch out regcode for isocode if you want to change to viewing a country. Switch out N with number you want to use

--What are the most populous states in each country/continent?
select name, location, isocode, regcode, discode, population from geoname_geoname where isocode = 756 and regcode is not null order by population desc limit 10;

--Which countries have any points higher than the highest point of any of their neighbors?
with countries as (
    with maximum as (
    select geoname_neighbour.isocode, max(elevation), geoname_neighbour.neighbour from geoname_neighbour join geoname_geoname on geoname_neighbour.neighbour = geoname_geoname.isocode group by geoname_neighbour.isocode, neighbour),
    neighbormax as
    (select maximum.isocode, min(max) as nmax from maximum group by isocode),
    isomax as
    (select isocode, max(elevation) as imax from geoname_geoname group by isocode)
    select isocode from isomax join neighbormax using(isocode) where imax > nmax
)
select isocode, name from countries join geoname_country using(isocode) order by isocode asc;





