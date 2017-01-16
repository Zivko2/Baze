SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE PROCEDURE [dbo].[SP_CALCULAADVERTENCIAPEDIMPALL]   as

declare @PI_CODIGO int

		declare cur_pedimpadvertencias cursor for
			SELECT     PI_CODIGO
			FROM         PEDIMP
			ORDER BY PI_CODIGO
		open cur_pedimpadvertencias
		FETCH NEXT FROM cur_pedimpadvertencias INTO @PI_CODIGO
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	
			exec SP_PEDIMPADVERTENCIA @PI_CODIGO

			FETCH NEXT FROM cur_pedimpadvertencias INTO @PI_CODIGO
	
		END
	
		CLOSE cur_pedimpadvertencias
		DEALLOCATE cur_pedimpadvertencias


















GO
