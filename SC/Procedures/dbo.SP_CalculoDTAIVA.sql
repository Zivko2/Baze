SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_CalculoDTAIVA] (@picodigo int, @user int)   as

SET NOCOUNT ON 
declare @fecha datetime, @IVA decimal(38,6), @ValorDTA decimal(38,6), @coniva char(1), @pi_movimiento char(1), @ccp_tipo varchar(2), @ccptipo2 varchar(2), @totalpartidasdta integer,
@dummy varchar(3), @dtaPorcenta decimal(38,6), @IVAtasa decimal(38,6), @conISAN char(1), @valoraduanatotal decimal(38,6), @cf_ivaproporcional char(1), @PI_FRAN_INT char(1),
@FechaActual varchar(10), @hora varchar(15), @em_codigo int, @cp_codigo int, @pg_codigo2 int, @totalPartidasAgrupacion int, @cp_clave varchar(3)

	select @fecha=pi_fec_pag, @pi_movimiento=pi_movimiento, @PI_FRAN_INT=PI_FRAN_INT, @cp_codigo=cp_codigo from pedimp where pi_codigo=@picodigo


	select  @ccp_tipo=ccp_tipo from configuraclaveped where cp_codigo =@cp_codigo


	select @ccptipo2=ccp_tipo from configuraclaveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo in (select pi_rectifica from pedimp where pi_codigo=@PICODIGO))

	IF (@ccp_tipo='RP' or @ccptipo2='RP') and @PI_FRAN_INT<>'I'
	begin
		update pedimp
		set PI_FRAN_INT='I'
		where pi_codigo=@picodigo
	
		set @PI_FRAN_INT='I'
	end


	select @cf_ivaproporcional = max(PICF_IVAPROPORCIONAL) from PEDIMPSAAICONFIG where pi_codigo=@picodigo

	exec sp_calculoDTA  @picodigo, @pi_movimiento, @ccp_tipo, @user, @tipodta=@dummy output


	SET @FechaActual = convert(varchar(10), getdate(),101)

	select @em_codigo=em_codigo from intradeglobal.dbo.empresa where em_corto in
	(select replace(convert(sysname,db_name()),'intrade',''))

	select @hora =substring(convert(varchar(100),getdate(),9),13,8)+' '+substring(convert(varchar(100),getdate(),9),25,2)

	insert into IntradeGlobal.dbo.Avance (sysuslst_id, ava_mensajeno, ava_info, ava_infoing, ava_fecha, ava_hora, em_codigo)
	values (@user, 2, 'Calculando IVA ', 'Calculating IVA ', convert(varchar(10),@FechaActual,101), @hora, @em_codigo)

	SELECT     @pg_codigo2=PG_CODIGO
	FROM         CONFIGURACONTRIBTPAGO
	WHERE     (CP_CODIGO = @CP_CODIGO) AND (CFC_MOVIMIENTO = @pi_movimiento) AND CON_CODIGO in (select con_codigo from contribucion where con_clave='3')

	if @pg_codigo2 is null
	set @pg_codigo2=0


	-- cuotas compensatorias
	if @CCP_TIPO='IE' and @pi_movimiento='E' 
	begin
		if exists (select * from pedimpdetbcontribucion where pi_codigo =@picodigo and con_codigo in (select con_codigo from contribucion where con_clave='2'))
		delete from pedimpdetbcontribucion where pi_codigo=@picodigo and con_codigo in (select con_codigo from contribucion where con_clave='2')
	
		insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)				
		SELECT     @picodigo, (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0'), (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), (select con_codigo from contribucion where con_clave='2'),
			     ARANCELCC.TASA, round(PEDIMPDETB.PIB_VAL_ADU * ARANCELCC.TASA / 100,0), PEDIMPDETB.PIB_INDICEB		FROM         ARANCELCC INNER JOIN
		                      PEDIMPDETB ON ARANCELCC.AR_CODIGO = PEDIMPDETB.AR_IMPMX AND ARANCELCC.PA_CODIGO = PEDIMPDETB.PA_ORIGEN
		WHERE     (PEDIMPDETB.PI_CODIGO = @picodigo) and PEDIMPDETB.PIB_INDICEB IS NOT NULL
		                  and ARANCELCC.TASA>0
	end

/*	if @conISAN='S'
	begin
		--print 'hola'
		algunas fracciones para automoviles nuevos
		(87021001, 87021002, 87021003, 87021004, 87029002, 
		87029003, 87029004, 87029005, 87032199, 87032201, 
		87032301, 87032401, 87033101, 87033201, 87033301, 
		87039099, 87042102, 87042103, 87042199, 87042202, 
		87042203, 87042204, 87042205, 87043103, 87043199, 
		87043202, 87043203, 87043204, 87043205, 87060002)
		checar tambien que sea --nuevo--


	end
*/

--	select @valoraduanatotal=round(pi_valor_adu,0) from vpedimpvalores where pi_codigo=@picodigo
	if (select cp_usanaftadta from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo))='S'
	begin
		-- toma todas las partidas
		SELECT     @valoraduanatotal=SUM(ROUND(PID_VAL_ADU, 2)) 
		FROM  dbo.PEDIMPDET
		WHERE dbo.PEDIMPDET.PID_IMPRIMIR = 'S'
		GROUP BY PI_CODIGO
		HAVING      (PI_CODIGO = @picodigo)

	end
	else
	begin
		if (SELECT count(*) FROM  VSPIVALADU GROUP BY PI_CODIGO HAVING  PI_CODIGO = @picodigo)>0
		-- toma solo las partidas que son diferentes de nafta
			SELECT     @valoraduanatotal=SUM(ROUND(PID_VAL_ADU, 2)) 
			FROM  VSPIVALADU
			GROUP BY PI_CODIGO
			HAVING      (PI_CODIGO = @picodigo)
		else
			set @valoraduanatotal=0
	end



	SELECT     @dtaPorcenta=case when CLAVEPED.CP_PAGODTA='O' then .008 when CLAVEPED.CP_PAGODTA='U' then .00176
		else 0 end FROM  CLAVEPED INNER JOIN PEDIMP ON CLAVEPED.CP_CODIGO = PEDIMP.CP_CODIGO
	WHERE     (PEDIMP.PI_CODIGO = @picodigo)



	if exists (select * from pedimp where pi_codigo =@picodigo and (cp_codigo in 
		(SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('CN', 'OC', 'RG', 'ED')) or
		 (cp_codigo in  (SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('IE', 'RP')) and pi_movimiento='E') or
		 (cp_codigo in  (SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('RE')) and cp_rectifica in  (SELECT CP_CODIGO from configuraclaveped WHERE CCP_TIPO IN ('IE', 'RP')) and pi_movimiento='E')))
	begin
		set @coniva='S'
	end
	else
	begin
		set @coniva='N'
	end


	--print @coniva

	if @coniva='S'
	begin
		
	
	
		-- dta
		if (SELECT count(*) FROM         dbo.VPEDIMPCONTRIBUCION LEFT OUTER JOIN
	                 dbo.CONTRIBUCION ON dbo.VPEDIMPCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO
		    WHERE     dbo.CONTRIBUCION.CON_CLAVE = '1' AND dbo.VPEDIMPCONTRIBUCION.PI_CODIGO = @picodigo)>0

		SELECT     @ValorDTA=round(dbo.VPEDIMPCONTRIBUCION.PIT_CONTRIBTOTMN,0)
		FROM         dbo.VPEDIMPCONTRIBUCION LEFT OUTER JOIN
		                      dbo.CONTRIBUCION ON dbo.VPEDIMPCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO
		WHERE     (dbo.CONTRIBUCION.CON_CLAVE = '1') AND (dbo.VPEDIMPCONTRIBUCION.PI_CODIGO = @picodigo)
	           else
		SET     @ValorDTA=0

		if @PI_FRAN_INT<>'I' 
		begin
			SELECT     @IVA=isnull(CONTRIBUCIONFIJA.COF_VALOR,0)/100
			FROM         CONTRIBUCIONFIJA INNER JOIN
			                      CONFIGURACONTRIBUCION ON CONTRIBUCIONFIJA.CON_CODIGO = CONFIGURACONTRIBUCION.CON_CODIGO AND 
			                      CONTRIBUCIONFIJA.COF_TIPOVALOR = CONFIGURACONTRIBUCION.CFB_TIPO
			WHERE     (CONTRIBUCIONFIJA.CON_CODIGO in(select con_codigo from contribucion where con_clave='3')) AND 
			(CONTRIBUCIONFIJA.COF_PERINI <=@fecha) AND (CONTRIBUCIONFIJA.COF_PERFIN >=@fecha)
	
	
			SELECT     @IVAtasa=isnull(CONTRIBUCIONFIJA.COF_VALOR,0)
			FROM         CONTRIBUCIONFIJA INNER JOIN
			                      CONFIGURACONTRIBUCION ON CONTRIBUCIONFIJA.CON_CODIGO = CONFIGURACONTRIBUCION.CON_CODIGO AND 
			                      CONTRIBUCIONFIJA.COF_TIPOVALOR = CONFIGURACONTRIBUCION.CFB_TIPO
			WHERE     (CONTRIBUCIONFIJA.CON_CODIGO in(select con_codigo from contribucion where con_clave='3')) AND 
			(CONTRIBUCIONFIJA.COF_PERINI <=@fecha) AND (CONTRIBUCIONFIJA.COF_PERFIN >=@fecha)
		end
		else
		begin
			IF @ccp_tipo='RP' /* reexpedicion, es el 5% porque es el restante del cambio del C1=10 hacia el interior=15 */
					  /* para el 2010 el iva cambio al 16% para el interior*/
			begin
				SET @IVA=.05
				SET @IVAtasa=5
			end
			else
			begin
				/*
				SET @IVA=.16
				SET @IVAtasa=16
				*/
				--Yolanda Avila
				--2010-10-29
				--Tasa del iva al interior de la republica de acuerdo al periodo de vigencia
				if @fecha < '2010-01-01' 
				begin
					SET @IVA=.15
					SET @IVAtasa=15
				end 

				if @fecha >= '2010-01-01' 
				begin
					SET @IVA=.16
					SET @IVAtasa=16
				end 
			end
		end
		
		select @totalpartidasdta = count(*) from pedimpdetb where pi_codigo = @picodigo and dbo.PEDIMPDETB.PIB_DESTNAFTA = 'N'
		--select @totalpartidasdta  = count(*) from pedimpdet where pi_codigo = @picodigo and PID_DEF_TIP <> 'P' --and pa_origen not in (select pa_codigo from pais where pa_corto in ('USA','MX','CA'))
		select @totalpartidasAgrupacion = count(*) from pedimpdetb where pi_codigo = @picodigo 
		select @cp_clave = cp_clave from claveped where cp_codigo = @cp_codigo



		if exists (select * from pedimpdetbcontribucion where pi_codigo =@picodigo and con_codigo in(select con_codigo from contribucion where con_clave='3'))
		delete from pedimpdetbcontribucion where pi_codigo=@picodigo and con_codigo in(select con_codigo from contribucion where con_clave='3')
	

--	IVA = Redondeo[(Valor Aduana + IGI + DTAPP + CC + ISAN + IEPS) x (TASAIVA/100)]
	
	-- calculo de iva
		if @PI_FRAN_INT<>'I' 
		begin
			if @dummy='OM'  OR @dummy='SM' or @dummy='CF' or @dummy='CFV' or @dummy='CFM'  
			begin
				if (select cp_usanaftadta from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo))<>'S'
				begin
			
					if @cf_ivaproporcional = 'S'
					begin
						if @valoraduanatotal >0
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
							 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVAFRANJA=0 then 0 else @IVAtasa end,  
							--'importe'=Case when AR_IVAFRANJA=0 then 0 else round((dbo.trunc(@ValorDTA*(round((dbo.PEDIMPDETB.PIB_VAL_ADU)/@valoraduanatotal,6)),4)+(dbo.PEDIMPDETB.PIB_VAL_ADU)+isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0)) *@IVA,0) end,
							  'importe'=Case when AR_IVAFRANJA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														round(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  
													else
														round((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
						AND           (dbo.PEDIMPDETB.PIB_DESTNAFTA <> 'S')
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, dbo.ARANCEL.AR_IVA, dbo.ARANCEL.AR_IVAFRANJA	

					end
					else
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
							 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVAFRANJA=0 then 0 else @IVAtasa end, 
							--'importe'=Case when AR_IVAFRANJA=0 then 0 else round(((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0)+dbo.trunc(@ValorDTA/@totalpartidasdta,4))*@IVA),0) end,
							  'importe'=Case when AR_IVAFRANJA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														ceiling(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA)  
													else
														ceiling((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
						AND           (dbo.PEDIMPDETB.PIB_DESTNAFTA <> 'S')
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, dbo.ARANCEL.AR_IVA, dbo.ARANCEL.AR_IVAFRANJA	
		
					insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
					SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
						 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
						(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVAFRANJA=0 then 0 else @IVAtasa end, 
						--'importe'=Case when AR_IVAFRANJA=0 then 0 else round((round(dbo.PEDIMPDETB.PIB_VAL_ADU,0) + dbo.trunc(isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0),0))*@IVA,0) end, 
						  'importe'=Case when AR_IVAFRANJA=0 then 0 else round((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  end,
					                      dbo.PEDIMPDETB.PIB_INDICEB
					FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
					                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
					                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
					WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
					AND           (dbo.PEDIMPDETB.PIB_DESTNAFTA = 'S')
					GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, dbo.ARANCEL.AR_IVA, dbo.ARANCEL.AR_IVAFRANJA	
				end
				else
				begin


					if @cf_ivaproporcional = 'S'
					begin
	
						if @valoraduanatotal > 0
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
							 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVAFRANJA=0 then 0 else @IVAtasa end, 
							--'importe'=Case when AR_IVAFRANJA=0 then 0 else round((dbo.trunc(@ValorDTA*(round((dbo.PEDIMPDETB.PIB_VAL_ADU)/@valoraduanatotal,6)),4)+(dbo.PEDIMPDETB.PIB_VAL_ADU)+isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0) end,	
							  'importe'=Case when AR_IVAFRANJA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														round(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  
													else
														round((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, dbo.ARANCEL.AR_IVA, dbo.ARANCEL.AR_IVAFRANJA	
					end
					else
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
							 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVAFRANJA=0 then 0 else @IVAtasa end, 				
							--'importe'=Case when AR_IVAFRANJA=0 then 0 else round(((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0)+dbo.trunc(@ValorDTA/@totalpartidasdta,4))*@IVA),0) end,
							  'importe'=Case when AR_IVAFRANJA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														ceiling(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA)  
													else
														ceiling((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, dbo.ARANCEL.AR_IVA, dbo.ARANCEL.AR_IVAFRANJA		
				end	

				/* se incluye tambien el iva calculado en el C1, con tipo de pago 13= ya efectuado */

			end
			else
			begin

			-- sin dta
	
				insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
				SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
					(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), (select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVAFRANJA=0 then 0 else @IVAtasa end, 
					      --'importe'=Case when AR_IVAFRANJA=0 then 0 else round(round(dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0), 0)/@IVAtasa,0) end, 
							'importe'=Case when AR_IVAFRANJA=0 then 0 else round((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVAtasa,0)  end,
				                      dbo.PEDIMPDETB.PIB_INDICEB
				FROM         dbo.PEDIMPDETB LEFT OUTER JOIN			
		                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN				                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO			
      				WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
				GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, dbo.ARANCEL.AR_IVA, dbo.ARANCEL.AR_IVAFRANJA	
			end
	
		end
		else --  interior del pais
		begin
			if @dummy='OM'  OR @dummy='SM' or @dummy='CF' or @dummy='CFV' or @dummy='CFM'  
			begin
				if (select cp_usanaftadta from claveped where cp_codigo in (select cp_codigo from pedimp where pi_codigo=@picodigo))<>'S'
				begin
					if @cf_ivaproporcional = 'S'
					begin
						if @valoraduanatotal >0
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
							 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVA=0 then 0 else @IVAtasa end,  
							--'importe'=Case when AR_IVA=0 then 0 else round((dbo.trunc(@ValorDTA*(round((dbo.PEDIMPDETB.PIB_VAL_ADU)/@valoraduanatotal,6)),4)+(dbo.PEDIMPDETB.PIB_VAL_ADU)+isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0) end,
							  'importe'=Case when AR_IVA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														round(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  
													else
														round((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
						AND           (dbo.PEDIMPDETB.PIB_DESTNAFTA <> 'S')
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, dbo.ARANCEL.AR_IVA, dbo.ARANCEL.AR_IVAFRANJA
					end
					else
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
							 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVA=0 then 0 else @IVAtasa end, 
							--'importe'=Case when AR_IVA=0 then 0 else round(((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0)+dbo.trunc(@ValorDTA/@totalpartidasdta,4))*@IVA),0) end,
							  'importe'=Case when AR_IVA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														ceiling(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA)  
													else
														ceiling((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 						AND           (dbo.PEDIMPDETB.PIB_DESTNAFTA <> 'S')
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, AR_IVA	
		
					insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
					SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
						 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
						(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVA=0 then 0 else @IVAtasa end, 
						--'importe'=Case when AR_IVA=0 then 0 else round((round(dbo.PEDIMPDETB.PIB_VAL_ADU,0) + dbo.trunc(isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0),0))*@IVA,0) end, 
						  'importe'=Case when AR_IVA=0 then 0 else round((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  end,
					                      dbo.PEDIMPDETB.PIB_INDICEB
					FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
					                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
					                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
					WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
					AND           (dbo.PEDIMPDETB.PIB_DESTNAFTA = 'S')
					GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, AR_IVA	
				end
				else
				begin
					if @cf_ivaproporcional = 'S'
					begin
	
						if @valoraduanatotal > 0
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
							 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVA=0 then 0 else @IVAtasa end, 
							--'importe'=Case when AR_IVA=0 then 0 else round((dbo.trunc(@ValorDTA*(round((dbo.PEDIMPDETB.PIB_VAL_ADU)/@valoraduanatotal,6)),4)+(dbo.PEDIMPDETB.PIB_VAL_ADU)+isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0) end,	
							  'importe'=Case when AR_IVA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														round(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  
													else
														round((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA,0)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, AR_IVA	
					end
					else
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
							 (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVA=0 then 0 else @IVAtasa end, 				
							--'importe'=Case when AR_IVA=0 then 0 else round(((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0)+dbo.trunc(@ValorDTA/@totalpartidasdta,4))*@IVA),0) end,
							  'importe'=Case when AR_IVA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														ceiling(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA)  
													else
														ceiling((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVA)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, AR_IVA	
				end	

				IF @ccp_tipo='RP' -- reexpedicion, duplica el IVA porque el 10% ya fue pagado en el C1
				begin


					if @cf_ivaproporcional = 'S'
					begin
						if @valoraduanatotal >0
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='13'),	(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 10,  
						--	'importe'=Case when AR_IVA=0 then 0 else round((dbo.trunc(@ValorDTA*(round((dbo.PEDIMPDETB.PIB_VAL_ADU)/@valoraduanatotal,6)),4)+(dbo.PEDIMPDETB.PIB_VAL_ADU)+isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*.10,0) end,
							  'importe'=Case when AR_IVA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														round(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*.10,0)  
													else
														round((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*.10,0)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
						AND           (dbo.PEDIMPDETB.PIB_DESTNAFTA <> 'S')
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, dbo.ARANCEL.AR_IVA, dbo.ARANCEL.AR_IVAFRANJA
					end
					else
						insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
						SELECT    @picodigo, 'pg_codigo'=(SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='13'), (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
							(select con_codigo from contribucion where con_clave='3'), 10, 
							--'importe'=Case when AR_IVA=0 then 0 else round(((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0)+dbo.trunc(@ValorDTA/@totalpartidasdta,4))*.10),0) end,
							  'importe'=Case when AR_IVA=0 
											then 0 
											else
												case when  @totalpartidasdta = @totalpartidasAgrupacion or @cp_clave = 'F4'
													then
														ceiling(((dbo.PEDIMPDETB.PIB_VAL_ADU * @ValorDTA/@valoraduanatotal)+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*.10)  
													else
														ceiling((((@ValorDTA/@totalpartidasdta))+dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*.10)  
												end
										end,
						                      dbo.PEDIMPDETB.PIB_INDICEB
						FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
						                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
						                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
						WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 						AND           (dbo.PEDIMPDETB.PIB_DESTNAFTA <> 'S')
						GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, AR_IVA	
		

					insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
					SELECT    @picodigo, (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='13'), (SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), 
						(select con_codigo from contribucion where con_clave='3'), 10, 
						--'importe'=Case when AR_IVA=0 then 0 else round((round(dbo.PEDIMPDETB.PIB_VAL_ADU,0) + dbo.trunc(isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0),0))*.10,0) end, 
						  'importe'=Case when AR_IVA=0 then 0 else round((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*.10,0)  end,
					                      dbo.PEDIMPDETB.PIB_INDICEB
					FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
					                      dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN
					                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO
					WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
					AND           (dbo.PEDIMPDETB.PIB_DESTNAFTA = 'S')
					GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, AR_IVA	

				end	

	
			end
			else
			begin
			-- sin dta
	
				insert into pedimpdetbcontribucion(PI_CODIGO, PG_CODIGO, TTA_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, PIB_CONTRIBTOTMN, PIB_INDICEB)	
				SELECT    @picodigo, 'pg_codigo'=case when @pg_codigo2 =0 then (case when @ccp_tipo='ED' then (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='6') else (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0') end) else @pg_codigo2 end,
					(SELECT TTA_CODIGO FROM TTASA WHERE TTA_CLA_PED = '1'), (select con_codigo from contribucion where con_clave='3'), 'Tasa'=case when AR_IVA=0 then 0 else @IVAtasa end, 
					      --'importe'=Case when AR_IVA=0 then 0 else round(round(dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0), 0)/@IVAtasa,0) end, 
  							'importe'=Case when AR_IVA=0 then 0 else round((dbo.PEDIMPDETB.PIB_VAL_ADU + isnull(sum(dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN),0))*@IVAtasa,0)  end,
				                      dbo.PEDIMPDETB.PIB_INDICEB
				FROM         dbo.PEDIMPDETB LEFT OUTER JOIN
				dbo.PEDIMPDETBCONTRIBUCION ON dbo.PEDIMPDETB.PIB_INDICEB = dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB LEFT OUTER JOIN		
			                      dbo.PEDIMP ON dbo.PEDIMPDETB.PI_CODIGO = dbo.PEDIMP.PI_CODIGO LEFT OUTER JOIN dbo.ARANCEL ON dbo.PEDIMPDETB.AR_IMPMX = dbo.ARANCEL.AR_CODIGO			
				WHERE     (dbo.PEDIMPDETB.PIB_INDICEB IS NOT NULL) AND (dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO in(select con_codigo from contribucion where con_clave in ('6','2','4','5'))) and (dbo.PEDIMPDETB.PI_CODIGO = @picodigo) 
				GROUP BY dbo.PEDIMPDETB.PIB_INDICEB, dbo.PEDIMPDETB.PIB_VAL_ADU, AR_IVA

			end
		end
	end
GO
