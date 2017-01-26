SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_fillpedExpDetBArt303Periodo]  @fechaini varchar(10), @fechafin varchar(10), @CrearTablas char(1)='N'   as

SET NOCOUNT ON

declare @picodigo int, @PI_FEC_PAG datetime
	
	DECLARE cur_PedexpBArt303 CURSOR FOR
	
		SELECT     TOP 100 PERCENT dbo.VPEDEXP.PI_CODIGO
		FROM          dbo.VPEDEXP INNER JOIN
		                      dbo.CLAVEPED ON dbo.VPEDEXP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO  LEFT OUTER JOIN 
			        dbo.CONFIGURACLAVEPED ON dbo.CONFIGURACLAVEPED.CP_CODIGO=dbo.VPEDEXP.CP_CODIGO
		WHERE      (dbo.CLAVEPED.CP_ART303 = 'S') AND dbo.CONFIGURACLAVEPED.CCP_TIPO='ER' 
			AND dbo.VPEDEXP.PI_DESP_EQUIPO='N' 
			AND (dbo.VPEDEXP.PI_FEC_PAG >= @fechaini) AND (dbo.VPEDEXP.PI_FEC_PAG <= @fechafin) 
			and dbo.VPEDEXP.PI_CODIGO in (select pi_codigo from pedimpdet)
		GROUP BY dbo.VPEDEXP.PI_CODIGO, dbo.VPEDEXP.PI_FEC_PAG
		ORDER BY dbo.VPEDEXP.PI_FEC_PAG, dbo.VPEDEXP.PI_CODIGO

	OPEN cur_PedexpBArt303
	
	FETCH NEXT FROM cur_PedexpBArt303 INTO @picodigo
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @PI_FEC_PAG=PI_FEC_PAG from PEDIMP where PI_CODIGO=@picodigo

	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @PI_FEC_PAG) + '==========>' 


		exec sp_fillpedExpDetBArt303 @picodigo, @CrearTablas

		if (select cf_pagocontribucion from configuracion)='J'
		begin
			exec sp_fillpedimpdetidentificaDT @picodigo
	
	
			-- contribucion 303
			if exists (select * from pedimpdetbcontribucion where pi_codigo =@picodigo and con_codigo in (select con_codigo from contribucion where con_abrevia='303'))
			delete from pedimpdetbcontribucion where pi_codigo=@picodigo and con_codigo in (select con_codigo from contribucion where con_abrevia='303')
		
			insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)				
			SELECT     @picodigo, (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0'), (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), (select con_codigo from contribucion where con_abrevia='303'),
				     ROUND((PIB_IMPORTECONTR/PIB_VAL_ADU)*100,6), PIB_IMPORTECONTR, PEDIMPDETB.PIB_INDICEB			FROM         PEDIMPDETB 
			WHERE     (PEDIMPDETB.PI_CODIGO = @picodigo) and PEDIMPDETB.PIB_INDICEB IS NOT NULL
			                  and PIB_IMPORTECONTR>0	
		end


		FETCH NEXT FROM cur_PedexpBArt303 INTO @picodigo
	
	END
	
	CLOSE cur_PedexpBArt303
	DEALLOCATE cur_PedexpBArt303


	-----======================= en caso de los complementarios ==================================
	IF EXISTS (SELECT     TOP 100 PERCENT dbo.VPEDEXP.PI_CODIGO
		FROM          dbo.VPEDEXP INNER JOIN
		                      dbo.CLAVEPED ON dbo.VPEDEXP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO  LEFT OUTER JOIN 
			        dbo.CONFIGURACLAVEPED ON dbo.CONFIGURACLAVEPED.CP_CODIGO=dbo.VPEDEXP.CP_CODIGO
		WHERE      dbo.CONFIGURACLAVEPED.CCP_TIPO='CT' 
			AND (dbo.VPEDEXP.PI_FEC_PAG >= @fechaini) AND (dbo.VPEDEXP.PI_FEC_PAG <= @fechafin) 
			and dbo.VPEDEXP.PI_CODIGO in (select pi_codigo from pedimpdet)
		GROUP BY dbo.VPEDEXP.PI_CODIGO)
	begin


		DECLARE cur_PedexpBArt303Falta CURSOR FOR
			SELECT     TOP 100 PERCENT dbo.VPEDEXP.PI_CODIGO
			FROM          dbo.VPEDEXP INNER JOIN
			                      dbo.CLAVEPED ON dbo.VPEDEXP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO INNER JOIN
					VPEDEXP VPEDEXPcomp ON dbo.VPEDEXP.PI_COMPLEMENTA=VPEDEXPcomp.PI_CODIGO LEFT OUTER JOIN 
				        dbo.CONFIGURACLAVEPED ON dbo.CONFIGURACLAVEPED.CP_CODIGO=VPEDEXPcomp.CP_CODIGO
			WHERE dbo.CONFIGURACLAVEPED.CCP_TIPO='CT'  and (VPEDEXPcomp.PI_FEC_PAG >= @fechaini) AND (VPEDEXPcomp.PI_FEC_PAG <= @fechafin) 
				and dbo.VPEDEXP.PI_CODIGO in (select pi_codigo from pedimpdet) and
			dbo.VPEDEXP.PI_CODIGO not in (SELECT    VPEDEXP2.PI_CODIGO
					FROM          dbo.VPEDEXP VPEDEXP2 INNER JOIN
					                      dbo.CLAVEPED ON VPEDEXP2.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO  LEFT OUTER JOIN 
						        dbo.CONFIGURACLAVEPED ON dbo.CONFIGURACLAVEPED.CP_CODIGO=VPEDEXP2.CP_CODIGO
					WHERE      (dbo.CLAVEPED.CP_ART303 = 'S') AND dbo.CONFIGURACLAVEPED.CCP_TIPO='ER' 
						AND VPEDEXP2.PI_DESP_EQUIPO='N' 
						AND (VPEDEXP2.PI_FEC_PAG >= @fechaini) AND (VPEDEXP2.PI_FEC_PAG <= @fechafin) 
						and VPEDEXP2.PI_CODIGO in (select pi_codigo from pedimpdet)
					GROUP BY VPEDEXP2.PI_CODIGO)
	
			GROUP BY dbo.VPEDEXP.PI_CODIGO, dbo.VPEDEXP.PI_FEC_PAG
			ORDER BY dbo.VPEDEXP.PI_FEC_PAG, dbo.VPEDEXP.PI_CODIGO
		
	
	
		OPEN cur_PedexpBArt303Falta
		
		FETCH NEXT FROM cur_PedexpBArt303Falta INTO @picodigo
		
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	
		select @PI_FEC_PAG=PI_FEC_PAG from PEDIMP where PI_CODIGO=@picodigo
	
		print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @PI_FEC_PAG) + '==========>' 
	
	
			exec sp_fillpedExpDetBArt303 @picodigo, @CrearTablas
			
	
			FETCH NEXT FROM cur_PedexpBArt303Falta INTO @picodigo
		
		END
		
		CLOSE cur_PedexpBArt303Falta
		DEALLOCATE cur_PedexpBArt303Falta




	DECLARE cur_PedexpComplArt303 CURSOR FOR
	
		SELECT     TOP 100 PERCENT dbo.VPEDEXP.PI_CODIGO
		FROM          dbo.VPEDEXP INNER JOIN
		                      dbo.CLAVEPED ON dbo.VPEDEXP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO  LEFT OUTER JOIN 
			        dbo.CONFIGURACLAVEPED ON dbo.CONFIGURACLAVEPED.CP_CODIGO=dbo.VPEDEXP.CP_CODIGO
		WHERE      dbo.CONFIGURACLAVEPED.CCP_TIPO='CT' 
			AND (dbo.VPEDEXP.PI_FEC_PAG >= @fechaini) AND (dbo.VPEDEXP.PI_FEC_PAG <= @fechafin) 
			and dbo.VPEDEXP.PI_CODIGO in (select pi_codigo from pedimpdet)
		GROUP BY dbo.VPEDEXP.PI_CODIGO, dbo.VPEDEXP.PI_FEC_PAG
		ORDER BY dbo.VPEDEXP.PI_FEC_PAG, dbo.VPEDEXP.PI_CODIGO

	OPEN cur_PedexpComplArt303
	
	FETCH NEXT FROM cur_PedexpComplArt303 INTO @picodigo
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	select @PI_FEC_PAG=PI_FEC_PAG from PEDIMP where PI_CODIGO=@picodigo

	print '<==========' + convert(varchar(50), @picodigo) + + convert(varchar(50), @PI_FEC_PAG) + '==========>' 


		exec sp_fillpedExpComplArt303 @picodigo, 'S'
		

		FETCH NEXT FROM cur_PedexpComplArt303 INTO @picodigo
	
	END
	
	CLOSE cur_PedexpComplArt303
	DEALLOCATE cur_PedexpComplArt303
	end




GO
