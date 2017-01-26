SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE ActIdentMA AS
Begin
declare @F1 varchar(30), @DT Varchar(6)

declare cur_consecutivo1 cursor for
SELECT    F1, DT
FROM   dbo.Identif

open cur_consecutivo1


	FETCH NEXT FROM  cur_consecutivo1 INTO @F1, @DT

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
                Update Maestro Set MA_Nombre = MA_Nombre + ' ' + Rtrim( @DT ) where MA_NOParte=@F1

                FETCH NEXT FROM  cur_consecutivo1 INTO @F1, @DT
           END

CLOSE cur_consecutivo1
DEALLOCATE cur_consecutivo1
End
GO
