-- Create Function Private_SqlVersion
Print 'Create Function Private_SqlVersion'
GO

CREATE FUNCTION tSQLt.Private_SqlVersion()
RETURNS TABLE
AS

RETURN
  SELECT CAST(SERVERPROPERTY('ProductVersion')AS NVARCHAR(128)) ProductVersion,
         CAST(SERVERPROPERTY('Edition')AS NVARCHAR(128)) Edition;
GO
