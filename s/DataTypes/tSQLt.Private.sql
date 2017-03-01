-- Create Type Private
Print 'Create Type Private'
GO
EXEC sp_addtype @typename=N'Private', @phystype=N'nvarchar(4000)', @nulltype='NULL', @owner='tSQLt'
GO
