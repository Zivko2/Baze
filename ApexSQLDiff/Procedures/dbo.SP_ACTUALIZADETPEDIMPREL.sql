SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_ACTUALIZADETPEDIMPREL]   as

SET NOCOUNT ON 

declare @picodigo int, @ccp_tipo varchar(5), @pi_movimiento char(1), @pi_fec_pag datetime

declare cur_actualizapedimento cursor for
	SELECT     dbo.PEDIMP.PI_CODIGO, dbo.CONFIGURACLAVEPED.CCP_TIPO, dbo.PEDIMP.PI_MOVIMIENTO
	FROM         dbo.PEDIMP LEFT OUTER JOIN
	                      dbo.CONFIGURACLAVEPED ON dbo.PEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
	WHERE dbo.PEDIMP.PI_CODIGO NOT IN (SELECT PI_CODIGO FROM PEDIMPDET) AND
	(dbo.PEDIMP.PI_CODIGO IN (SELECT PI_CODIGO FROM FACTIMP) OR 
	dbo.PEDIMP.PI_CODIGO IN (SELECT PI_CODIGO FROM FACTEXP))

open cur_actualizapedimento


	FETCH NEXT FROM cur_actualizapedimento INTO @picodigo, @ccp_tipo, @pi_movimiento

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo

	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 


	if @ccp_tipo='RE'
		exec sp_fillpedimp_rect @picodigo, 1
	else
	begin
		if @pi_movimiento='E'
			exec sp_fillpedimp @picodigo, 1
		else
			exec sp_fillpedexp @picodigo, 1
	end


	FETCH NEXT FROM cur_actualizapedimento INTO @picodigo, @ccp_tipo, @pi_movimiento

END

CLOSE cur_actualizapedimento
DEALLOCATE cur_actualizapedimento














































GO
