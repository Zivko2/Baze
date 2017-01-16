SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
/* inserta en la tabla CLASIFICATLC  los del nivel 1 el bom  para calculo de costos y calculo de aranceles, esto con la ultima estructura dinamica capturada*/
CREATE PROCEDURE [dbo].[SP_FILL_BOMDESCTEMPRecalcular] (@NFT_CODIGO INT)   as

SET NOCOUNT ON 
declare @BST_HIJO int, @BST_INCORPOR decimal(38,6), @BST_DISCH char(1), @TI_CODIGO char(1), @ME_CODIGO int, @Factconv decimal(28,14), 
    @BST_PERINI datetime, @BST_PERFIN datetime, @ME_GEN int, @BST_TRANS char(1), @BST_TIPOCOSTO char(1), 
   @MA_TIP_ENS char(1), @BST_ENTRAVIGOR DateTime,  @CF_USATIPOADQUISICION char(1), @CF_NIVELES  int, @BST_PT INT, 
 @bst_perini2 datetime, @PA_CODIGO int, @cf_pais_mx int, @ar_codigo int, @cf_pais_ca int, @spi_codigo int

	UPDATE NAFTA
	SET     NFT_FECHA=GETDATE()
	WHERE NFT_CODIGO=@NFT_CODIGO and NFT_FECHA is null


	select @spi_codigo=spi_codigo, @BST_ENTRAVIGOR = NFT_FECHA, @BST_PT=MA_CODIGO from nafta where nft_codigo=@NFT_CODIGO


	select  @CF_USATIPOADQUISICION = CF_USATIPOADQUISICION, @CF_NIVELES = CF_NIVELES,
	@cf_pais_mx=cf_pais_mx, @cf_pais_ca=cf_pais_ca from configuracion


	-- Actualiza el costo del producto para guardar historial del calculo
   	exec SP_ACTUALIZATIPOCOSTOCLASIFICATLC @NFT_CODIGO -- actualiza el tipo de costo en base al nft que se esta corriendo



	UPDATE CLASIFICATLC
	SET BST_EMPAQUE=(CASE WHEN BST_TIPOCOSTO in ('E', 'F')  THEN
					round(BST_INCORPOR * BST_COS_UNI,6) ELSE 0 END),
	BST_MATORIG=(CASE WHEN BST_TIPOCOSTO in ('C', 'D', 'N', 'P') THEN
					round(BST_INCORPOR * BST_COS_UNI,6) ELSE 0 END),
	BST_MATNOORIG=(CASE WHEN BST_TIPOCOSTO in ('A', 'B') THEN
					round(BST_INCORPOR * BST_COS_UNI,6) ELSE 0 END),
	BST_TIPOORIG=(CASE WHEN BST_TIPOCOSTO in ('E', 'F')  THEN
					'E' WHEN BST_TIPOCOSTO in ('C', 'D', 'N', 'P') THEN 'O' ELSE 'N' END)
	WHERE NFT_CODIGO=@NFT_CODIGO


	UPDATE dbo.CLASIFICATLC
	SET BST_EMPAQUE = 0
	WHERE BST_EMPAQUE IS NULL

	UPDATE dbo.CLASIFICATLC
	SET BST_MATORIG = 0 
	WHERE BST_MATORIG IS NULL

	UPDATE dbo.CLASIFICATLC
	SET BST_MATNOORIG = 0
	WHERE BST_MATNOORIG IS NULL


	----------------------- regla 1 -----------------------------------------------------------
	
		EXEC Sp_SaltoArancelario @BST_PT, @NFT_CODIGO, 1
	
	
		exec sp_SaltoExcepto @BST_PT, @NFT_CODIGO, 1
	
		exec SP_ACTUALIZACALCULOCLASIFICATLC @NFT_CODIGO, 1
	
	
		----------------------- regla 2 -----------------------------------------------------------
		if (select nft_califico from nafta where nft_codigo=@NFT_CODIGO)<>'S' and
		exists (SELECT     REGLAORIGENDET.ARR_PARTIDASALTO
		FROM         ARANCELREGLAORIGEN INNER JOIN
		                      REGLAORIGEN INNER JOIN
		                      NAFTA ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
		                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
		                      ARANCELREGLAORIGEN.AR_CODIGO = NAFTA.AR_CODIGO INNER JOIN
		                      ARANCEL ON NAFTA.AR_CODIGO = ARANCEL.AR_CODIGO LEFT OUTER JOIN
		                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
		WHERE     (NAFTA.NFT_CODIGO = @nft_codigo) AND (REGLAORIGENDET.ARR_REGLA = '2')
		--Yolanda Avila
		--2010-09-20
		and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
		     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))
		)

		begin
		
			EXEC Sp_SaltoArancelario @BST_PT, @NFT_CODIGO, 2
		
			 exec sp_SaltoExcepto @BST_PT, @NFT_CODIGO, 2
		
			exec SP_ACTUALIZACALCULOCLASIFICATLC @NFT_CODIGO, 2
	
		end
	
		----------------------- regla 3 -----------------------------------------------------------
		if (select nft_califico from nafta where nft_codigo=@NFT_CODIGO)<>'S' and
		exists (SELECT     REGLAORIGENDET.ARR_PARTIDASALTO
		FROM         ARANCELREGLAORIGEN INNER JOIN
		                      REGLAORIGEN INNER JOIN
		                      NAFTA ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
		                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
		                      ARANCELREGLAORIGEN.AR_CODIGO = NAFTA.AR_CODIGO INNER JOIN
		                      ARANCEL ON NAFTA.AR_CODIGO = ARANCEL.AR_CODIGO LEFT OUTER JOIN
		                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
		WHERE     (NAFTA.NFT_CODIGO = @nft_codigo) AND (REGLAORIGENDET.ARR_REGLA = '3')
		--Yolanda Avila
		--2010-09-20
		and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
		     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))
		)

		begin
		
			EXEC Sp_SaltoArancelario @BST_PT, @NFT_CODIGO, 3
		
		
			 exec sp_SaltoExcepto @BST_PT, @NFT_CODIGO, 3
		
			exec SP_ACTUALIZACALCULOCLASIFICATLC @NFT_CODIGO, 3
	
		end
GO
