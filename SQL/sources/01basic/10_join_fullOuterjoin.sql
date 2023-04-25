/*********************************
full outer join
*********************************/

--------------------------------------
-- full outer join = left outer join + right outer join
--------------------------------------

-- prep
CREATE SCHEMA pm;
GO

CREATE TABLE pm.projects(
    id INT PRIMARY KEY IDENTITY,
    title VARCHAR(255) NOT NULL
)
GO

CREATE TABLE pm.members(
    id INT PRIMARY KEY IDENTITY,
    name VARCHAR(120) NOT NULL,
    project_id INT,
    FOREIGN KEY (project_id) 
        REFERENCES pm.projects(id)
)
GO

INSERT INTO 
    pm.projects(title)
VALUES
    ('New CRM for Project Sales'),
    ('ERP Implementation'),
    ('Develop Mobile Sales Platform')
GO

INSERT INTO
    pm.members(name, project_id)
VALUES
    ('John Doe', 1),
    ('Lily Bush', 1),
    ('Jane Doe', 2),
    ('Jack Daniel', null)
GO

-- test: members who participate in projects, members who do not participate in any projects, and projects which do not have any members
SELECT 
    m.name member, 
    p.title project
FROM 
    pm.members m
    FULL OUTER JOIN pm.projects p 
        ON p.id = m.project_id

-- test: members who do not participate in any project and projects which do not have any members
SELECT 
    m.name member, 
    p.title project
FROM 
    pm.members m
    FULL OUTER JOIN pm.projects p 
        ON p.id = m.project_id
WHERE
    m.id IS NULL OR
    P.id IS NULL;





