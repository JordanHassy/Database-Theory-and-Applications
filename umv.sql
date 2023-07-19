begin;
create table emp (
    id serial primary key,
    name text not null
);

create table customer (
    id serial primary key,
    salesperson int references emp(id),
    name text not null
);

create table item (
    id serial primary key,
    name text not null,
    description text,
    price numeric(10, 2) not null check(price >= 0)
);

create table sales (
    id serial primary key,
    empid int references emp(id),
    cusid int references customer(id),
    itemid int references item(id)
);

insert into emp(name) values 
('Michael'), ('Christopher'), ('Jessica'), ('Matthew'), ('Ashley'), ('Jennifer'), ('Joshua'), ('Amanda'), ('Daniel'), ('David'), ('James'), ('Robert'), ('John'), ('Joseph'), ('Andrew'), ('Ryan'), ('Brandon'), ('Jason'), ('Justin'), ('Sarah'), ('William'), ('Jonathan'), ('Stephanie'), ('Brian'), ('Nicole'), ('Nicholas'), ('Anthony'), ('Heather'), ('Eric'), ('Elizabeth'), ('Adam'), ('Megan'), ('Melissa'), ('Kevin'), ('Steven'), ('Thomas'), ('Timothy'), ('Christina'), ('Kyle'), ('Rachel'), ('Laura'), ('Lauren'), ('Amber'), ('Brittany'), ('Danielle'), ('Richard'), ('Kimberly'), ('Jeffrey'), ('Amy'), ('Crystal');

insert into customer(salesperson, name) values
(floor(random()*(50))+1, 'Carlos'), (floor(random()*(50))+1, 'Brandi'), (floor(random()*(50))+1, 'Douglas'), (floor(random()*(50))+1, 'Nathaniel'), (floor(random()*(50))+1, 'Ian'), (floor(random()*(50))+1, 'Craig'), (floor(random()*(50))+1, 'Brandy'), (floor(random()*(50))+1, 'Alex'), (floor(random()*(50))+1, 'Valerie'), (floor(random()*(50))+1, 'Veronica'), (floor(random()*(50))+1, 'Cory'), (floor(random()*(50))+1, 'Whitney'), (floor(random()*(50))+1, 'Gary'), (floor(random()*(50))+1, 'Derrick'), (floor(random()*(50))+1, 'Philip'), (floor(random()*(50))+1, 'Luis'), (floor(random()*(50))+1, 'Diana'), (floor(random()*(50))+1, 'Chelsea'), (floor(random()*(50))+1, 'Leslie'), (floor(random()*(50))+1, 'Caitlin'), (floor(random()*(50))+1, 'Leah'), (floor(random()*(50))+1, 'Natasha'), (floor(random()*(50))+1, 'Erika'), (floor(random()*(50))+1, 'Casey'), (floor(random()*(50))+1, 'Latoya'), (floor(random()*(50))+1, 'Erik'), (floor(random()*(50))+1, 'Dana'), (floor(random()*(50))+1, 'Victor'), (floor(random()*(50))+1, 'Brent'), (floor(random()*(50))+1, 'Dominique'), (floor(random()*(50))+1, 'Frank'), (floor(random()*(50))+1, 'Brittney'), (floor(random()*(50))+1, 'Evan'), (floor(random()*(50))+1, 'Gabriel'), (floor(random()*(50))+1, 'Julia'), (floor(random()*(50))+1, 'Candice'), (floor(random()*(50))+1, 'Karen'), (floor(random()*(50))+1, 'Melanie'), (floor(random()*(50))+1, 'Adrian'), (floor(random()*(50))+1, 'Stacey'), (floor(random()*(50))+1, 'Margaret'), (floor(random()*(50))+1, 'Sheena'), (floor(random()*(50))+1, 'Wesley'), (floor(random()*(50))+1, 'Vincent'), (floor(random()*(50))+1, 'Alexandra'), (floor(random()*(50))+1, 'Katrina'), (floor(random()*(50))+1, 'Bethany'), (floor(random()*(50))+1, 'Nichole'), (floor(random()*(50))+1, 'Larry'), (floor(random()*(50))+1, 'Jeffery'), (floor(random()*(50))+1, 'Curtis'), (floor(random()*(50))+1, 'Carrie'), (floor(random()*(50))+1, 'Todd'), (floor(random()*(50))+1, 'Blake'), (floor(random()*(50))+1, 'Christian'), (floor(random()*(50))+1, 'Randy'), (floor(random()*(50))+1, 'Dennis'), (floor(random()*(50))+1, 'Alison'), (floor(random()*(50))+1, 'Trevor'), (floor(random()*(50))+1, 'Seth'), (floor(random()*(50))+1, 'Kara'), (floor(random()*(50))+1, 'Joanna'), (floor(random()*(50))+1, 'Rachael'), (floor(random()*(50))+1, 'Luke'), (floor(random()*(50))+1, 'Felicia'), (floor(random()*(50))+1, 'Brooke'), (floor(random()*(50))+1, 'Austin'), (floor(random()*(50))+1, 'Candace'), (floor(random()*(50))+1, 'Jasmine'), (floor(random()*(50))+1, 'Jesus'), (floor(random()*(50))+1, 'Alan'), (floor(random()*(50))+1, 'Susan'), (floor(random()*(50))+1, 'Sandra'), (floor(random()*(50))+1, 'Tracy'), (floor(random()*(50))+1, 'Kayla'), (floor(random()*(50))+1, 'Nancy'), (floor(random()*(50))+1, 'Tina'), (floor(random()*(50))+1, 'Krystle'), (floor(random()*(50))+1, 'Russell'), (floor(random()*(50))+1, 'Jeremiah'), (floor(random()*(50))+1, 'Carl'), (floor(random()*(50))+1, 'Miguel'), (floor(random()*(50))+1, 'Tony'), (floor(random()*(50))+1, 'Alexis'), (floor(random()*(50))+1, 'Gina'), (floor(random()*(50))+1, 'Jillian'), (floor(random()*(50))+1, 'Pamela'), (floor(random()*(50))+1, 'Mitchell'), (floor(random()*(50))+1, 'Hannah'), (floor(random()*(50))+1, 'Renee'), (floor(random()*(50))+1, 'Denise'), (floor(random()*(50))+1, 'Molly'), (floor(random()*(50))+1, 'Jerry'), (floor(random()*(50))+1, 'Misty'), (floor(random()*(50))+1, 'Mario'), (floor(random()*(50))+1, 'Johnathan'), (floor(random()*(50))+1, 'Jaclyn'), (floor(random()*(50))+1, 'Brenda'), (floor(random()*(50))+1, 'Terry'), (floor(random()*(50))+1, 'Lacey'), (floor(random()*(50))+1, 'Shaun'), (floor(random()*(50))+1, 'Devin'), (floor(random()*(50))+1, 'Heidi'), (floor(random()*(50))+1, 'Troy'), (floor(random()*(50))+1, 'Lucas'), (floor(random()*(50))+1, 'Desiree'), (floor(random()*(50))+1, 'Jorge'), (floor(random()*(50))+1, 'Andre'), (floor(random()*(50))+1, 'Morgan'), (floor(random()*(50))+1, 'Drew'), (floor(random()*(50))+1, 'Sabrina'), (floor(random()*(50))+1, 'Miranda'), (floor(random()*(50))+1, 'Alyssa'), (floor(random()*(50))+1, 'Alisha'), (floor(random()*(50))+1, 'Teresa'), (floor(random()*(50))+1, 'Johnny'), (floor(random()*(50))+1, 'Meagan'), (floor(random()*(50))+1, 'Allen'), (floor(random()*(50))+1, 'Krista'), (floor(random()*(50))+1, 'Marc');

insert into item(name, description, price) values
('Cutco-Knife-Set', 'A full set of Knives!', 119.99),
('Lawnmower', 'It just cuts grass', 49.99),
('Acer Spin 3', 'It comes with a stylus!', 1199.99),
('Lipscomb University 4 year Tuition', 'Careful! Its Expensive!', 214512.00),
('Private Jet', 'Batteries Included', 2.99);

insert into sales(empid, cusid, itemid)
select distinct floor(random()*(50))+1, floor(random()*(120))+1, floor(random()*(5))+1 from generate_series(1, 1000);

--indexes
create index on customer(id);
create index on customer(salesperson);
create index on emp(id);
create index on item(id);
create index on item(price);
create index on sales(id);

--actual view
create view transaction as 
select sales.id as id, customer.id as cus_id, customer.name as buyer, item.name as item, item.price as price, item.description as description, emp.name as seller, emp.id as emp_id from
sales join customer on customer.id = sales.cusid join emp on emp.id = sales.empid join item on item.id = sales.itemid;


create table umv as select * from transaction;
create index on umv(id);


create or replace function refresh_row(id int) returns void language 'plpgsql' as $$
begin
    delete from umv where umv.id = $1;
    insert into umv select * from transaction where umv.id = $1;
end;
$$;

create or replace function emp_trigger_refresh_row() 
returns trigger 
language plpgsql
as $$
begin 
    delete from umv where umv.emp_id = old.id;
    insert into umv select * from transaction where emp_id = new.id;
    return new;
end;
$$;

create or replace function cus_trigger_refresh_row() 
returns trigger 
language plpgsql
as $$
begin 
    delete from umv where umv.cus_id = old.id;
    insert into umv select * from transaction where cus_id = new.id;
    return new;
end;
$$;

create or replace function item_trigger_refresh_row() 
returns trigger 
language plpgsql
as $$
begin 
    update from umv where umv.item = old.name;
    insert into umv select * from transaction where item = new.name;
    return new;
end;
$$;

create or replace function sales_trigger_refresh_row() 
returns trigger 
language plpgsql
as $$
begin 
    delete from umv where umv.emp_id = old.id;
    insert into umv select * from transaction where item = new.name;
    return new;
end;
$$;

--triggers
create or replace trigger update_emp_trigger
before update on emp
execute function emp_trigger_refresh_row();

create or replace trigger update_cus_trigger
before update on customer
execute function cus_trigger_refresh_row();

create or replace trigger update_item_trigger
before update on item
execute function item_trigger_refresh_row();

create or replace trigger update_sales_trigger
before update on sales
execute function sales_trigger_refresh_row();





commit;