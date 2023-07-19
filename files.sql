CREATE TABLE files (
    id          SERIAL  UNIQUE,
    name        text    NOT NULL,
    parent_id   int              REFERENCES files(id),
    size        int     NOT NULL DEFAULT 0,

    UNIQUE(parent_id,name)
);

INSERT INTO files (name) VALUES
    ('D:'),
    ('C:');
    
INSERT INTO files (name,parent_id,size) VALUES
    ('Windows',2,200),
    ('Users',2,100),
    ('Bob',4,100),
    ('Documents',5,300),
    ('hw.txt',6,1000),
    ('Pictures',5,100),
    ('img1.jpg',8,2000),
    ('img2.jpg',8,2000),
    ('hw2.doc',6,5000),
    ('stuff',3,10000),
    ('Data',1,100),
    ('stuff',13,100000);

SELECT * FROM files WHERE parent_id IS NULL;

SELECT * FROM files WHERE id IN (SELECT parent_id FROM files);
SELECT * FROM files WHERE id NOT IN (SELECT parent_id FROM files);
SELECT parent_id FROM files;
SELECT * FROM files WHERE id NOT IN (SELECT parent_id FROM files WHERE parent_id IS NOT NULL);

SELECT * FROM files WHERE parent_id=(SELECT id FROM files WHERE name='Documents' AND parent_id=5);
SELECT * FROM files WHERE parent_id=(SELECT id FROM files WHERE name='Pictures' AND parent_id=5);
SELECT * FROM files WHERE parent_id IN (SELECT id FROM files WHERE parent_id=5);

-- parents
SELECT folders.name||E'\\'||files.name,files.size
FROM files
JOIN files folders ON folders.id=files.parent_id;

-- CTE
WITH folders AS (
    SELECT id,name FROM files
)
SELECT folders.name||E'\\'||files.name,size
FROM files, folders
WHERE folders.id=files.parent_id;

-- recursive CTE
WITH RECURSIVE folders AS (
    SELECT id,name,size FROM files WHERE parent_id IS NULL
    UNION ALL
    SELECT files.id,folders.name||'\'||files.name,files.size
    FROM files
    JOIN folders ON folders.id=files.parent_id
)
SELECT * FROM folders
ORDER BY name;

-- recursive CTE w/ depth and breadth columns
WITH RECURSIVE folders AS (
    
    SELECT files.id,folders.name||'\'||files.name,files.size,folders.depth+1,folders.path||files.id 
    FROM files
    JOIN folders ON folders.id=files.parent_id
)
SELECT * FROM folders
ORDER BY depth;

WITH RECURSIVE folders AS (
    SELECT id,name,size,0 AS depth,ARRAY[id] AS path FROM files WHERE parent_id IS NULL
    UNION ALL
    SELECT files.id,folders.name||'\'||files.name,files.size,folders.depth+1,folders.path||files.id 
    FROM files
    JOIN folders ON folders.id=files.parent_id
)
SELECT * FROM folders
ORDER BY depth;

with recursive folders as (
    select id, name, size, 0 as depth, array[id] as path from files where parent_id is null
    union all 
    select files.id, folders.name||'\'||files.name, files.size, folders.depth+1, folders.path||files.id
    from files 
    join folders on folders.id = files.parent_id
)