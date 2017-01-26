SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE PROCEDURE [dbo].[SP_ACTUALIZADETALLEPEDIMPCONCILIAALL]   as

SET NOCOUNT ON 
declare @picodigo int, @pimovimiento char(1), @cp_codigo int, @ccp_tipo varchar(5), @pi_tipo char(1), @pi_estatus char(1),
@pi_fec_pag datetime, @PI_VALOR_ME decimal(38,6), @TotalFI decimal(38,6), @TotalFE decimal(38,6)


	declare cur_actualizadetimp cursor for
		SELECT     TOP 100 PERCENT VPEDIMP.PI_CODIGO, VPEDIMP.CP_CODIGO, VPEDIMP.PI_TIPO, 
		                      VPEDIMP.PI_ESTATUS, VPEDIMP.PI_VALOR_ME
		FROM         VPEDIMP INNER JOIN
		                      dbo.VFACTIMPSUMCOSTOT ON VPEDIMP.PI_CODIGO = dbo.VFACTIMPSUMCOSTOT.PI_CODIGO AND ROUND(VPEDIMP.PI_VALOR_ME, 2) 
		                      <> ROUND(dbo.VFACTIMPSUMCOSTOT.FID_COS_TOT, 2) 
		GROUP BY VPEDIMP.PI_CODIGO, VPEDIMP.CP_CODIGO, VPEDIMP.PI_TIPO, VPEDIMP.PI_ESTATUS, 
		                      VPEDIMP.PI_FEC_PAG, VPEDIMP.PI_VALOR_ME
		ORDER BY VPEDIMP.PI_FEC_PAG, VPEDIMP.PI_CODIGO
	open cur_actualizadetimp
	
	
		FETCH NEXT FROM cur_actualizadetimp INTO @picodigo, @cp_codigo, @pi_tipo, @pi_estatus, @PI_VALOR_ME
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
		select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo=@cp_codigo
	
		select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo


		print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 
	
	
		if (@PI_ESTATUS not in ('A', 		-- ABIERTO - AFECTADO
		'C',  					-- CERRADO
		'F',  					-- RECTIFICACION - AFECTADA
		'G'))					-- RECTIFICACION - CERRADA
	
		begin
	
			if @pi_tipo='C'		--Corriente
			begin
				if @ccp_tipo<>'RE'
				begin

					if @ccp_tipo='CN' OR (@ccp_tipo='RG' and (select PI_DESP_EQUIPO from pedimp where  pi_codigo=@PICODIGO)='S')
					begin
							exec SP_ACTUALIZAINFOANEXAFACT @PICODIGO
							exec sp_fillpedimp_rect @PICODIGO, 1	--pedimento de importacion 

					end
					else
						if @TotalFI <> @PI_VALOR_ME
						begin
							exec SP_ACTUALIZAINFOANEXAFACT @PICODIGO
							EXEC sp_fillpedimp @PICODIGO, 1		--pedimento de importacion 
						end
				end
				else
						if @TotalFI <> @PI_VALOR_ME or @TotalFE <> @PI_VALOR_ME
						begin
  							exec SP_ACTUALIZAINFOANEXAFACT @PICODIGO
							EXEC sp_fillpedimp_rect @PICODIGO, 1		--rectificacion
						end

			end
		end
	
	
		-- actualiza el estatus del pedimento 
		exec SP_ACTUALIZAESTATUSPEDIMP @picodigo, @cp_codigo
	
		FETCH NEXT FROM cur_actualizadetimp INTO @picodigo, @cp_codigo, @pi_tipo, @pi_estatus, @PI_VALOR_ME
	
	END
	
	CLOSE cur_actualizadetimp
	DEALLOCATE cur_actualizadetimp


/* pedimentos de salida */

	declare cur_actualizadetexp cursor for
		SELECT     TOP 100 PERCENT VPEDEXP.PI_CODIGO, VPEDEXP.CP_CODIGO, VPEDEXP.PI_TIPO, 
		                      VPEDEXP.PI_ESTATUS, PI_VALOR_ME
		FROM         VPEDEXP INNER JOIN
		                      dbo.VFACTEXPSUMCOSTOT ON VPEDEXP.PI_CODIGO = dbo.VFACTEXPSUMCOSTOT.PI_CODIGO AND ROUND(VPEDEXP.PI_VALOR_ME, 2) 
		                      <> ROUND(dbo.VFACTEXPSUMCOSTOT.FED_COS_TOT, 2)
		GROUP BY VPEDEXP.PI_CODIGO, VPEDEXP.CP_CODIGO, VPEDEXP.PI_TIPO, VPEDEXP.PI_ESTATUS, 
		                      VPEDEXP.PI_FEC_PAG, PI_VALOR_ME
		ORDER BY VPEDEXP.PI_FEC_PAG, VPEDEXP.PI_CODIGO
	open cur_actualizadetexp
	
	
		FETCH NEXT FROM cur_actualizadetexp INTO @picodigo, @cp_codigo, @pi_tipo, @pi_estatus, @PI_VALOR_ME
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
		select @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo=@cp_codigo
	
		select @pi_fec_pag=pi_fec_pag from pedimp where pi_codigo=@picodigo


		print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @pi_fec_pag) + '==========>' 
	
	
		if (@PI_ESTATUS not in ('A', 		-- ABIERTO - AFECTADO
		'C',  					-- CERRADO
		'F',  					-- RECTIFICACION - AFECTADA
		'G'))					-- RECTIFICACION - CERRADA
	
		begin
	
			if @pi_tipo='C'		--Corriente
			begin
				if @ccp_tipo<>'RE'
				begin
					if @pimovimiento='S'	--Corriente de salida
						if @TotalFE <> @PI_VALOR_ME
						EXEC sp_fillpedexp @PICODIGO, 1		--pedimento de exportacion
				end
				else
						if @TotalFI <> @PI_VALOR_ME or @TotalFE <> @PI_VALOR_ME
						EXEC sp_fillpedimp_rect @PICODIGO, 1		--rectificacion

			end
		end
	
	
		-- actualiza el estatus del pedimento 
		exec SP_ACTUALIZAESTATUSPEDIMP @picodigo, @cp_codigo
	
		FETCH NEXT FROM cur_actualizadetexp INTO @picodigo, @cp_codigo, @pi_tipo, @pi_estatus, @PI_VALOR_ME
	
	END
	
	CLOSE cur_actualizadetexp
	DEALLOCATE cur_actualizadetexp


GO
