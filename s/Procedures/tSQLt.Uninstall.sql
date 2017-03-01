-- Create Procedure Uninstall
Print 'Create Procedure Uninstall'
GO


CREATE PROCEDURE tSQLt.Uninstall
AS

BEGIN
  DROP TYPE tSQLt.Private;

  EXEC tSQLt.DropClass 'tSQLt';  
  
  DROP ASSEMBLY tSQLtCLR;
END;
GO
