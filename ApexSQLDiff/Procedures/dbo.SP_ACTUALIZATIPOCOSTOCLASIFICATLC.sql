SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ACTUALIZATIPOCOSTOCLASIFICATLC] (@NFT_CODIGO int)    as

SET NOCOUNT ON 
DECLARE @spi_codigo int, @spi_codigo2 int
declare @fecha as datetime
declare @nft_tracevalue as char(1)

set @fecha = (select BST_entravigor from CLASIFICATLC where nft_codigo = @NFT_CODIGO group by BST_entravigor) 


	SET @nft_tracevalue= isnull((select nft_tracevalue FROM NAFTA WHERE NFT_CODIGO = @NFT_CODIGO), 'N')


	SELECT @spi_codigo= SPI_CODIGO FROM NAFTA WHERE NFT_CODIGO = @NFT_CODIGO

	IF (SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX' )= @spi_codigo
	SELECT @spi_codigo2= SPI_CODIGO FROM SPI WHERE SPI_CLAVE='NAFTA'
	ELSE
	SET @spi_codigo2=@spi_codigo



	exec sp_droptable 'TempBomGravableTlc'

	exec sp_droptable 'TempPaisTLC'

	select pa_codigo 
	into dbo.TempPaisTLC
	from pais where (spi_codigo=@spi_codigo OR spi_codigo=@spi_codigo2) and pa_codigo<>233


	if @nft_tracevalue = 'S'
	/*
	if exists (select * from MAESTROTRACEVALUE where ma_codigo = isnull((select BST_PT from CLASIFICATLC where nft_codigo = @NFT_CODIGO group by bst_pt),-1)
	and  @fecha between matrv_perini and matrv_perfin
	and matrv_usetracevalue='S'
	)
	*/
	begin
		--revisa que no existan originarios, ya que esto significa que todo es NO ORIGINARIO y por lo tanto debe ejecutarse el proceso como se hacia anteriormente
		if not exists (select *
				from CLASIFICATLC
				where CLASIFICATLC.clt_codigo not in (
									--Yolanda Avila
									--2011-11-29
									/*
									select c.clt_codigo
									from CLASIFICATLC c
									where c.nft_codigo = @NFT_CODIGO 
									and c.ar_codigo in (select ar_codigo from TRACEVALUE where @fecha between trv_perini and trv_perfin)
									*/
									select c.clt_codigo
									from CLASIFICATLC c
									left outer join arancel on c.ar_codigo = arancel.ar_codigo
									where c.nft_codigo = @NFT_CODIGO 
									and arancel.ar_fraccion in (
													select a.ar_fraccion
													from arancel a
													where 
													case when exists ( select *
															   from tracevalue
															   where getdate() between trv_perini and trv_perfin
															   and left(a.ar_fraccion, len(ar_fraccion_Inicial)) between ar_fraccion_Inicial and ar_fraccion_final) then 
																	'existe' 
													       else 'noExiste' 
													end = 'existe'
													and a.ar_fraccion = arancel.ar_fraccion
												   )
								 )
				and CLASIFICATLC.nft_codigo = @NFT_CODIGO 
			      )
		begin
			--Este proceso es el que se hacia anteriormente a que se agregara la opcion del metodo de rastreo
			if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' 
			begin
				SELECT  CLASIFICATLC.CLT_CODIGO, 
				esGravable=case when (bst_trans = 'N') and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
							         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
							         WHERE (CERTORIGMP.SPI_CODIGO = @spi_codigo OR CERTORIGMP.SPI_CODIGO = @spi_codigo2)  and CERTORIGMPDET.PA_CLASE=CLASIFICATLC.pa_codigo 
								and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6)=LEFT(REPLACE((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=CLASIFICATLC.AR_CODIGO),'.',''),6)
								 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= CLASIFICATLC.bst_entravigor AND CERTORIGMP.CMP_VFECHA >= CLASIFICATLC.bst_entravigor) then
			  				         (case when CLASIFICATLC.pa_codigo  in (SELECT pa_codigo FROM TempPaisTLC) then
								(case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) else (case when ma_servicio='S' then 'X' else 'S' end) end,
				esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
					esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
					esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end,  'Z' as bst_tipocosto
					into dbo.TempBomGravableTlc
					FROM         CLASIFICATLC INNER JOIN
					                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
					WHERE NFT_CODIGO=@NFT_CODIGO
			end
			else
			begin
				SELECT  CLASIFICATLC.CLT_CODIGO, 
				esGravable=CASE WHEN bst_trans = 'N' and (MAESTRO.ma_def_tip='P' and (MAESTRO.spi_codigo=@spi_codigo OR MAESTRO.spi_codigo=@spi_codigo2)) then
				(case when CLASIFICATLC.pa_codigo in (SELECT pa_codigo FROM TempPaisTLC) then
				  (case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) 
				else
				(case when MAESTRO.ma_servicio='S' then 'X' else 'S' end)
				end, esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
				esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
				esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end, 'Z' as bst_tipocosto
				into dbo.TempBomGravableTlc
				FROM         CLASIFICATLC INNER JOIN
				                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
				WHERE NFT_CODIGO=@NFT_CODIGO	
		
			end	
	
	
	
		end
		else 
		begin	
			--Aplica el metodo de rastreo
			if not exists (
					--Los NO ORIGINARIOS
					select *
					from CLASIFICATLC
					where CLASIFICATLC.clt_codigo in (
										--Yolanda Avila
										--2011-11-29
										/*
										select c.clt_codigo
										from CLASIFICATLC c
										where c.nft_codigo = @NFT_CODIGO 
										and c.ar_codigo in (select ar_codigo from TRACEVALUE where @fecha between trv_perini and trv_perfin)
										*/
										select c.clt_codigo
										from CLASIFICATLC c
										left outer join arancel on c.ar_codigo = arancel.ar_codigo
										where c.nft_codigo = @NFT_CODIGO 
										and arancel.ar_fraccion in (
														select a.ar_fraccion
														from arancel a
														where 
														case when exists ( select *
																   from tracevalue
																   where getdate() between trv_perini and trv_perfin
																   and left(a.ar_fraccion, len(ar_fraccion_Inicial)) between ar_fraccion_Inicial and ar_fraccion_final) then 
																		'existe' 
														       else 'noExiste' 
														end = 'existe'
														and a.ar_fraccion = arancel.ar_fraccion
													   )
	

									 )
					)		
	
			begin
				--Entonces todo es ORIGINARIO
				--Falta desarrollar esta parte (ya)
					SELECT  CLASIFICATLC.CLT_CODIGO, 
					esGravable=/*case when (bst_trans = 'N') and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
								         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
								         WHERE (CERTORIGMP.SPI_CODIGO = @spi_codigo OR CERTORIGMP.SPI_CODIGO = @spi_codigo2)  and CERTORIGMPDET.PA_CLASE=CLASIFICATLC.pa_codigo 
									and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6)=LEFT(REPLACE((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=CLASIFICATLC.AR_CODIGO),'.',''),6)
									 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= CLASIFICATLC.bst_entravigor AND CERTORIGMP.CMP_VFECHA >= CLASIFICATLC.bst_entravigor) then
				  				         (case when CLASIFICATLC.pa_codigo  in (SELECT pa_codigo FROM TempPaisTLC) then
									(case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) else (case when ma_servicio='S' then 'X' else 'S' end) end,
						     */
							( case when maestro.ma_consta='S' then 'Z' 
							       else case when ma_servicio='S' then 'X'
							          	 else 'N' 
							     	    end
							  end),
					esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
						esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
						esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end,  'Z' as bst_tipocosto
						into dbo.TempBomGravableTlc
						FROM CLASIFICATLC 
						INNER JOIN MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
						WHERE NFT_CODIGO=@NFT_CODIGO
						and CLASIFICATLC.clt_codigo not in (
											--Yolanda Avila
											--2011-11-29
											/*
											select c.clt_codigo
											from CLASIFICATLC c
											where c.nft_codigo = @NFT_CODIGO 
											and c.ar_codigo in (select ar_codigo from TRACEVALUE where @fecha between trv_perini and trv_perfin)
											*/
											select c.clt_codigo
											from CLASIFICATLC c
											left outer join arancel on c.ar_codigo = arancel.ar_codigo
											where c.nft_codigo = @NFT_CODIGO 
											and arancel.ar_fraccion in (
															select a.ar_fraccion
															from arancel a
															where 
															case when exists ( select *
																	   from tracevalue
																	   where getdate() between trv_perini and trv_perfin
																	   and left(a.ar_fraccion, len(ar_fraccion_Inicial)) between ar_fraccion_Inicial and ar_fraccion_final) then 
																			'existe' 
															       else 'noExiste' 
															end = 'existe'
															and a.ar_fraccion = arancel.ar_fraccion
														   )
										   )
	
	
	
			end
			else
			begin
				--Falta desarrollar esta parte (ya)
	
				--Los originarios
/*
				select *
				from CLASIFICATLC
				where CLASIFICATLC.clt_codigo not in (
									select c.clt_codigo
									from CLASIFICATLC c
									where c.nft_codigo = @NFT_CODIGO 
									and c.ar_codigo in (select ar_codigo from TRACEVALUE where @fecha between trv_perini and trv_perfin)
								 )
				and CLASIFICATLC.nft_codigo = @NFT_CODIGO 
*/
	
	
				--Se comento esta parte ya que NO es necesario diferenciar si tiene Certificado de origen o el Tipo de Tasa es BAJO TRATADO,
				--ya que todo por no estar utilizando la fraccion es ORIGINARIO
				/*
				if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' 
				begin
					SELECT  CLASIFICATLC.CLT_CODIGO, 
					esGravable=case when (bst_trans = 'N') and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
								         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
								         WHERE (CERTORIGMP.SPI_CODIGO = @spi_codigo OR CERTORIGMP.SPI_CODIGO = @spi_codigo2)  and CERTORIGMPDET.PA_CLASE=CLASIFICATLC.pa_codigo 
									and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6)=LEFT(REPLACE((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=CLASIFICATLC.AR_CODIGO),'.',''),6)
									 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= CLASIFICATLC.bst_entravigor AND CERTORIGMP.CMP_VFECHA >= CLASIFICATLC.bst_entravigor) then
				  				         (case when CLASIFICATLC.pa_codigo  in (SELECT pa_codigo FROM TempPaisTLC) then
									(case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) else (case when ma_servicio='S' then 'X' else 'S' end) end,
						     
					esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
						esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
						esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end,  'Z' as bst_tipocosto
						into dbo.TempBomGravableTlc
						FROM CLASIFICATLC 
						INNER JOIN MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
						WHERE NFT_CODIGO=@NFT_CODIGO
						and CLASIFICATLC.clt_codigo not in (
											select c.clt_codigo
											from CLASIFICATLC c
											where c.nft_codigo = @NFT_CODIGO 
											and c.ar_codigo in (select ar_codigo from TRACEVALUE where (select BST_entravigor from CLASIFICATLC where nft_codigo = @NFT_CODIGO group by BST_entravigor) between trv_perini and trv_perfin)
										   )
				end
				else
				begin
					SELECT  CLASIFICATLC.CLT_CODIGO, 
					esGravable=CASE WHEN bst_trans = 'N' and (MAESTRO.ma_def_tip='P' and (MAESTRO.spi_codigo=@spi_codigo OR MAESTRO.spi_codigo=@spi_codigo2)) then
							(case when CLASIFICATLC.pa_codigo in (SELECT pa_codigo FROM TempPaisTLC) then
							  (case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) 
							else
							(case when MAESTRO.ma_servicio='S' then 'X' else 'S' end)
							end, 
						    
					esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
					esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
					esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end, 'Z' as bst_tipocosto
					into dbo.TempBomGravableTlc
					FROM CLASIFICATLC 
					INNER JOIN MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
					WHERE NFT_CODIGO=@NFT_CODIGO	
					and CLASIFICATLC.clt_codigo not in (
										select c.clt_codigo
										from CLASIFICATLC c
										where c.nft_codigo = @NFT_CODIGO 
										and c.ar_codigo in (select ar_codigo from TRACEVALUE where (select BST_entravigor from CLASIFICATLC where nft_codigo = @NFT_CODIGO group by BST_entravigor) between trv_perini and trv_perfin)
									   )		
				end	
				*/
	
	
	
				--Parte de lo ORIGINARIO
					SELECT  CLASIFICATLC.CLT_CODIGO, 
					esGravable=/*case when (bst_trans = 'N') and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
								         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
								         WHERE (CERTORIGMP.SPI_CODIGO = @spi_codigo OR CERTORIGMP.SPI_CODIGO = @spi_codigo2)  and CERTORIGMPDET.PA_CLASE=CLASIFICATLC.pa_codigo 
									and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6)=LEFT(REPLACE((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=CLASIFICATLC.AR_CODIGO),'.',''),6)
									 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= CLASIFICATLC.bst_entravigor AND CERTORIGMP.CMP_VFECHA >= CLASIFICATLC.bst_entravigor) then
				  				         (case when CLASIFICATLC.pa_codigo  in (SELECT pa_codigo FROM TempPaisTLC) then
									(case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) else (case when ma_servicio='S' then 'X' else 'S' end) end,
						     */
							( case when maestro.ma_consta='S' then 'Z' 
							       else case when ma_servicio='S' then 'X'
							          	 else 'N' 
							     	    end
							  end),
					esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
						esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
						esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end,  'Z' as bst_tipocosto
						into dbo.TempBomGravableTlc
						FROM CLASIFICATLC 
						INNER JOIN MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
						WHERE NFT_CODIGO=@NFT_CODIGO
						and CLASIFICATLC.clt_codigo not in (
											--Yolanda Avila
											--2011-11-29
											/*
											select c.clt_codigo
											from CLASIFICATLC c
											where c.nft_codigo = @NFT_CODIGO 
											and c.ar_codigo in (select ar_codigo from TRACEVALUE where @fecha between trv_perini and trv_perfin)
											*/
											select c.clt_codigo
											from CLASIFICATLC c
											left outer join arancel on c.ar_codigo = arancel.ar_codigo
											where c.nft_codigo = @NFT_CODIGO 
											and arancel.ar_fraccion in (
															select a.ar_fraccion
															from arancel a
															where 
															case when exists ( select *
																	   from tracevalue
																	   where getdate() between trv_perini and trv_perfin
																	   and left(a.ar_fraccion, len(ar_fraccion_Inicial)) between ar_fraccion_Inicial and ar_fraccion_final) then 
																			'existe' 
															       else 'noExiste' 
															end = 'existe'
															and a.ar_fraccion = arancel.ar_fraccion
														   )


										   )
	
	
	
				--Los NO ORIGINARIOS
/*
				select *
				from CLASIFICATLC
				where CLASIFICATLC.clt_codigo in (
									select c.clt_codigo
									from CLASIFICATLC c
									where c.nft_codigo = @NFT_CODIGO 
									and c.ar_codigo in (select ar_codigo from TRACEVALUE where @fecha between trv_perini and trv_perfin)

								 )
	
*/
			
				if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' 
				begin

					insert into dbo.TempBomGravableTlc (CLT_CODIGO,esGravable,esAnadido,esMP,esSUB,bst_tipocosto)
					SELECT  CLASIFICATLC.CLT_CODIGO, 
					esGravable=case when (bst_trans = 'N') and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
								         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
								         WHERE (CERTORIGMP.SPI_CODIGO = @spi_codigo OR CERTORIGMP.SPI_CODIGO = @spi_codigo2)  and CERTORIGMPDET.PA_CLASE=CLASIFICATLC.pa_codigo 
									and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6)=LEFT(REPLACE((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=CLASIFICATLC.AR_CODIGO),'.',''),6)
									 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= CLASIFICATLC.bst_entravigor AND CERTORIGMP.CMP_VFECHA >= CLASIFICATLC.bst_entravigor) then
				  				         (case when CLASIFICATLC.pa_codigo  in (SELECT pa_codigo FROM TempPaisTLC) then
									(case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) else (case when ma_servicio='S' then 'X' else 'S' end) end,
					esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
						esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
						esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end,  'Z' as bst_tipocosto
						--into dbo.TempBomGravableTlc
						FROM CLASIFICATLC 
						INNER JOIN MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
						WHERE NFT_CODIGO=@NFT_CODIGO
						and CLASIFICATLC.clt_codigo in (
										 --Yolanda Avila
										--2011-11-29
										  /*
										  select c.clt_codigo
										  from CLASIFICATLC c
										  where c.nft_codigo = @NFT_CODIGO 
										  and c.ar_codigo in (select ar_codigo from TRACEVALUE where @fecha between trv_perini and trv_perfin)
										  */
											select c.clt_codigo
											from CLASIFICATLC c
											left outer join arancel on c.ar_codigo = arancel.ar_codigo
											where c.nft_codigo = @NFT_CODIGO 
											and arancel.ar_fraccion in (
															select a.ar_fraccion
															from arancel a
															where 
															case when exists ( select *
																	   from tracevalue
																	   where getdate() between trv_perini and trv_perfin
																	   and left(a.ar_fraccion, len(ar_fraccion_Inicial)) between ar_fraccion_Inicial and ar_fraccion_final) then 
																			'existe' 
															       else 'noExiste' 
															end = 'existe'
															and a.ar_fraccion = arancel.ar_fraccion
														   )

										)
				end
				else
				begin
					insert into dbo.TempBomGravableTlc (CLT_CODIGO,esGravable,esAnadido,esMP,esSUB,bst_tipocosto)
					SELECT  CLASIFICATLC.CLT_CODIGO, 
					esGravable=CASE WHEN bst_trans = 'N' and (MAESTRO.ma_def_tip='P' and (MAESTRO.spi_codigo=@spi_codigo OR MAESTRO.spi_codigo=@spi_codigo2)) then
							(case when CLASIFICATLC.pa_codigo in (SELECT pa_codigo FROM TempPaisTLC) then
							  (case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) 
							else
							(case when MAESTRO.ma_servicio='S' then 'X' else 'S' end)
							end, 
					esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
					esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
					esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end, 'Z' as bst_tipocosto
					--into dbo.TempBomGravableTlc
					FROM CLASIFICATLC 
					INNER JOIN MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
					WHERE NFT_CODIGO=@NFT_CODIGO	
					and CLASIFICATLC.clt_codigo in (
									--Yolanda Avila
									--2011-11-29
									  /*
									  select c.clt_codigo
									  from CLASIFICATLC c
									  where c.nft_codigo = @NFT_CODIGO 
									  and c.ar_codigo in (select ar_codigo from TRACEVALUE where @fecha between trv_perini and trv_perfin)
									  */
											select c.clt_codigo
											from CLASIFICATLC c
											left outer join arancel on c.ar_codigo = arancel.ar_codigo
											where c.nft_codigo = @NFT_CODIGO 
											and arancel.ar_fraccion in (
															select a.ar_fraccion
															from arancel a
															where 
															case when exists ( select *
																	   from tracevalue
																	   where getdate() between trv_perini and trv_perfin
																	   and left(a.ar_fraccion, len(ar_fraccion_Inicial)) between ar_fraccion_Inicial and ar_fraccion_final) then 
																			'existe' 
															       else 'noExiste' 
															end = 'existe'
															and a.ar_fraccion = arancel.ar_fraccion
														   )

									)
	
			
				end	
			
	
	
	
	
			end
		
		end
	
	end
	else 
	begin
		--Se ejecuta el proceso como se hacia anteriormente ya que no aplica el metodo de rastreo
			if (SELECT CF_CONFERIRORIGEN FROM CONFIGURACION)='C' 
			begin
				SELECT  CLASIFICATLC.CLT_CODIGO, 
				esGravable=case when (bst_trans = 'N') and bst_hijo in (SELECT CERTORIGMPDET.MA_CODIGO
							         FROM  CERTORIGMPDET INNER JOIN CERTORIGMP ON CERTORIGMPDET.CMP_CODIGO = CERTORIGMP.CMP_CODIGO 
							         WHERE (CERTORIGMP.SPI_CODIGO = @spi_codigo OR CERTORIGMP.SPI_CODIGO = @spi_codigo2)  and CERTORIGMPDET.PA_CLASE=CLASIFICATLC.pa_codigo 
								and LEFT(REPLACE(CERTORIGMPDET.CMP_FRACCION,'.',''),6)=LEFT(REPLACE((SELECT AR_FRACCION FROM ARANCEL WHERE AR_CODIGO=CLASIFICATLC.AR_CODIGO),'.',''),6)
								 AND CERTORIGMP.CMP_ESTATUS='V' AND CERTORIGMP.CMP_IFECHA <= CLASIFICATLC.bst_entravigor AND CERTORIGMP.CMP_VFECHA >= CLASIFICATLC.bst_entravigor) then
			  				         (case when CLASIFICATLC.pa_codigo  in (SELECT pa_codigo FROM TempPaisTLC) then
								(case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) else (case when ma_servicio='S' then 'X' else 'S' end) end,
				esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
					esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
					esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end,  'Z' as bst_tipocosto
					into dbo.TempBomGravableTlc
					FROM         CLASIFICATLC INNER JOIN
					                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
					WHERE NFT_CODIGO=@NFT_CODIGO
			end
			else
			begin
				SELECT  CLASIFICATLC.CLT_CODIGO, 
				esGravable=CASE WHEN bst_trans = 'N' and (MAESTRO.ma_def_tip='P' and (MAESTRO.spi_codigo=@spi_codigo OR MAESTRO.spi_codigo=@spi_codigo2)) then
				(case when CLASIFICATLC.pa_codigo in (SELECT pa_codigo FROM TempPaisTLC) then
				  (case when maestro.ma_consta='S' then 'Z' else 'X' end) else 'N' end) 
				else
				(case when MAESTRO.ma_servicio='S' then 'X' else 'S' end)
				end, esAnadido=case when MAESTRO.MA_REPARA <>'A' then 'N' else 'S' end,
				esMP=case when CLASIFICATLC.TI_CODIGO in ('R', 'L', 'M', 'O') or (CLASIFICATLC.TI_CODIGO ='S' and (CLASIFICATLC.MA_TIP_ENS='C' or CLASIFICATLC.MA_TIP_ENS='A')) then 'S' else 'N' end,
				esSUB=case when CLASIFICATLC.TI_CODIGO ='S' and CLASIFICATLC.MA_TIP_ENS<>'C' then 'S' else 'N' end, 'Z' as bst_tipocosto
				into dbo.TempBomGravableTlc
				FROM         CLASIFICATLC INNER JOIN
				                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO 
				WHERE NFT_CODIGO=@NFT_CODIGO	
		
			end	
	
	end
	


	
	/* Se asigna el tipo de costo */   


	update TempBomGravableTlc
	set bst_tipocosto='A'
	where esMP = 'S' and esGravable = 'S' and esAnadido = 'N' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='B'
	where esMP = 'S' and esGravable = 'S' and esAnadido = 'S' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='C'
	where esMP = 'S' and esGravable = 'N' and esAnadido = 'N' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='D'
	where esMP = 'S' and esGravable = 'N' and esAnadido = 'S' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='N'
	where esMP = 'S' and esGravable = 'X' and esAnadido = 'N' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='P'
	where esMP = 'S' and esGravable = 'X' and esAnadido = 'S' 

	update TempBomGravableTlc
	set bst_tipocosto='Z'
	where esMP = 'S' and esGravable = 'Z' and esAnadido = 'N' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='G'
	where esMP = 'S' and esGravable = 'Z' and esAnadido = 'S' 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='S'
	where esSUB = 'S'  
	
	
	update TempBomGravableTlc
	set bst_tipocosto='E'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable = 'S' or  esGravable = 'X') 
	

	update TempBomGravableTlc
	set bst_tipocosto='H'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable = 'Z') 
	
	
	update TempBomGravableTlc
	set bst_tipocosto='F'
	where esMP = 'N' and esSUB = 'N' and
	(esGravable <> 'S' and  esGravable <> 'X') 



	update CLASIFICATLC
	set bst_tipocosto=TempBomGravableTlc.bst_tipocosto
	from TempBomGravableTlc inner join CLASIFICATLC on TempBomGravableTlc.clt_codigo=CLASIFICATLC.clt_codigo
	where CLASIFICATLC.bst_tipocosto is null or CLASIFICATLC.bst_tipocosto<>TempBomGravableTlc.bst_tipocosto

	/*
	select *
	into TempBomGravableTlc_yolanda
	from TempBomGravableTlc
						
	select *
	into CLASIFICATLC_yolanda
	FROM CLASIFICATLC 
	*/
	exec sp_droptable 'TempBomGravableTlc'


	exec sp_droptable 'TempPaisTLC'

GO
