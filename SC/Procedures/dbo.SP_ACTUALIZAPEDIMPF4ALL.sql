SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

















































CREATE PROCEDURE [dbo].[SP_ACTUALIZAPEDIMPF4ALL]   as

SET NOCOUNT ON 

declare @picodigo int, @pimovimiento char(1), @pi_fec_pag datetime

declare cur_actualizaestatus cursor for
	SELECT     PI_CODIGO, PI_MOVIMIENTO
	FROM         PEDIMP
	where CP_CODIGO IN (SELECT CP_CODIGO FROM CONFIGURACLAVEPED WHERE CCP_TIPO='CN')
	ORDER BY PI_FEC_PAG, PI_CODIGO

open cur_actualizaestatus


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @pimovimiento

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo
	
	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 

	
	if @pimovimiento=' S'
	begin
		exec sp_fillpedexpReg @picodigo, 1
	end


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @pimovimiento

END

CLOSE cur_actualizaestatus
DEALLOCATE cur_actualizaestatus














































GO
