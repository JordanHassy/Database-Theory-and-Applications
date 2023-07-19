
--Return a set of N countries with the lowest population.
create function lowPopCountries(n integer)
returns table(country_iso integer, country_name text, country_population bigint)
language 'plpgsql'
as $$
begin
    return query
        select geoname_country.isocode, geoname_country.name, population 
        from geoname_country join geoname_geoname using(isocode) 
        group by geoname_country.isocode, population 
        order by population limit n;
end;
$$;

--Return a set of places within country C (NULL means no country) whose population is greater than P.

create function countrypopgreater(c text, p bigint)
returns table(place_name text, place_population bigint)
language 'plpgsql'
as $$
begin
    if c is null then
        return query
            select name, population 
            from geoname_geoname 
            where isocode is null and population > p;
    else
        return query
            select name, population 
            from geoname_geoname 
            where isocode  = (
                    select isocode from geoname_country where name = c
            )
            and population > p;
    end if;
end;
$$;

--Return a set of kinds and counts of places in countries but NOT within any other administrative area.

create function incbutnotother()
returns table(place text, count bigint)
language 'plpgsql'
as $$
begin
    return query
        with types as (select geoname_feature.feature
        from geoname_geoname join geoname_feature using(feature)
        where regcode is null and discode is null and geoname_feature.feature not like 'ADM%')
        select feature as fcode, count(feature) from types group by feature order by count desc;
end;
$$;

--Return a set of timezones with counts for the number of cities/states/countries/continents.

create function timenumofplace(place text)
returns table(tzone text, count bigint)
language  'plpgsql'
as $$
begin
    if place = 'cities' then
        return query
            with area as (select discode, timezone
            from geoname_geoname join geoname_country using(isocode)
            where discode is not null and timezone is not null group by timezone, discode)
            select timezone, count(discode) from area group by timezone order by count desc limit 10;
    elsif place = 'states' then 
        return query
            with area as (select regcode, timezone
            from geoname_geoname join geoname_country using(isocode)
            where regcode is not null and timezone is not null group by timezone, regcode)
            select timezone, count(regcode) from area group by timezone order by count desc limit 10;
    elsif place = 'countries' then
        return query
            with area as (select isocode, timezone
            from geoname_geoname join geoname_country using(isocode)
            where isocode is not null and timezone is not null group by timezone, isocode)
            select timezone, count(isocode) from area group by timezone order by count desc limit 10;
    elsif place = 'continents' then
        return query
            with area as (select continent, timezone
            from geoname_geoname join geoname_country using(isocode)
            where continent is not null and timezone is not null group by timezone, continent)
            select timezone, count(continent) from area group by timezone order by count desc limit 10;
    end if;
end;
$$;

--Return a set of N highest points within country C (NULL means no country).

create function highestpoints(n integer, c text)
returns table(pname text, pelev bigint)
language 'plpgsql'
as $$
begin
    return query
        select geoname_geoname.name, elevation 
        from geoname_geoname join geoname_country using(isocode)
        where elevation is not null and geoname_country.name = c
        order by elevation desc limit n;
end;
$$;

create function highestpoints(n integer)
returns table(pname text, pelev bigint)
language 'plpgsql'
as $$ 
begin
    return query
        select geoname_geoname.name, elevation 
        from geoname_geoname 
        where elevation is not null and isocode is null
        order by elevation desc limit n;
end;
$$;

--Return a set of N most populous states on each continent.

create function continenthighpop(n integer)
returns table (cname char(2), pname text, pop bigint)
language 'plpgsql'
as $$
declare r record;
begin
    for r in
        select * from geoname_continent
    loop
        return query
            select geoname_country.continent, geoname_geoname.name, geoname_geoname.population 
            from geoname_continent join geoname_country on geoname_continent.code = geoname_country.continent join geoname_geoname using(isocode) 
            where discode is null and continent = r.code and regcode is not null
            order by population desc
            limit n;
    end loop;
end;
$$;

--Return a set of countries with higher points than any point in their neighbors.
create function higherpointneighbour()
returns table(isocode integer, name text)
language 'plpgsql'
as $$
begin
return query
    with countries as (
        with minimum as (
                select geoname_neighbour.isocode, min(elevation), geoname_neighbour.neighbour from geoname_neighbour join geoname_geoname on geoname_neighbour.neighbour = geoname_geoname.isocode group by geoname_neighbour.isocode, neighbour),
            neighbormin as
                (select minimum.isocode, min(min) as nmin from minimum group by minimum.isocode),
            isomax as
                (select geoname_geoname.isocode, max(elevation) as imax from geoname_geoname group by geoname_geoname.isocode)
        select isomax.isocode from isomax join neighbormin using(isocode) where imax > nmin
    )
    select countries.isocode, geoname_country.name from countries join geoname_country using(isocode) order by geoname_country.isocode asc;
end;
$$;


--Return a set of kinds of places with their min, max, and average "hierarchical depth

create function hier_depth() 
returns table (place text, mind integer, maxd integer, avgd integer) 
language 'plpgsql'
as $$
begin
    return query
        with aggfunctions as (
            with recursive alldepths as (
                select childid, 0 as depth from hierarchy where childid not in (select parentid from hierarchy)
                union all
                select hierarchy.childid, depth+1 from hierarchy join alldepths on hierarchy.parentid = alldepths.childid
            )
            select feature, childid, depth from alldepths join geoname_geoname on alldepths.childid = geoname_geoname.geonameid
        )
        select feature, min(depth)::integer as min_depth, max(depth)::integer as max_depth, avg(depth)::integer as avg_depth from aggfunctions group by feature;
end;
$$;