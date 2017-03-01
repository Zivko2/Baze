-- Create Procedure Private_CleanTestResult
Print 'Create Procedure Private_CleanTestResult'
GO

CREATE PROCEDURE tSQLt.Private_CleanTestResult
AS

BEGIN
   DELETE FROM tSQLt.TestResult;
END;
GO
