SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO













CREATE PROCEDURE [dbo].[SP_ACTUALIZADETALLEPEDIMPAZUL]   as

SET NOCOUNT ON 
declare @picodigo int, @pimovimiento char(1), @cp_codigo int, @ccp_tipo varchar(5), @pi_tipo char(1), @pi_estatus char(1),
@pi_fec_pag datetime

	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##PEDIMPACT'  AND  type = 'U')
	begin
		drop table ##PEDIMPACT
	end


	SELECT     PI_CODIGO, PI_MOVIMIENTO, cp_codigo, PI_TIPO, PI_ESTATUS, PI_FEC_PAG
	INTO ##PEDIMPACT
	FROM         PEDIMP
	WHERE PI_CODIGO IN (SELECT PI_CODIGO FROM VPEDIMPAZUL)
	ORDER BY PI_FEC_PAG, PI_CODIGO


declare cur_actualizaestatus cursor for
	SELECT     PI_CODIGO, PI_MOVIMIENTO, cp_codigo, PI_TIPO, PI_ESTATUS, PI_FEC_PAG
	FROM        ##PEDIMPACT
	ORDER BY PI_FEC_PAG, PI_CODIGO
open cur_actualizaestatus


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @pimovimiento, @cp_codigo, @pi_tipo, @pi_estatus, @pi_fec_pag

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 


	if (@PI_ESTATUS not in ('A', 		-- ABIERTO - AFECTADO
	'C',  					-- CERRADO
	'F',  					-- RECTIFICACION - AFECTADA
	'G'))					-- RECTIFICACION - CERRADA

	begin

		if @pi_tipo='C'		--Corriente
		begin
			EXEC sp_fillpedimento @PICODIGO, 1, @pimovimiento		-- cambio de regimen
		end
		else
		begin

			EXEC sp_fillpedimpdetb @PICODIGO, 1		--pedimento de importacion detalle b

		end
	end
	else
	begin

		EXEC sp_fillpedimpdetb @PICODIGO, 1		--pedimento de importacion detalle b


		EXEC sp_fillpedimpactualizaincrementa	@PICODIGO	--pedimento de importacion factor aduana
	
	end


	/* actualiza el estatus del pedimento */
	exec SP_ACTUALIZAESTATUSPEDIMP @picodigo, @cp_codigo

	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @pimovimiento, @cp_codigo, @pi_tipo, @pi_estatus, @pi_fec_pag

END

CLOSE cur_actualizaestatus
DEALLOCATE cur_actualizaestatus


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##PEDIMPACT'  AND  type = 'U')
	begin
		drop table ##PEDIMPACT
	end


GO
