DECLARE @temp TABLE (id int, name varchar(50))  
--Insert Data in table  
INSERT INTO @temp(id, name)  
values(1,'João'),(5, 'Maria'),(10,'Jose'),(13,'Filipe'),(16,'Antonio'),(24,'Marcos')  
DECLARE @ptopicid INT  
SET @ptopicid = 16  
-- Get Table Records   
SELECT * FROM @temp  
-- Get Previous and Next Record Ids  
SELECT (SELECT MAX(t.id) PreviousID  
FROM @temp t  
WHERE id < @ptopicid) PreviousId, (SELECT MIN(et.id) NextID  
FROM @temp et  
WHERE id > @ptopicid) NextId 