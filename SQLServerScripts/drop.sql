USE master;
GO

-- 1. Force all active connections (including yours) to the target database to close immediately.
-- Replace [YourDatabaseName] with the actual name of the database you want to drop.
ALTER DATABASE [hcsdl_btl] 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
GO

-- 2. Execute the DROP command.
DROP DATABASE [hcsdl_btl];
GO