-- Create Procedure RunNew
Print 'Create Procedure RunNew'
GO


CREATE PROCEDURE tSQLt.RunNew
AS

BEGIN
  EXEC tSQLt.Private_RunMethodHandler @RunMethod = 'tSQLt.Private_RunNew';
END;
GO
