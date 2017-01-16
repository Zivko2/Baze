SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_ACTUALIZAAGRUPACIONPEDIMPALL]   as

SET NOCOUNT ON 
declare @picodigo int, @pimovimiento char(1), @pi_fec_ent varchar(10)


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##PEDIMPCICLO'  AND  type = 'U')
	begin
		drop table ##PEDIMPCICLO
	end

	SELECT     PI_CODIGO, PI_MOVIMIENTO, convert(varchar(10), PI_FEC_ENT, 101) as PI_FEC_ENT
	INTO ##PEDIMPCICLO
	FROM        PEDIMP
	ORDER BY PI_FEC_ENT, PI_CODIGO


declare cur_actualizaestatus cursor for
	SELECT     PI_CODIGO, PI_MOVIMIENTO, PI_FEC_ENT
	FROM        ##PEDIMPCICLO
	ORDER BY PI_FEC_ENT, PI_CODIGO

open cur_actualizaestatus


	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @pimovimiento, @pi_fec_ent

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


		print '<==========' + convert(varchar(50), @picodigo) +' ' +@pi_fec_ent + '==========>' 
	
	
		EXEC sp_fillpedimpdetB @PICODIGO, 1

	FETCH NEXT FROM cur_actualizaestatus INTO @picodigo, @pimovimiento, @pi_fec_ent

END

CLOSE cur_actualizaestatus
DEALLOCATE cur_actualizaestatus


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##PEDIMPCICLO'  AND  type = 'U')
	begin
		drop table ##PEDIMPCICLO
	end






GO
