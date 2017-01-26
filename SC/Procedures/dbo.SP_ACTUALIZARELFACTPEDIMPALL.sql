SET ANSI_NULLS OFF
SET QUOTED_IDENTIFIER OFF
GO















CREATE PROCEDURE [SP_ACTUALIZARELFACTPEDIMPALL] AS


declare @picodigo int, @pimovimiento char(1), @pi_fec_pag datetime, @cpcodigo int, @ccp_tipo varchar(5)

declare cur_actualizaRelFact cursor for
	SELECT     PI_CODIGO, PI_MOVIMIENTO, CP_CODIGO
	FROM         dbo.PEDIMP
	WHERE PI_TIPO='C'
	ORDER BY PI_FEC_PAG, PI_CODIGO

open cur_actualizaRelFact


	FETCH NEXT FROM cur_actualizaRelFact INTO @picodigo, @pimovimiento, @cpcodigo

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo=@cpcodigo

		select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo
	
	

	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 

	if @ccp_tipo<>'RE'
	begin
		if @pimovimiento='E'
		begin
			if exists(select * from pedimpfact where pi_codigo=@picodigo)
				update factimp
				set pi_codigo=@picodigo
				where fi_codigo in (select fi_codigo from pedimpfact where pi_codigo=@picodigo)
			else
				if exists (select * from factimp where pi_codigo=@picodigo)
				exec sp_fillpedimpfact @picodigo
		end

		if @pimovimiento='S' 
		begin
			if exists(select * from pedimpfact where pi_codigo=@picodigo)
				update factexp
				set pi_codigo=@picodigo
				where fe_codigo in (select fi_codigo from pedimpfact where pi_codigo=@picodigo)
			else
				if exists (select * from factexp where pi_codigo=@picodigo)
				exec sp_fillpedexpfact @picodigo


		end




	end
	else
	begin
		if @pimovimiento='E' 
		begin
			if exists(select * from pedimpfact where pi_codigo=@picodigo)
				update factimp
				set pi_rectifica=@picodigo
				where fi_codigo in (select fi_codigo from pedimpfact where pi_codigo=@picodigo)
			else
				if exists (select * from factimp where pi_rectifica=@picodigo)
				exec sp_fillpedimpfact_rect @picodigo
		end
		

		if @pimovimiento='S' 
		begin
			if exists(select * from pedimpfact where pi_codigo=@picodigo)
				update factexp
				set pi_rectifica=@picodigo
				where fe_codigo in (select fi_codigo from pedimpfact where pi_codigo=@picodigo)
			else
				if exists (select * from factexp where pi_rectifica=@picodigo)
				exec sp_fillpedexpfact_rect @picodigo

		end
	end





	FETCH NEXT FROM cur_actualizaRelFact INTO @picodigo, @pimovimiento, @cpcodigo

END

CLOSE cur_actualizaRelFact
DEALLOCATE cur_actualizaRelFact














GO
