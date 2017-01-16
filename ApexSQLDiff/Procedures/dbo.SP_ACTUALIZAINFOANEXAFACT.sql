SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ACTUALIZAINFOANEXAFACT] (@pi_codigo int)   as

SET NOCOUNT ON 
																																		-- Corrección Descargas 12-Nov-09 Manuel G.
DECLARE @pi_movimiento char(1), @cp_codigo int, @ccptipo varchar(2), @ConcidenNoPartidas bit
/* este stored se corre desde el sistema del boton actualiza infoanexa que se encuentra en pedimento de importacion
este boton solo esta habilitado en las siguientes opciones = cuando el pedimento sea corriente, cuando si es de salida no sea cambio de regimen
*/

	select @pi_movimiento=pi_movimiento,@cp_codigo=cp_codigo from pedimp where pi_codigo=@pi_codigo

	SELECT @ccptipo = CCP_TIPO
	FROM CONFIGURACLAVEPED
	where CP_CODIGO = @cp_codigo
  -- Correción Descargas 12-Noc-09 Manuel G.
	set @ConcidenNoPartidas=0

	    if @pi_movimiento='E'
	    begin
	       if (SELECT count(*) AS CUENTA FROM FACTIMP INNER JOIN FACTIMPDET ON FACTIMP.FI_CODIGO=FACTIMPDET.FI_CODIGO WHERE PI_CODIGO=@PI_CODIGO OR
		PI_RECTIFICA=@PI_CODIGO)=  (select pi_cuentadet from pedimp where pi_codigo = @PI_CODIGO) 
	       SET @ConcidenNoPartidas = 1
	    end
	    else
	    begin
	       if (SELECT count(*) AS CUENTA FROM FACTEXP INNER JOIN FACTEXPDET ON FACTEXP.FE_CODIGO=FACTEXPDET.FE_CODIGO WHERE PI_CODIGO=@PI_CODIGO OR
		PI_RECTIFICA=@PI_CODIGO)= (select pi_cuentadet from pedimp where pi_codigo = @PI_CODIGO) 
	       SET @ConcidenNoPartidas = 1
	    end
  -- todo este codigo correción descargas
  
	IF @ccptipo='CT' 
	begin
		exec SP_ACTUALIZAINFOANEXACOMPL @pi_codigo
	end
	else
	begin
		-- si no estan agrupados se les pueden pasar los factores de conversion
		-- Linea comentada por correción descargas 12-nov-09 Manuel G.
		-- if (select picf_pedimpsinagrup from pedimpsaaiconfig WHERE PI_CODIGO = @pi_codigo)='S'
		-- Correción Descargas 12-Nov-09 Manuel G.
		if @ConcidenNoPartidas=1
		begin

			if @pi_movimiento='E'
			begin
				if @ccptipo = 'RE'
				begin
					UPDATE dbo.FACTIMPDET
					SET     dbo.FACTIMPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
					dbo.FACTIMPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
					dbo.FACTIMPDET.EQ_IMPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
					dbo.FACTIMPDET.AR_IMPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
					dbo.FACTIMPDET.AR_EXPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
					dbo.FACTIMPDET.FID_RATEEXPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
					dbo.FACTIMPDET.FID_SEC_IMP= isnull(dbo.PEDIMPDET.PID_SEC_IMP,0),
					dbo.FACTIMPDET.FID_DEF_TIP = isnull(dbo.PEDIMPDET.PID_DEF_TIP,'G'),
					dbo.FACTIMPDET.FID_POR_DEF = isnull(dbo.PEDIMPDET.PID_POR_DEF,-1),
					dbo.FACTIMPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
					dbo.FACTIMPDET.PA_CODIGO = isnull(dbo.PEDIMPDET.PA_ORIGEN,0),
					dbo.FACTIMPDET.SPI_CODIGO = isnull(dbo.PEDIMPDET.SPI_CODIGO,0),
					dbo.FACTIMPDET.ME_GEN = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
					dbo.FACTIMPDET.ME_ARIMPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
					dbo.FACTIMPDET.PR_CODIGO = isnull(dbo.PEDIMPDET.PR_CODIGO,0),
					dbo.FACTIMPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
					dbo.FACTIMPDET.FID_NOMBRE = isnull(dbo.PEDIMPDET.PID_NOMBRE,0)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGAR1
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_codigo)
	
				end
				else
				begin
					UPDATE dbo.FACTIMPDET
					SET     dbo.FACTIMPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
					dbo.FACTIMPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
					dbo.FACTIMPDET.EQ_IMPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
					dbo.FACTIMPDET.AR_IMPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
					dbo.FACTIMPDET.AR_EXPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
					dbo.FACTIMPDET.FID_RATEEXPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
					dbo.FACTIMPDET.FID_SEC_IMP = CASE WHEN dbo.PEDIMPDET.PID_SERVICIO = 'S' THEN 0 ELSE isnull(dbo.PEDIMPDET.PID_SEC_IMP,0) END,
					dbo.FACTIMPDET.FID_DEF_TIP = CASE WHEN dbo.PEDIMPDET.PID_SERVICIO = 'S' THEN 'E' ELSE isnull(dbo.PEDIMPDET.PID_DEF_TIP,'G') END,
					dbo.FACTIMPDET.FID_POR_DEF = CASE WHEN dbo.PEDIMPDET.PID_SERVICIO = 'S' THEN 0 ELSE isnull(dbo.PEDIMPDET.PID_POR_DEF,-1) END,
					dbo.FACTIMPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
					dbo.FACTIMPDET.PA_CODIGO = isnull(dbo.PEDIMPDET.PA_ORIGEN,0),
					dbo.FACTIMPDET.SPI_CODIGO = CASE WHEN dbo.PEDIMPDET.PID_SERVICIO = 'S' THEN 0 ELSE isnull(dbo.PEDIMPDET.SPI_CODIGO,0) END,
					dbo.FACTIMPDET.ME_GEN = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
					dbo.FACTIMPDET.ME_ARIMPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
					dbo.FACTIMPDET.PR_CODIGO = isnull(dbo.PEDIMPDET.PR_CODIGO,0),
					dbo.FACTIMPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
					dbo.FACTIMPDET.FID_NOMBRE = isnull(dbo.PEDIMPDET.PID_NOMBRE,0)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGA
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_codigo)
	
	
				end
		
		
			end
			else
			begin
				if @ccptipo = 'RE'
				begin
					UPDATE dbo.FACTEXPDET
					SET     dbo.FACTEXPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
					dbo.FACTEXPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
					dbo.FACTEXPDET.EQ_EXPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
					dbo.FACTEXPDET.AR_EXPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
					dbo.FACTEXPDET.AR_IMPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
					dbo.FACTEXPDET.FED_RATEIMPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
					dbo.FACTEXPDET.FED_RATEEXPMX = isnull(dbo.PEDIMPDET.PID_POR_DEF,-1),
					dbo.FACTEXPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
					dbo.FACTEXPDET.SPI_CODIGO = isnull(dbo.PEDIMPDET.SPI_CODIGO,0),
					dbo.FACTEXPDET.ME_GENERICO = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
					dbo.FACTEXPDET.ME_AREXPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
					dbo.FACTEXPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
					dbo.FACTEXPDET.SE_CODIGO = isnull(dbo.PEDIMPDET.SE_CODIGO,0),
					dbo.FACTEXPDET.FED_DESTNAFTA = isnull(dbo.PEDIMPDET.PID_REGIONFIN,0),
					dbo.FACTEXPDET.FED_NOMBRE = isnull(dbo.PEDIMPDET.PID_NOMBRE,0)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGAR1
					WHERE     (dbo.PEDIMPDET.PI_CODIGO =@pi_codigo)
		
				end
				else
				begin
					UPDATE dbo.FACTEXPDET
					SET     dbo.FACTEXPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
					dbo.FACTEXPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
					dbo.FACTEXPDET.EQ_EXPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
					dbo.FACTEXPDET.AR_EXPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
					dbo.FACTEXPDET.AR_IMPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
					dbo.FACTEXPDET.FED_RATEIMPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
					dbo.FACTEXPDET.FED_RATEEXPMX = isnull(dbo.PEDIMPDET.PID_POR_DEF,-1),
					dbo.FACTEXPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
					dbo.FACTEXPDET.SPI_CODIGO = isnull(dbo.PEDIMPDET.SPI_CODIGO,0),
					dbo.FACTEXPDET.ME_GENERICO = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
					dbo.FACTEXPDET.ME_AREXPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
					dbo.FACTEXPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
					dbo.FACTEXPDET.SE_CODIGO = isnull(dbo.PEDIMPDET.SE_CODIGO,0),
					dbo.FACTEXPDET.FED_DESTNAFTA = isnull(dbo.PEDIMPDET.PID_REGIONFIN,0),
					dbo.FACTEXPDET.FED_NOMBRE = isnull(dbo.PEDIMPDET.PID_NOMBRE,0)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_codigo)
				end
			end

		end
		else
		begin

			if @pi_movimiento='E'
			begin
				if @ccptipo = 'RE'
				begin
					UPDATE dbo.FACTIMPDET
					SET     dbo.FACTIMPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
					--dbo.FACTIMPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
					--dbo.FACTIMPDET.EQ_IMPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
					dbo.FACTIMPDET.AR_IMPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
					dbo.FACTIMPDET.AR_EXPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
					dbo.FACTIMPDET.FID_RATEEXPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
					dbo.FACTIMPDET.FID_SEC_IMP= isnull(dbo.PEDIMPDET.PID_SEC_IMP,0),
					dbo.FACTIMPDET.FID_DEF_TIP = isnull(dbo.PEDIMPDET.PID_DEF_TIP,'G'),
					dbo.FACTIMPDET.FID_POR_DEF = isnull(dbo.PEDIMPDET.PID_POR_DEF,-1),
					dbo.FACTIMPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
					dbo.FACTIMPDET.PA_CODIGO = isnull(dbo.PEDIMPDET.PA_ORIGEN,0),
					dbo.FACTIMPDET.SPI_CODIGO = isnull(dbo.PEDIMPDET.SPI_CODIGO,0),
					dbo.FACTIMPDET.ME_GEN = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
					dbo.FACTIMPDET.ME_ARIMPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
					dbo.FACTIMPDET.PR_CODIGO = isnull(dbo.PEDIMPDET.PR_CODIGO,0),
					dbo.FACTIMPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
					dbo.FACTIMPDET.FID_NOMBRE = isnull(dbo.PEDIMPDET.PID_NOMBRE,0)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGAR1
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_codigo)
	
	
					/*UPDATE dbo.FACTIMPDET
					SET     dbo.FACTIMPDET.EQ_GEN = ROUND(dbo.FACTIMPDET.FID_PES_UNI,6)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGAR1
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDET.pi_codigo)
					AND dbo.FACTIMPDET.ME_GEN IN (select ME_KILOGRAMOS from configuracion) and ROUND(dbo.FACTIMPDET.FID_PES_UNI,6) > 0
					AND (dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDET.pi_codigo)
	
					UPDATE dbo.FACTIMPDET
					SET     dbo.FACTIMPDET.EQ_IMPMX =	dbo.FACTIMPDET.EQ_GEN
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGAR1
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDET.pi_codigo)
					AND dbo.FACTIMPDET.ME_ARIMPMX=dbo.FACTIMPDET.ME_GEN
					AND (dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDET.pi_codigo)	*/
				end
				else
				begin
					UPDATE dbo.FACTIMPDET
					SET     dbo.FACTIMPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
					--dbo.FACTIMPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
					--dbo.FACTIMPDET.EQ_IMPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
					dbo.FACTIMPDET.AR_IMPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
					dbo.FACTIMPDET.AR_EXPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
					dbo.FACTIMPDET.FID_RATEEXPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
					dbo.FACTIMPDET.FID_SEC_IMP = CASE WHEN dbo.PEDIMPDET.PID_SERVICIO = 'S' THEN 0 ELSE isnull(dbo.PEDIMPDET.PID_SEC_IMP,0) END,
					dbo.FACTIMPDET.FID_DEF_TIP = CASE WHEN dbo.PEDIMPDET.PID_SERVICIO = 'S' THEN 'E' ELSE isnull(dbo.PEDIMPDET.PID_DEF_TIP,'G') END,
					dbo.FACTIMPDET.FID_POR_DEF = CASE WHEN dbo.PEDIMPDET.PID_SERVICIO = 'S' THEN 0 ELSE isnull(dbo.PEDIMPDET.PID_POR_DEF,-1) END,
					dbo.FACTIMPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
					dbo.FACTIMPDET.PA_CODIGO = isnull(dbo.PEDIMPDET.PA_ORIGEN,0),
					dbo.FACTIMPDET.SPI_CODIGO = CASE WHEN dbo.PEDIMPDET.PID_SERVICIO = 'S' THEN 0 ELSE isnull(dbo.PEDIMPDET.SPI_CODIGO,0) END,
					dbo.FACTIMPDET.ME_GEN = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
					dbo.FACTIMPDET.ME_ARIMPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
					dbo.FACTIMPDET.PR_CODIGO = isnull(dbo.PEDIMPDET.PR_CODIGO,0),
					dbo.FACTIMPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
					dbo.FACTIMPDET.FID_NOMBRE = isnull(dbo.PEDIMPDET.PID_NOMBRE,0)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGA
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_codigo)
	
	
	
	
					/*UPDATE dbo.FACTIMPDET
					SET     dbo.FACTIMPDET.EQ_GEN = ROUND(dbo.FACTIMPDET.FID_PES_UNI,6)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGA
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDET.pi_codigo)
					AND dbo.FACTIMPDET.ME_GEN IN (select ME_KILOGRAMOS from configuracion) and ROUND(dbo.FACTIMPDET.FID_PES_UNI,6) > 0
					AND (dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDET.pi_codigo)
	
					UPDATE dbo.FACTIMPDET
					SET     dbo.FACTIMPDET.EQ_IMPMX =	dbo.FACTIMPDET.EQ_GEN
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTIMPDET.PID_INDICEDLIGA
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDET.pi_codigo)
					AND dbo.FACTIMPDET.ME_ARIMPMX=dbo.FACTIMPDET.ME_GEN
					AND (dbo.PEDIMPDET.PI_CODIGO = dbo.PEDIMPDET.pi_codigo)*/
				end
		
		
			end
			else
			begin
				if @ccptipo = 'RE'
				begin
					UPDATE dbo.FACTEXPDET
					SET     dbo.FACTEXPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
					--dbo.FACTEXPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
					--dbo.FACTEXPDET.EQ_EXPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
					dbo.FACTEXPDET.AR_EXPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
					dbo.FACTEXPDET.AR_IMPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
					dbo.FACTEXPDET.FED_RATEIMPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
					dbo.FACTEXPDET.FED_RATEEXPMX = isnull(dbo.PEDIMPDET.PID_POR_DEF,-1),
					dbo.FACTEXPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
					dbo.FACTEXPDET.SPI_CODIGO = isnull(dbo.PEDIMPDET.SPI_CODIGO,0),
					dbo.FACTEXPDET.ME_GENERICO = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
					dbo.FACTEXPDET.ME_AREXPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
					dbo.FACTEXPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
					dbo.FACTEXPDET.SE_CODIGO = isnull(dbo.PEDIMPDET.SE_CODIGO,0),
					dbo.FACTEXPDET.FED_DESTNAFTA = isnull(dbo.PEDIMPDET.PID_REGIONFIN,0),
					dbo.FACTEXPDET.FED_NOMBRE = isnull(dbo.PEDIMPDET.PID_NOMBRE,0)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGAR1
					WHERE     (dbo.PEDIMPDET.PI_CODIGO =@pi_codigo)
		
				end
				else
				begin
					UPDATE dbo.FACTEXPDET
					SET     dbo.FACTEXPDET.MA_GENERICO= isnull(dbo.PEDIMPDET.MA_GENERICO,0),
					--dbo.FACTEXPDET.EQ_GEN = isnull(dbo.PEDIMPDET.EQ_GENERICO,1),
					--dbo.FACTEXPDET.EQ_EXPMX = isnull(dbo.PEDIMPDET.EQ_IMPMX,1),
					dbo.FACTEXPDET.AR_EXPMX = isnull(dbo.PEDIMPDET.AR_IMPMX,0),
					dbo.FACTEXPDET.AR_IMPFO = isnull(dbo.PEDIMPDET.AR_EXPFO,0),
					dbo.FACTEXPDET.FED_RATEIMPFO = isnull(dbo.PEDIMPDET.PID_RATEEXPFO,-1),
					dbo.FACTEXPDET.FED_RATEEXPMX = isnull(dbo.PEDIMPDET.PID_POR_DEF,-1),
					dbo.FACTEXPDET.TI_CODIGO = isnull(dbo.PEDIMPDET.TI_CODIGO,0),
					dbo.FACTEXPDET.SPI_CODIGO = isnull(dbo.PEDIMPDET.SPI_CODIGO,0),
					dbo.FACTEXPDET.ME_GENERICO = isnull(dbo.PEDIMPDET.ME_GENERICO,0),
					dbo.FACTEXPDET.ME_AREXPMX = isnull(dbo.PEDIMPDET.ME_ARIMPMX,0),
					dbo.FACTEXPDET.CS_CODIGO = isnull(dbo.PEDIMPDET.CS_CODIGO,0),
					dbo.FACTEXPDET.SE_CODIGO = isnull(dbo.PEDIMPDET.SE_CODIGO,0),
					dbo.FACTEXPDET.FED_DESTNAFTA = isnull(dbo.PEDIMPDET.PID_REGIONFIN,0),
					dbo.FACTEXPDET.FED_NOMBRE = isnull(dbo.PEDIMPDET.PID_NOMBRE,0)
					FROM         dbo.PEDIMPDET LEFT OUTER JOIN
					                      dbo.FACTEXPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.FACTEXPDET.PID_INDICEDLIGA
					WHERE     (dbo.PEDIMPDET.PI_CODIGO = @pi_codigo)
				end
			end
		end
	end


	EXEC SP_ACTUALIZAIDENTIFICA @pi_codigo

GO
