-- Create View Private_SysIndexes
Print 'Create View Private_SysIndexes'
GO
CREATE VIEW tSQLt.Private_SysIndexes AS  SELECT * FROM sys.indexes;
GO
