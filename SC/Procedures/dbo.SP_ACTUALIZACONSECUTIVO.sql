SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* cursor para todos los consecutivos*/
CREATE PROCEDURE [dbo].[SP_ACTUALIZACONSECUTIVO]    as

SET NOCOUNT ON 
declare @tipo varchar(5)

declare cur_consecutivo1 cursor for
SELECT     CV_TIPO
FROM         dbo.CONSECUTIVO

open cur_consecutivo1


	FETCH NEXT FROM  cur_consecutivo1 INTO @tipo

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		EXEC SP_ACTUALIZACONSECUTIVOTABLA @tipo

	FETCH NEXT FROM  cur_consecutivo1 INTO @tipo

END

CLOSE cur_consecutivo1
DEALLOCATE cur_consecutivo1




GO
