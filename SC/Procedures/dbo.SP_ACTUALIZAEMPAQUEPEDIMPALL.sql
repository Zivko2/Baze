SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























CREATE PROCEDURE [dbo].[SP_ACTUALIZAEMPAQUEPEDIMPALL]   as

SET NOCOUNT ON 
declare @picodigo int, @pimovimiento char(1), @cp_codigo int, @ccp_tipo varchar(5), @pi_tipo char(1), @pi_estatus char(1),
@pi_fec_pag datetime

declare cur_actualizaestatus cursor for
	SELECT     PI_CODIGO, cp_codigo, PI_TIPO, PI_ESTATUS
	FROM         PEDIMP
	WHERE PI_MOVIMIENTO='E'
	ORDER BY PI_FEC_PAG, PI_CODIGO
open cur_actualizaestatus


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @cp_codigo, @pi_tipo, @pi_estatus

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
	select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo=@cp_codigo

	select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo
	

	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 


	if (@PI_ESTATUS not in ('A', 		-- ABIERTO - AFECTADO
	'C',  					-- CERRADO
	'F',  					-- RECTIFICACION - AFECTADA
	'G') and @pi_tipo='C')				-- RECTIFICACION - CERRADA


		EXEC sp_fillpedimpempaque @picodigo, 1


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @cp_codigo, @pi_tipo, @pi_estatus

END

CLOSE cur_actualizaestatus
DEALLOCATE cur_actualizaestatus






















GO
