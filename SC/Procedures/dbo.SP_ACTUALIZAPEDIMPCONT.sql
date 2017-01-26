SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE PROCEDURE [dbo].[SP_ACTUALIZAPEDIMPCONT]  (@FED_INDICED INT)   as

SET NOCOUNT ON 

declare @pic_indicec  int

declare cur_pedimpcont cursor for
	Select pic_indicec 
	from  factexpcont
	where fed_indiced =@fed_indiced and pic_indicec > 0

open cur_pedimpcont


	FETCH NEXT FROM cur_pedimpcont INTO @pic_indicec 

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	UPDATE PEDIMPCONT
	SET PIC_USO_DESCARGA ='N', PIC_SEL='N'
	WHERE PIC_INDICEC = @PIC_INDICEC




	FETCH NEXT FROM cur_pedimpcont INTO @pic_indicec 

END

CLOSE cur_pedimpcont
DEALLOCATE cur_pedimpcont
















































GO
