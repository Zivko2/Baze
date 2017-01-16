SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZADETALLEPEDIMPSAL303Per] (@fechaini datetime, @fechafin datetime)   as

SET NOCOUNT ON 
declare @picodigo int, @cp_codigo int, @ccp_tipo varchar(5),
@pi_fec_pag datetime

	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##PEDIMPACT'  AND  type = 'U')
	begin
		drop table ##PEDIMPACT
	end


	SELECT     TOP 100 PERCENT dbo.PEDIMP.PI_CODIGO, dbo.PEDIMP.PI_FEC_PAG, dbo.PEDIMP.CP_CODIGO
	INTO ##PEDIMPACT
	FROM         dbo.PEDIMP INNER JOIN
	              dbo.CLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO
	WHERE     (dbo.PEDIMP.PI_MOVIMIENTO = 'S') AND (dbo.CLAVEPED.CP_ART303 = 'S')
	AND (dbo.PEDIMP.PI_ESTATUS<>'R')  and dbo.PEDIMP.PI_FEC_ENT >=@fechaini  AND dbo.PEDIMP.PI_FEC_ENT <=@fechafin
	ORDER BY dbo.PEDIMP.PI_FEC_PAG, dbo.PEDIMP.PI_CODIGO


declare cur_actualizaestatus cursor for
	SELECT     PI_CODIGO, CP_CODIGO
	FROM         ##PEDIMPACT
	ORDER BY PI_FEC_PAG, PI_CODIGO
open cur_actualizaestatus


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @cp_codigo

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo
	

	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 


		EXEC sp_fillpedimento @PICODIGO, 1, 'S'


		/* actualiza el estatus del pedimento */
		exec SP_ACTUALIZAESTATUSPEDIMP @picodigo, @cp_codigo

	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @cp_codigo

END

CLOSE cur_actualizaestatus
DEALLOCATE cur_actualizaestatus


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##PEDIMPACT'  AND  type = 'U')
	begin
		drop table ##PEDIMPACT
	end

GO
