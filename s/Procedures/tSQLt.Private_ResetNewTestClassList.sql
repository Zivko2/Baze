-- Create Procedure Private_ResetNewTestClassList
Print 'Create Procedure Private_ResetNewTestClassList'
GO

CREATE PROCEDURE tSQLt.Private_ResetNewTestClassList
AS

BEGIN
  SET NOCOUNT ON;
  DELETE FROM tSQLt.Private_NewTestClassList;
END;
GO
