SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAESTATUSORDTRABAJOALL]    as

SET NOCOUNT ON 

declare @otcodigo int, @OT_FECHAINI datetime

declare cur_actualizaestatus cursor for
	SELECT     OT_CODIGO
	FROM         dbo.ORDTRABAJO
	ORDER BY OT_FECHAINI, OT_CODIGO

open cur_actualizaestatus


	FETCH NEXT FROM cur_actualizaestatus INTO @otcodigo

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @OT_FECHAINI=OT_FECHAINI from ORDTRABAJO where OT_CODIGO=@otcodigo

	print '<==========' + convert(varchar(50), @otcodigo) + + convert(varchar(50), @OT_FECHAINI) + '==========>' 


	EXEC SP_ACTUALIZAESTATUSORDTRABAJO @otcodigo


	FETCH NEXT FROM cur_actualizaestatus INTO @otcodigo

END

CLOSE cur_actualizaestatus
DEALLOCATE cur_actualizaestatus
















































GO
