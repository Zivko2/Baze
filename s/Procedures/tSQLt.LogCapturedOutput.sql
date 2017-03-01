-- Create Procedure LogCapturedOutput
Print 'Create Procedure LogCapturedOutput'
GO


CREATE PROCEDURE tSQLt.LogCapturedOutput @text NVARCHAR(MAX)
AS

BEGIN
  INSERT INTO tSQLt.CaptureOutputLog (OutputText) VALUES (@text);
END;

GO
