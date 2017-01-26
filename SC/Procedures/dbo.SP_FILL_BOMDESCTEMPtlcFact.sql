SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
/* inserta en la tabla CLASIFICATLC  los del nivel 1 el bom  para calculo de costos y calculo de aranceles, esto con la ultima estructura dinamica capturada*/
CREATE PROCEDURE [dbo].[SP_FILL_BOMDESCTEMPtlcFact] (@BST_PT Int, @NFT_CODIGO INT)   as

SET NOCOUNT ON 
declare @BST_HIJO int, @BST_INCORPOR decimal(38,6), @BST_DISCH char(1), @TI_CODIGO char(1), @ME_CODIGO int, @Factconv decimal(28,14), 
    @BST_PERINI datetime, @BST_PERFIN datetime, @ME_GEN int, @BST_TRANS char(1), @BST_TIPOCOSTO char(1), 
   @MA_TIP_ENS char(1), @BST_ENTRAVIGOR DateTime,  @CF_USATIPOADQUISICION char(1), @CF_NIVELES  int,
 @bst_perini2 datetime, @PA_CODIGO int, @cf_pais_mx int, @ar_codigo int, @cf_pais_ca int, @spi_codigo int

	UPDATE NAFTA
	SET     NFT_FECHA=GETDATE()
	WHERE NFT_CODIGO=@NFT_CODIGO and NFT_FECHA is null


	select @BST_ENTRAVIGOR = NFT_FECHA from nafta where nft_codigo=@NFT_CODIGO


DELETE FROM CLASIFICATLC WHERE NFT_CODIGO = @NFT_CODIGO

select  @CF_USATIPOADQUISICION = CF_USATIPOADQUISICION, @CF_NIVELES = CF_NIVELES,
@cf_pais_mx=cf_pais_mx, @cf_pais_ca=cf_pais_ca from configuracion

select @spi_codigo=spi_codigo from nafta where nft_codigo=@NFT_CODIGO




			insert into CLASIFICATLC(BST_PT, BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, 
			    BST_DISCH, TI_CODIGO, ME_CODIGO, FACTCONV, BST_PERINI, BST_PERFIN, ME_GEN, 
			    BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, BST_NIVEL, BST_PERTENECE,
 			PA_CODIGO, AR_CODIGO, NFT_CODIGO)



			SELECT     @BST_PT, @BST_ENTRAVIGOR, RETRABAJO.MA_HIJO, SUM(RETRABAJO.RE_INCORPOR) AS RE_INCORPOR, 
					'S',  CONFIGURATIPO.CFT_TIPO, RETRABAJO.ME_CODIGO, RETRABAJO.FACTCONV, @BST_ENTRAVIGOR, 
			                      @BST_ENTRAVIGOR, RETRABAJO.ME_GEN, 'N', 'Z', 
			                      CASE WHEN MAESTRO.MA_TIP_ENS='A' THEN 'C' ELSE MAESTRO.MA_TIP_ENS END, 1, @BST_PT,
					RETRABAJO.PA_ORIGEN, 'AR_CODIGO'=CASE WHEN @spi_codigo in (select spi_codigo from spi where SPI_ANALISISHTSMEX='S') then MAX(MAESTRO.AR_IMPMX) else MAX(MAESTRO.AR_IMPFO) end, @NFT_CODIGO
			FROM         RETRABAJO LEFT OUTER JOIN
			                      CONFIGURATIPO ON RETRABAJO.TI_HIJO = CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
			                      MAESTRO ON RETRABAJO.MA_HIJO = MAESTRO.MA_CODIGO INNER JOIN
				     FACTEXPDET ON RETRABAJO.FETR_INDICED = FACTEXPDET.FED_INDICED 
			WHERE (((CONFIGURATIPO.CFT_TIPO<>'P' and CONFIGURATIPO.CFT_TIPO<>'S') and (MAESTRO.MA_TIP_ENS='C' or MAESTRO.MA_TIP_ENS is null))
			or ((CONFIGURATIPO.CFT_TIPO='P' or CONFIGURATIPO.CFT_TIPO='S') and (MAESTRO.MA_TIP_ENS='C' or MAESTRO.MA_TIP_ENS='A' or MAESTRO.MA_TIP_ENS='E' or MAESTRO.MA_TIP_ENS='O')))
			AND (FACTEXPDET.MA_CODIGO = @BST_PT) 
			AND RETRABAJO.FETR_CODIGO IN 
				(SELECT     MAX(FACTEXP.FE_CODIGO)
				FROM         FACTEXP INNER JOIN
				                      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
				WHERE     (FACTEXPDET.MA_CODIGO = @BST_PT) AND (FACTEXPDET.FED_RETRABAJO = 'D') AND
				           FACTEXP.FE_FECHA IN
				  	  (SELECT MAX(FACTEXP.FE_FECHA)
					   FROM  FACTEXP INNER JOIN
					      FACTEXPDET ON FACTEXP.FE_CODIGO = FACTEXPDET.FE_CODIGO
				  	   WHERE FACTEXPDET.MA_CODIGO = @BST_PT AND FACTEXPDET.FED_RETRABAJO = 'D'))
			AND RETRABAJO.RE_INCORPOR >0 

			GROUP BY RETRABAJO.MA_HIJO, CONFIGURATIPO.CFT_TIPO, RETRABAJO.ME_CODIGO, 
			                      RETRABAJO.FACTCONV, RETRABAJO.ME_GEN, 
			                      MAESTRO.MA_TIP_ENS,  
			                      RETRABAJO.PA_ORIGEN
			ORDER BY RETRABAJO.MA_HIJO




	-- Actualiza el costo del producto para guardar historial del calculo
   	exec SP_ACTUALIZATIPOCOSTOCLASIFICATLC @NFT_CODIGO -- actualiza el tipo de costo en base al nft que se esta corriendo

	 exec SP_ACTUALIZATIPOMATORIG @BST_PT, @NFT_CODIGO



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

GO
