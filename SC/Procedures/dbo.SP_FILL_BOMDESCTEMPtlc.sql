SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* inserta en la tabla CLASIFICATLC  los del nivel 1 el bom  para calculo de costos y calculo de aranceles*/
CREATE PROCEDURE [dbo].[SP_FILL_BOMDESCTEMPtlc] (@BST_PT Int, @NFT_CODIGO INT, @PorRango char(1)='N')   as

--SET NOCOUNT ON 
declare @BST_HIJO int, @BST_INCORPOR decimal(38,6), @BST_DISCH char(1), @TI_CODIGO char(1), @ME_CODIGO int, @Factconv decimal(28,14), 
    @BST_PERINI datetime, @BST_PERFIN datetime, @ME_GEN int, @BST_TRANS char(1), @BST_TIPOCOSTO char(1), 
    @MA_TIP_ENS char(1), @BST_ENTRAVIGOR DateTime,  @CF_USATIPOADQUISICION char(1), @CF_NIVELES  int,
 @bst_perini2 datetime, @PA_CODIGO int, @cf_pais_mx int, @ar_codigo int, @cf_pais_ca int, @spi_codigo int, @IML_CBFORMA int


	UPDATE NAFTA
	SET     NFT_FECHA=convert(varchar(11),getdate(),101)
	WHERE NFT_CODIGO=@NFT_CODIGO and NFT_FECHA is null


	select @BST_ENTRAVIGOR = NFT_FECHA from nafta where nft_codigo=@NFT_CODIGO

	print 'SP_FILL_BOMDESCTEMPtlc'

	if @PorRango='S'
	set @IML_CBFORMA=-88
	else
	begin
		set @IML_CBFORMA=88
		DELETE FROM IMPORTLOG WHERE IML_CBFORMA=88 AND IML_REFERENCIA=@BST_PT

		if (select count(*) from IMPORTLOG)=0
		DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS



		update nafta
		set ar_codigo =(select	case when ma_codigo>0 then 
		(case when (select spi_analisishtsmex from spi where spi_codigo=nafta.spi_codigo)='S' then 
			(select isnull(ar_impmx,0) from maestro where ma_codigo=nafta.ma_codigo) 
			else 
			(select isnull(ar_impfo,0) from maestro where ma_codigo=nafta.ma_codigo) 
		end) 
		else 
		(case when (select spi_analisishtsmex from spi where spi_codigo=nafta.spi_codigo)='S' then 
			(select isnull(max(ar_expmx),0) from factexpdet where fed_noparte=nafta.nft_noparte) 
		 	else 
			(select isnull(max(ar_impfo),0) from factexpdet where fed_noparte=nafta.nft_noparte) 
		end) 
		end)
		from nafta 
		where nft_codigo=@NFT_CODIGO and (ar_codigo is null or ar_codigo=0)



		DELETE FROM CLASIFICATLC WHERE NFT_CODIGO = @NFT_CODIGO

	end

	select  @CF_USATIPOADQUISICION = CF_USATIPOADQUISICION, @CF_NIVELES = CF_NIVELES,
	@cf_pais_mx=cf_pais_mx, @cf_pais_ca=cf_pais_ca from configuracion
	
	select @spi_codigo=spi_codigo from nafta where nft_codigo=@NFT_CODIGO
	



		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
		SELECT 'NO. PARTE : ' +MA_NOPARTE+' NO TIENE ASIGNADA ESTRUCTURA (BOM)', @IML_CBFORMA,  @BST_PT
		FROM MAESTRO WHERE MA_CODIGO=@BST_PT AND
		MA_CODIGO NOT IN (SELECT BSU_SUBENSAMBLE FROM BOM_STRUCT WHERE 
		BST_PERINI <=  @BST_ENTRAVIGOR and BST_PERFIN>=  @BST_ENTRAVIGOR)



	if @PorRango<>'S'
	begin
				insert into CLASIFICATLC(BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
				    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
				    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, BST_NIVEL, BST_PERTENECE,
	 			PA_CODIGO, AR_CODIGO, NFT_CODIGO)
	
	
				SELECT     @BST_PT, @BST_ENTRAVIGOR, dbo.BOM_STRUCT.BST_HIJO, sum((BOM_STRUCT.BST_INCORPOR+(CASE WHEN isnull(MAESTRO.MA_POR_DESP,0)<0 and
						isnull(MAESTRO.MA_POR_DESP,0)<>0 then ((BOM_STRUCT.BST_INCORPOR*MAESTRO.MA_POR_DESP)/100) 
						         else 0 end))) AS BST_INCORPOR, 
						'BST_DISCH'=CASE WHEN (dbo.BOM_STRUCT.BST_TIP_ENS='A') OR 
						((ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)='P' or ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)='S') AND dbo.BOM_STRUCT.BST_TRANS='S') THEN 'S' ELSE dbo.BOM_STRUCT.BST_DISCH END, 
				                      ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO), dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
				                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
				                      CASE WHEN dbo.BOM_STRUCT.BST_TIP_ENS='A' THEN 'C' ELSE dbo.BOM_STRUCT.BST_TIP_ENS END, 1, @BST_PT,
						dbo.MAESTRO.PA_ORIGEN, 'AR_CODIGO'=CASE WHEN @spi_codigo in (select spi_codigo from spi where SPI_ANALISISHTSMEX='S') then MAX(dbo.MAESTRO.AR_IMPMX) else MAX(dbo.MAESTRO.AR_IMPFO) end, @NFT_CODIGO
				FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
				                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO  LEFT OUTER JOIN dbo.MAESTROREFER ON 
					         dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
				                      dbo.CONFIGURATIPO CONFIGURATIPOA ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPOA.TI_CODIGO
				WHERE (((ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)<>'P' and ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)<>'S') and (dbo.BOM_STRUCT.BST_TIP_ENS='C' or dbo.BOM_STRUCT.BST_TIP_ENS is null))
				or ((ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)='P' or ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO)='S') and (dbo.BOM_STRUCT.BST_TIP_ENS='C' or dbo.BOM_STRUCT.BST_TIP_ENS='A' or dbo.BOM_STRUCT.BST_TIP_ENS='E' 
					or dbo.BOM_STRUCT.BST_TIP_ENS='O' or dbo.BOM_STRUCT.BST_TRANS='S'))) and
					dbo.MAESTRO.MA_USO_ENANALISIS='S'
				GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO), dbo.BOM_STRUCT.ME_CODIGO, 
				                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
				                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
				                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.MAESTRO.PA_ORIGEN
				HAVING     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
				AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>=  @BST_ENTRAVIGOR)
				AND dbo.BOM_STRUCT.BST_INCORPOR >0 
				ORDER BY dbo.BOM_STRUCT.BST_HIJO
	
	
	
		declare CUR_BOMSTRUCT cursor static for
		
		SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_PERINI
		FROM         dbo.BOM_STRUCT LEFT OUTER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN dbo.MAESTROREFER ON 
			         dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
		                      dbo.CONFIGURATIPO CONFIGURATIPOA ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPOA.TI_CODIGO
		WHERE     (ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) = 'P' OR ISNULL(dbo.CONFIGURATIPO.CFT_TIPO,CONFIGURATIPOA.CFT_TIPO) = 'S') 
			AND (dbo.BOM_STRUCT.BST_TIP_ENS = 'F' OR dbo.BOM_STRUCT.BST_TIP_ENS IS NULL) AND (dbo.BOM_STRUCT.BST_TRANS<>'S' OR dbo.BOM_STRUCT.BST_TRANS IS NULL)
			AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
			AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND dbo.BOM_STRUCT.BST_INCORPOR >0 
			AND (dbo.BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>=  @BST_ENTRAVIGOR)
		GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_PERINI
		ORDER BY dbo.BOM_STRUCT.BST_HIJO
		
		
		 OPEN CUR_BOMSTRUCT
		
			FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR, @BST_PERINI
		
		  WHILE (@@fetch_status = 0) 
		
		  BEGIN  
		
		
				exec  SP_FILL_BOMDESCTEMP1tlc @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR,
				@BST_PERINI, @CF_USATIPOADQUISICION, @BST_INCORPOR, @CF_NIVELES, 1, @NFT_CODIGO, @IML_CBFORMA
		
		
		
			FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR, @BST_PERINI
		
		END
		
			CLOSE CUR_BOMSTRUCT
			DEALLOCATE CUR_BOMSTRUCT

	end


	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##CLASIFICATLC'  AND  type = 'U')
	begin
		drop table ##CLASIFICATLC
	end

	if exists(select * from CLASIFICATLC WHERE NFT_CODIGO=@NFT_CODIGO) 
	begin 
		if @PorRango='N'
		begin		

			SELECT BST_PT, BST_ENTRAVIGOR, BST_HIJO, sum(BST_INCORPOR) BST_INCORPOR, 
			    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, MIN(BST_PERINI) BST_PERINI, MAX(BST_PERFIN) BST_PERFIN, ME_GEN, 
			    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, BST_NIVEL, 
				PA_CODIGO, AR_CODIGO, NFT_CODIGO
			INTO ##CLASIFICATLC
			FROM CLASIFICATLC
			WHERE NFT_CODIGO=@NFT_CODIGO
			GROUP BY BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
			BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, ME_GEN, 
			BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, BST_NIVEL,
			PA_CODIGO, AR_CODIGO, NFT_CODIGO
			
			DELETE FROM CLASIFICATLC WHERE NFT_CODIGO=@NFT_CODIGO
		
		
			INSERT INTO CLASIFICATLC(BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
					    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
					    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, BST_NIVEL, 
		 			PA_CODIGO, AR_CODIGO, NFT_CODIGO)
			SELECT BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
					    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
					    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, BST_NIVEL,
		 			PA_CODIGO, AR_CODIGO, NFT_CODIGO
			FROM ##CLASIFICATLC
		
	
			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##CLASIFICATLC'  AND  type = 'U')
			begin
				drop table ##CLASIFICATLC
			end
	
	
	
			-- Actualiza el costo del producto para guardar historial del calculo
		   	exec SP_ACTUALIZATIPOCOSTOCLASIFICATLC @NFT_CODIGO -- actualiza el tipo de costo en base al nft que se esta corriendo
	
			 exec SP_ACTUALIZATIPOMATORIG @BST_PT, @NFT_CODIGO
	
			-- revisa informacion
			exec SP_REVISAINFOCLASIFICATLC @BST_PT, @NFT_CODIGO
		end



			----------------------- regla 1 -----------------------------------------------------------
		
			EXEC Sp_SaltoArancelario @BST_PT, @NFT_CODIGO, 1
		
		
			exec sp_SaltoExcepto @BST_PT, @NFT_CODIGO, 1

		
			exec SP_ACTUALIZACALCULOCLASIFICATLC @NFT_CODIGO, 1
		
		
			----------------------- regla 2 -----------------------------------------------------------
			if (select nft_califico from nafta where nft_codigo=@NFT_CODIGO)<>'S' and
			exists (SELECT     dbo.REGLAORIGENDET.ARR_PARTIDASALTO
			FROM         dbo.ARANCELREGLAORIGEN INNER JOIN
			                      dbo.REGLAORIGEN INNER JOIN
			                      dbo.NAFTA ON dbo.REGLAORIGEN.SPI_CODIGO = dbo.NAFTA.SPI_CODIGO ON 
			                      dbo.ARANCELREGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGEN.ARR_CODIGO AND 
			                      dbo.ARANCELREGLAORIGEN.AR_CODIGO = dbo.NAFTA.AR_CODIGO INNER JOIN
			                      dbo.ARANCEL ON dbo.NAFTA.AR_CODIGO = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
			                      dbo.REGLAORIGENDET ON dbo.REGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGENDET.ARR_CODIGO
			WHERE     (NAFTA.NFT_CODIGO = @nft_codigo) AND (REGLAORIGENDET.ARR_REGLA = '2')
			--Yolanda Avila
			--2010-09-20
			and (dbo.ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
			     and dbo.ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))
			)
	
			begin
			
				EXEC Sp_SaltoArancelario @BST_PT, @NFT_CODIGO, 2
			
				 exec sp_SaltoExcepto @BST_PT, @NFT_CODIGO, 2
			
				exec SP_ACTUALIZACALCULOCLASIFICATLC @NFT_CODIGO, 2
		
			end
		
			----------------------- regla 3 -----------------------------------------------------------
			if (select nft_califico from nafta where nft_codigo=@NFT_CODIGO)<>'S' and
			exists (SELECT     dbo.REGLAORIGENDET.ARR_PARTIDASALTO
			FROM         dbo.ARANCELREGLAORIGEN INNER JOIN
			                      dbo.REGLAORIGEN INNER JOIN
			                      dbo.NAFTA ON dbo.REGLAORIGEN.SPI_CODIGO = dbo.NAFTA.SPI_CODIGO ON 
			                      dbo.ARANCELREGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGEN.ARR_CODIGO AND 
			                      dbo.ARANCELREGLAORIGEN.AR_CODIGO = dbo.NAFTA.AR_CODIGO INNER JOIN
			                      dbo.ARANCEL ON dbo.NAFTA.AR_CODIGO = dbo.ARANCEL.AR_CODIGO LEFT OUTER JOIN
			                      dbo.REGLAORIGENDET ON dbo.REGLAORIGEN.ARR_CODIGO = dbo.REGLAORIGENDET.ARR_CODIGO
			WHERE     (NAFTA.NFT_CODIGO = @nft_codigo) AND (REGLAORIGENDET.ARR_REGLA = '3')
			--Yolanda Avila
			--2010-09-20
			and (dbo.ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
			     and dbo.ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))

			)
	
			begin
			
				EXEC Sp_SaltoArancelario @BST_PT, @NFT_CODIGO, 3
			
			
				 exec sp_SaltoExcepto @BST_PT, @NFT_CODIGO, 3
			
				exec SP_ACTUALIZACALCULOCLASIFICATLC @NFT_CODIGO, 3
		
			end


		-- Se modifico el if poniendo not exists a la condición de imporlog, ya que se supone que si no tiene fracción ni costo
		-- y no existe información en importlog no debe hacer el análisis. 28-oct-2009 Manuel G.
		if exists(select * from CLASIFICATLC WHERE NFT_CODIGO=@NFT_CODIGO and (isnull(ar_codigo,0)=0 or isnull(bst_cos_uni,0)=0))
		or exists(select * from importlog where IML_CBFORMA=@IML_CBFORMA and IML_REFERENCIA=@BST_PT and IML_MENSAJE like '%NO TIENE%')
                 begin
 			-- Se agrego que eliminara la clasificación ya que le falto alguna información
			-- 28-Oct-2009 Manuel G.
                        DELETE FROM CLASIFICATLC WHERE NFT_CODIGO=@NFT_CODIGO

			update nafta
			set nft_califico='N', NFT_BASIS='', NFT_CLASE='1', NFT_FABRICA='0', NFT_CRITERIO='1', NFT_NETCOST='1', NFT_OTRASINST='5'
			where nft_codigo=@NFT_CODIGO
                 end
	end
GO
