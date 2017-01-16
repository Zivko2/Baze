SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE PROCEDURE [dbo].[SP_ACTUALIZAPAGOCONTRIBPEDIMPALL]   as

SET NOCOUNT ON 

declare @picodigo int, @pimovimiento char(1), @pi_fec_pag datetime

declare cur_actualizaestatus cursor for
	SELECT     PI_CODIGO, PI_MOVIMIENTO 
	FROM         dbo.PEDIMP
	WHERE PI_MOVIMIENTO='S' and PI_FEC_PAG>='11/20/2000'
	AND PI_CODIGO IN (SELECT PI_CODIGO FROM PEDIMPDET)
	ORDER BY PI_FEC_PAG, PI_CODIGO

open cur_actualizaestatus


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @pimovimiento

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo
	

	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 

	IF NOT EXISTS (SELECT * FROM PEDIMPDETB WHERE PI_CODIGO=@picodigo)
	exec sp_fillpedimpdetB @picodigo, 1	/*inserta detalle B del pedimento */

	EXEC sp_fillpedExpDetBArt303 @PICODIGO


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @pimovimiento

END

CLOSE cur_actualizaestatus
DEALLOCATE cur_actualizaestatus




































GO
