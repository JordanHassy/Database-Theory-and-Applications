select geoname_continent.name,
count(*),
round(100.0 * count(*) / sum(count(*)) over(), 2) as pct,
repeat('■', (100 * count(*) / sum(count(*)) over())::int) as hist
from geoname_geoname
join geoname_country using(isocode)
join geoname_continent
on geoname_continent.code = geoname_country.continent
group by geoname_continent.name order by geoname_continent.name;

select geoname_geoname.name, geoname_geoname.population 
from geoname_continent join geoname_country on geoname_continent.code = geoname_country.continent join geoname_geoname using(isocode) 
where discode is null and continent = 'NA' and regcode is not null
order by population desc;

select * from geoname_continent;

/*
loop through continents.
use current row to run a limit n query on most populous regcodes in that continent
return next that query
*/

WITH RECURSIVE countries AS ( --1st attempt
    SELECT childId, name,0 AS depth 
    FROM hierarchy join geoname_geoname on hierarchy.childId = geoname_geoname.geonameid WHERE parentId IS NULL
    UNION ALL
    SELECT hierarchy.childId||'\'||countries.childId,countries.depth+1
    FROM hierarchy
    JOIN countries ON countries.childId=hierarchy.parentId
)
SELECT * FROM countries
ORDER BY depth;

WITH RECURSIVE countries AS ( --actual
    SELECT childname,0 AS depth, FROM hierarchy WHERE parentId IS NULL
    UNION ALL
    SELECT 
    countries.name
    ||'\'|| --figure out how to get ch
    files.name
    ,files.size,folders.depth+1,folders.path||files.id 
    FROM files
    JOIN folders ON folders.id=files.parent_id
)
SELECT * FROM folders
ORDER BY depth;

WITH RECURSIVE folders AS ( --source
    SELECT id,name,size,0 AS depth,ARRAY[id] AS path FROM files WHERE parent_id IS NULL
    UNION ALL
    SELECT files.id,folders.name||'\'||files.name,files.size,folders.depth+1,folders.path||files.id 
    FROM files
    JOIN folders ON folders.id=files.parent_id
)
SELECT * FROM folders;

select parentid from hierarchy where parentid not in (select childid from hierarchy group by childId) group by parentId;
