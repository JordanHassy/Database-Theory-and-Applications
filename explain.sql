create table randomnums
(
    id serial primary key,
    randomnum int not null,
    numgroup text
);

create table randomstring
(
    id serial primary key,
    randomtext text
);

create function insertrandomstr()
returns table(random text)
language 'plpgsql'
as $$
begin
for i in 1 .. 3000000 loop
    return query
        select array_to_string(array(select chr((65 + floor(random()*100/4))::integer) from generate_series(1, 15)), '');
end loop;
end;
$$;


insert into randomstring (randomtext) select insertrandomstr();

with ngroup as (
select 'one' as thegroup, generate_series as id from generate_series(1, 50000)
), rand as (
    select floor(random() * 1000000000), generate_series as id from generate_series(1,50000)
)
insert into randomnums(randomnum, numgroup) select floor, thegroup from ngroup join rand using(id);

with ngroup as (
select 'two' as thegroup, generate_series as id from generate_series(1, 50000)
), rand as (
    select floor(random() * 1000000000), generate_series as id from generate_series(1,50000)
)
insert into randomnums(randomnum, numgroup) select floor, thegroup from ngroup join rand using(id);

--sequential scan
explain analyze select * from randomnums limit 30;

------------------------------------------------------------------------------

--index scan
create unique index on randomnums using btree(id);

explain analyze select * from randomnums where id = 300;
--backward
explain analyze select * from randomnums where id < 301 order by id desc;

explain analyze select * from randomnums order by id asc limit 10;

----------------------------------------------------------------------------
--bitmap heap scan
create index randomnumid on randomnums(randomnum);

explain analyze select * from randomnums where randomnum < 100000;

alter table randomnums add column randomnum2 integer default random() * 1000000000;
create index randomnumid2 on randomnums(randomnum2);
alter table randomnums add column randomnum3 integer default random() * 1000000000;
create index randomnumid3 on randomnums(randomnum3);

alter table randomstring add column randomnum integer default random() * 1000000000;

--multilevel bitmap scan
explain analyze select * from randomnums where randomnum2 > 95000000 and randomnum < 50000000 and randomnum3 > 100000000;

--------------------------------------------------------------------------
--function scan
explain analyze select * from generate_series(1, 10) i;
-----------------------------------------------------------------------------
--sorting methods
drop index randomnumid;

--merge sort
explain analyze select * from randomstring order by randomtext;

--quicksort
explain analyze select random() as x from generate_series(1,14000) i order by x;

--top-N heapsort
explain analyze select * from randomstring order by randomtext limit 10;
-------------------------------------------------------------------------------------
--joining methods
--Hash aggregate
explain analyze select numgroup, count(numgroup) from randomnums group by numgroup;
--Hashaggregate and sort
explain analyze select numgroup, count(numgroup) from randomnums group by numgroup order by numgroup;

--Hash Join
explain analyze select * from randomnums r join randomstring s using(randomnum);
--Hash Right Join
explain analyze select * from randomnums r left join randomstring s using(randomnum);
--Hash Right Join
explain analyze select * from randomnums r right join randomstring s using(randomnum);
--Hash Full Join
explain analyze select * from randomnums r full join randomstring s using(randomnum);
--couldn't figure out anti join so I did Hash Semi Join
explain analyze select * from randomnums r where r.randomnum in (select randomnums.randomnum from randomnums join randomstring using(id));


--Merge Join
explain analyze select * from randomnums r join randomstring s using(id);
--Merge Left Join
explain analyze select * from randomnums r left join randomstring s using(id);
--Merge Right Join
explain analyze select * from randomnums r right join randomstring s using(id);
--Merge Full Join
explain analyze select * from randomnums r full join randomstring s using(id);
--Couldnt gigure out anti join here either so i did Merge Semi Join
explain analyze select * from randomnums r where r.id in (select randomnums.id from randomnums join randomstring using(id));

--Nested Loop
explain analyze select * from randomnums r where not exists (select * from randomnums join randomstring on randomstring.randomnum = randomnums.randomnum);

--Materialize
explain analyze select * from randomnums r where not exists (select * from randomnums join randomstring on randomstring.randomnum = randomnums.randomnum);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--Unique
explain analyze select distinct randomnum from (select randomnums.randomnum from randomnums order by randomnum) as x;

--append
explain analyze select * from randomnums where id > 10 union (select * from randomnums where id < 11) limit 10;

--result
explain analyze select 1+2;

--insert on
explain insert into randomnums (id) select 1 where not exists (select * from randomnums where id = 1);
--Values scan
explain select * from (values('1', 'Jordan'), ('2', 'Brennan'), ('3', 'Justice'), ('4', 'Dwayne')) as t(a, b);
--group aggregate
explain select numgroup, count(*) from (select numgroup from randomnums order by numgroup) as t group by numgroup;
--HashOp Except
explain select * from randomnums where id < 11 except (select * from randomnums where id = 3);
--HashOp Intersect
explain select * from randomnums where id < 11 intersect (select * from randomnums where id = 3);
--HashOp Intersect All
explain select * from randomnums where id < 11 intersect all (select * from randomnums where id = 3);
--CTE scan
explain analyze with x as (select id, numgroup from randomnums) select numgroup, count(*), (select count(*) from x) from x group by numgroup;
--InitPlan
explain analyze select * from randomnums where id = (select id from randomnums order by random() limit 1);
--InitPlan multilayered
explain analyze select randomstring.randomtext as text, randomnums.randomnum2 as random1, randomstring.randomnum as random2
from randomstring left join randomnums on randomstring.randomnum = randomnums.randomnum2
where (randomstring.id > 500) or (select randomstring.id = 23 from randomstring where id > 22 limit 1)
and not exists (select 1 from randomnums join randomstring using(id) where randomnums.randomnum = randomstring.randomnum and randomnums.randomnum2 = randomstring.randomnum)
and randomnums.id < 9999999
order by text asc;
--SubPlan
explain analyze select r.randomnum, r.numgroup, (select count(*) from randomstring x where r.randomnum = x.randomnum) from randomnums r limit 1;
----------------------------------------------------------------------------------------------------------
