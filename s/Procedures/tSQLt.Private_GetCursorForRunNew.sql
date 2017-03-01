-- Create Procedure Private_GetCursorForRunNew
Print 'Create Procedure Private_GetCursorForRunNew'
GO


CREATE PROCEDURE tSQLt.Private_GetCursorForRunNew
  @TestClassCursor CURSOR VARYING OUTPUT
AS

BEGIN
  SET @TestClassCursor = CURSOR LOCAL FAST_FORWARD FOR
   SELECT TC.Name
     FROM tSQLt.TestClasses AS TC
     JOIN tSQLt.Private_NewTestClassList AS PNTCL
       ON PNTCL.ClassName = TC.Name;

  OPEN @TestClassCursor;
END;
GO
