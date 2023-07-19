select geoname_country.name, geoname_neighbour.isocode from geoname_country join geoname_neighbour using(isocode) where geoname_neighbour.isocode not in 
(select neighbour from geoname_neighbour)
group by geoname_neighbour.isocode, geoname_country.name;


select geoname_country.name, geoname_country.isocode, population from geoname_country join geoname_geoname using(isocode) group by geoname_country.isocode, population order by population;

select name, population from geoname_geoname where isocode is null and population > X;



with types as (select geoname_feature.feature
from geoname_geoname join geoname_feature using(feature)
where regcode is null and discode is null and geoname_feature.feature not like 'ADM%'
group by geoname_feature.feature)
select count(feature) from types;

select geoname_feature.feature, description
from geoname_geoname join geoname_feature using(feature)
where regcode is null and discode is null and geoname_feature.feature not like 'ADM%'
group by geoname_feature.feature, geoname_feature.description;

with area as (select continent, timezone
from geoname_geoname join geoname_country using(isocode)
where continent is not null and timezone is not null group by timezone, continent)
select count(continent), timezone from area group by timezone order by count desc limit 10;

select regcode, timezone from geoname_geoname where regcode is not null and timezone is not null group by timezone, regcode

select name, location, isocode, regcode, discode, population from geoname_geoname where isocode = 756 and regcode is not null order by population desc limit 10;



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


