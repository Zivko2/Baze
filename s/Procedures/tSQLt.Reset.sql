-- Create Procedure Reset
Print 'Create Procedure Reset'
GO

CREATE PROCEDURE tSQLt.Reset
AS

BEGIN
  EXEC tSQLt.Private_ResetNewTestClassList;
END;
GO
