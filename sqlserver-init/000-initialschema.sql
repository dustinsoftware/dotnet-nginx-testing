CREATE DATABASE MyDatabase;
GO

USE MyDatabase;
GO

CREATE TABLE MyTable (
    Id INT PRIMARY KEY,
    Name NVARCHAR(100),
    CreatedAt DATETIME
);
GO

INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (1, 'Test Name 1', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (2, 'Test Name 2', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (3, 'Test Name 3', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (4, 'Test Name 4', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (5, 'Test Name 5', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (6, 'Test Name 6', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (7, 'Test Name 7', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (8, 'Test Name 8', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (9, 'Test Name 9', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (10, 'Test Name 10', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (11, 'Test Name 11', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (12, 'Test Name 12', GETDATE());
INSERT INTO MyTable (Id, Name, CreatedAt) VALUES (13, 'Test Name 13', GETDATE());
GO


CREATE LOGIN dbuser WITH PASSWORD = 'YourStrongPassw0rd';
GO

CREATE USER dbuser FOR LOGIN dbuser;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO dbuser;
GO
