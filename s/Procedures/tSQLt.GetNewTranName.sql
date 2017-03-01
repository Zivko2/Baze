-- Create Procedure GetNewTranName
Print 'Create Procedure GetNewTranName'
GO



CREATE PROCEDURE tSQLt.GetNewTranName
  @TranName CHAR(32) OUTPUT
AS

BEGIN
  SELECT @TranName = LEFT('tSQLtTran'+REPLACE(CAST(NEWID() AS NVARCHAR(60)),'-',''),32);
END;
GO
