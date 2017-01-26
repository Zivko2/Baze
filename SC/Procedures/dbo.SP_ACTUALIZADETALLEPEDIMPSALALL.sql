SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_ACTUALIZADETALLEPEDIMPSALALL]   as

SET NOCOUNT ON 
declare @picodigo int, @cp_codigo int, @ccp_tipo varchar(5), @pi_tipo char(1), @pi_estatus char(1),
@pi_fec_pag datetime

	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##PEDIMPACT'  AND  type = 'U')
	begin
		drop table ##PEDIMPACT
	end

	SELECT     PI_CODIGO, cp_codigo, PI_TIPO, PI_ESTATUS, PI_FEC_PAG
	INTO ##PEDIMPACT
	FROM         PEDIMP
	WHERE PI_MOVIMIENTO='S' AND PI_ESTATUS<>'R'
	ORDER BY PI_FEC_PAG, PI_CODIGO



declare cur_actualizaestatus cursor for
	SELECT     PI_CODIGO, cp_codigo, PI_TIPO, PI_ESTATUS
	FROM         ##PEDIMPACT
	ORDER BY PI_FEC_PAG, PI_CODIGO
open cur_actualizaestatus


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @cp_codigo, @pi_tipo, @pi_estatus

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo
	

	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 


		EXEC sp_fillpedimento @PICODIGO, 1, 'S'



	/* actualiza el estatus del pedimento */
	exec SP_ACTUALIZAESTATUSPEDIMP @picodigo, @cp_codigo

	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @cp_codigo, @pi_tipo, @pi_estatus

END

CLOSE cur_actualizaestatus
DEALLOCATE cur_actualizaestatus


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##PEDIMPACT'  AND  type = 'U')
	begin
		drop table ##PEDIMPACT
	end


GO
