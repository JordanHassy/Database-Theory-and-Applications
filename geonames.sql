begin;

create table raw_geonames
(
geonameid bigint,
name text,
asciiname text,
alternatenames text,
latitude double precision,
longitude double precision,
feature_class text,
feature_code text,
country_code text,
cc2 text,
admin1_code text,
admin2_code text,
admin3_code text,
admin4_code text,
population bigint,
elevation bigint,
dem bigint,
timezone text,
modification date
);

create table raw_country
(
iso text,
iso3 text,
isocode integer,
fips text,
name text,
capital text,
area double precision,
population bigint,
continent text,
tld text,
currency_code text,
currency_name text,
phone text,
postal_code_format text,
postal_code_regex text,
languages text,
geonameid bigint,
neighbours text,
fips_equiv text
);

\copy raw_country from 'countryInfo2.txt' with csv delimiter E'\t'

create table raw_feature
(
code text,
description text,
comment text
);

\copy raw_feature from 'featureCodes_en.txt' with csv delimiter E'\t'

create table raw_admin1
(
code text,
name text,
ascii_name text,
geonameid bigint
);

\copy raw_admin1 from 'admin1CodesASCII.txt' with csv delimiter E'\t'

create table raw_admin2
(
code text,
name text,
ascii_name text,
geonameid bigint
);

\copy raw_admin2 from 'admin2Codes.txt' (QUOTE E'\u0007', delimiter E'\t', format 'csv', HEADER);

\copy raw_geonames from 'allCountries.txt' (QUOTE E'\u0007', delimiter E'\t', format 'csv', HEADER);

create table geoname_class
(
class char(1) not null primary key,
description text not null
);

insert into geoname_class (class, description)
values ('A', 'country, state, region,...'),
('H', 'stream, lake, ...'),
('L', 'parks,area, ...'),
('P', 'city, village,...'),
('R', 'road, railroad '),
('S', 'spot, building, farm'),
('T', 'mountain,hill,rock,... '),
('U', 'undersea'),
('V', 'forest,heath,...');

create table geoname_feature
(
class char(1) not null references geoname_class(class),
feature text not null,
description text,
comment text,

primary key(class, feature)
);

insert into geoname_feature
select substring(code from 1 for 1) as class,
substring(code from 3) as feature,
description,
comment
from raw_feature
where raw_feature.code <> 'null';

create table geoname_continent
(
id serial primary key check(id >= 0),
code char(2) unique not null,
name text unique not null
);

insert into geoname_continent(code, name)
values ('AF', 'Africa'),
('NA', 'North America'),
('OC', 'Oceania'),
('AN', 'Antarctica'),
('AS', 'Asia'),
('EU', 'Europe'),
('SA', 'South America');

create table geoname_country
(
isocode integer primary key,
iso char(2) not null,
iso3 char(3) not null,
fips text,
name text not null,
capital text,
continent char(2) references geoname_continent(code),
tld text,
geonameid bigint not null unique
);

insert into geoname_country
select isocode, iso, iso3, fips, name,
capital, continent, tld, geonameid
from raw_country;

create table geoname_neighbour
(
isocode integer not null references geoname_country(isocode),
neighbour integer not null references geoname_country(isocode),

primary key(isocode, neighbour)
);

insert into geoname_neighbour
with n as(
select isocode,
regexp_split_to_table(neighbours, ',') as neighbour
from raw_country
)
select n.isocode,
geoname_country.isocode
from n
join geoname_country
on geoname_country.iso = n.neighbour;

create table geoname_region
(
isocode integer not null references geoname_country(isocode),
regcode text not null,
name text not null,
geonameid bigint not null,

primary key(isocode, regcode)
);

insert into geoname_region
with admin as
(
select regexp_split_to_array(code, '[.]') as code,
name,
geonameid
from raw_admin1
)
select geoname_country.isocode as isocode,
code[2] as regcode,
admin.name,
admin.geonameid
from admin
join geoname_country
on geoname_country.iso = code[1];

create table geoname_district
(
isocode integer not null,
regcode text not null,
discode text not null,
name text not null,
geonameid bigint not null,

primary key(isocode, regcode, discode),
foreign key(isocode, regcode)
references geoname_region(isocode, regcode)
);

insert into geoname_district
with admin as
(
select regexp_split_to_array(code, '[.]') as code,
name,
geonameid
from raw_admin2
)
select geoname_region.isocode,
geoname_region.regcode,
code[3],
admin.name,
admin.geonameid
from admin

join geoname_country
on geoname_country.iso = code[1]

join geoname_region
on geoname_region.isocode = geoname_country.isocode
and geoname_region.regcode = code[2];

create table geoname_geoname
(
geonameid bigint primary key check(geonameid >= 0),
name text not null,
location point not null,
isocode integer,
regcode text,
discode text,
class char(1),
feature text,
population bigint,
elevation bigint,
timezone text,

foreign key(isocode)
references geoname_country(isocode),

foreign key(isocode, regcode)
references geoname_region(isocode, regcode),

foreign key(isocode, regcode, discode)
references geoname_district(isocode, regcode, discode),

foreign key(class)
references geoname_class(class),

foreign key(class, feature)
references geoname_feature(class, feature)
);

insert into geoname_geoname
with geo as
(
select geonameid,
name,
point(longitude, latitude) as location,
country_code,
admin1_code,
admin2_code,
feature_class,
feature_code,
population,
elevation,
timezone
from raw_geonames
)
select geo.geonameid,
geo.name,
geo.location,
geoname_country.isocode,
geoname_region.regcode,
geoname_district.discode,
geoname_feature.class,
geoname_feature.feature,
population,
elevation,
timezone
from geo
left join geoname_country
on geoname_country.iso = geo.country_code

left join geoname_region
on geoname_region.isocode = geoname_country.isocode
and geoname_region.regcode = geo.admin1_code

left join geoname_district
on geoname_district.isocode = geoname_country.isocode
and geoname_district.regcode = geo.admin1_code
and geoname_district.discode = geo.admin2_code

left join geoname_feature
on geoname_feature.class = geo.feature_class
and geoname_feature.feature = geo.feature_code;

create index on geoname_geoname using gist(location);

create table raw_hierarchy
(
    parentId bigint,
    childId bigint,
    hType text
);

create table hierarchy
(
    id serial primary key,
    parentId bigint,
    childId bigint not null,
    hType text
);

\copy raw_hierarchy from 'hierarchy.txt' with csv delimiter E'\t' 
insert into hierarchy(parentId, childId, hType)
    (select parentId, childId, hType from raw_hierarchy);

drop table raw_hierarchy;
drop table raw_admin1;
drop table raw_admin2;
drop table raw_country;
drop table raw_feature;
drop table raw_geonames;

create index hier_child_id on hierarchy(childid);
create index hier_parent_id on hierarchy(parentid);


commit;