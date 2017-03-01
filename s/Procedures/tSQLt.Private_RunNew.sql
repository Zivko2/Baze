-- Create Procedure Private_RunNew
Print 'Create Procedure Private_RunNew'
GO


CREATE PROCEDURE tSQLt.Private_RunNew
  @TestResultFormatter NVARCHAR(MAX)
AS

BEGIN
  EXEC tSQLt.Private_RunCursor @TestResultFormatter = @TestResultFormatter, @GetCursorCallback = 'tSQLt.Private_GetCursorForRunNew';
END;
GO
