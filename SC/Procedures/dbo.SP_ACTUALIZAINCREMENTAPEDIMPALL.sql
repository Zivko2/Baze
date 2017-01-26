SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































/* actualiza los incrementables del pedimento en base a las facturas seleccionadas*/
CREATE PROCEDURE [dbo].[SP_ACTUALIZAINCREMENTAPEDIMPALL]   as

SET NOCOUNT ON 

declare @picodigo int, @pi_fec_pag datetime

declare cur_actualizaincrementa cursor for
	SELECT     PI_CODIGO
	FROM         dbo.PEDIMP
	where pi_codigo in (select pi_codigo from pedimpincrementa)
	ORDER BY PI_FEC_PAG, PI_CODIGO

open cur_actualizaincrementa


	FETCH NEXT FROM cur_actualizaincrementa INTO @picodigo

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo
	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 



	EXEC sp_fillpedimpincrementa @PICODIGO


	FETCH NEXT FROM cur_actualizaincrementa INTO @picodigo

END

CLOSE cur_actualizaincrementa
DEALLOCATE cur_actualizaincrementa
















































GO
