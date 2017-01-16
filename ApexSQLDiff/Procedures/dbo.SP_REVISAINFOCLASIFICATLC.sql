SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_REVISAINFOCLASIFICATLC] (@BST_PT Int, @NFT_CODIGO INT)   as

declare @spi_codigo int, @spi_analisishtsmex char(1), @ma_noparte varchar(30), @ar_codigopt int, @IML_CBFORMA int



	select @spi_codigo=spi_codigo, @ar_codigopt=ar_codigo from nafta where nft_codigo=@NFT_CODIGO

	select @spi_analisishtsmex=spi_analisishtsmex from spi where spi_codigo=@spi_codigo

	set @IML_CBFORMA=88

	if exists(select * from maestrorefer where ma_codigo=@BST_PT)
		select @ma_noparte=ma_noparte from maestrorefer where ma_codigo=@BST_PT
	else
		select @ma_noparte=ma_noparte from maestro where ma_codigo=@BST_PT


	
			if (select CF_ANALISISCOSTOMA from configuracion)='S' AND @spi_codigo in (select spi_codigo from spi where (spi_clave ='mx' or spi_clave ='nafta'))
			begin
				if (SELECT ISNULL(MA_COSTOUNITLC,0) AS MA_COSTOUNITLC FROM MAESTRO WHERE MA_CODIGO =@BST_PT)=0
				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
				values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADO COSTO PARA EL TRATADO SELECCIONADO', @IML_CBFORMA, @BST_PT)
			end	
			else
			begin
				if @spi_codigo in (select spi_codigo from spi where (spi_clave ='mx' or spi_clave ='nafta'))
				begin
				    if (select count(*) AS CUENTA from maestrocost where mac_codigo in (SELECT max(mac_codigo) FROM MAESTROCOST m1 
				       WHERE m1.SPI_CODIGO in (select spi_codigo from spi where (spi_clave ='mx' or spi_clave ='nafta')) AND m1.TCO_CODIGO in (select TCO_MANUFACTURA from configuracion) AND m1.MA_PERINI <= CONVERT(varchar(11), GETDATE(), 101) 
				        AND m1.MA_PERFIN >= CONVERT(varchar(11), GETDATE(), 101) AND m1.MA_CODIGO=@BST_PT))=0 
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
					values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADO COSTO PARA EL TRATADO SELECCIONADO', @IML_CBFORMA, @BST_PT)
	
				end
				else
				    if (select count(*) AS CUENTA from maestrocost where mac_codigo in (SELECT max(mac_codigo) FROM MAESTROCOST m1 
				       WHERE m1.SPI_CODIGO = @spi_codigo AND m1.TCO_CODIGO in (select TCO_MANUFACTURA from configuracion) AND m1.MA_PERINI <= CONVERT(varchar(11), GETDATE(), 101) 
				        AND m1.MA_PERFIN >= CONVERT(varchar(11), GETDATE(), 101) AND m1.MA_CODIGO=@BST_PT))=0 
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
					values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADO COSTO PARA EL TRATADO SELECCIONADO', @IML_CBFORMA, @BST_PT)
			end



			if @spi_analisishtsmex='S'
			begin
	
				if @ar_codigopt=0
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
					values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADA FRACCION ARANCELARIA MEXICANA', @IML_CBFORMA, @BST_PT)
				else
				begin
	
	
					if (SELECT     count(*)
					FROM         ARANCELREGLAORIGEN INNER JOIN
					                      REGLAORIGEN INNER JOIN
					                      MAESTRO INNER JOIN
					                      NAFTA ON MAESTRO.MA_CODIGO = NAFTA.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
					                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
					                      ARANCELREGLAORIGEN.AR_CODIGO = MAESTRO.AR_IMPMX INNER JOIN
					                      ARANCEL ON MAESTRO.AR_IMPMX = ARANCEL.AR_CODIGO LEFT OUTER JOIN
					                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
					WHERE     (NAFTA.NFT_CODIGO = @nft_codigo)
					--Yolanda Avila
					--2010-09-20
					and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
					     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))			
					--Yolanda Avila
					and left(arancel.ar_fraccion,len(reglaorigen.arr_partidaPT)) between reglaorigen.arr_partidaPT and arr_partidaptf
					) = 0
	
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
					values( 'LA FRACCION ARANCELARIA DEL NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADA LA REGLA DE ORIGEN', @IML_CBFORMA, @BST_PT)
	
				end
			end
			else
			begin
	
				if @ar_codigopt=0
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
					values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADA FRACCION ARANCELARIA AMERICANA', @IML_CBFORMA, @BST_PT)
				else
				begin
	
					if (SELECT     count(*)
					FROM         ARANCELREGLAORIGEN INNER JOIN
					                      REGLAORIGEN INNER JOIN
					                      MAESTRO INNER JOIN
					                      NAFTA ON MAESTRO.MA_CODIGO = NAFTA.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
					                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
					                      ARANCELREGLAORIGEN.AR_CODIGO = MAESTRO.AR_IMPFO INNER JOIN
					                      ARANCEL ON MAESTRO.AR_IMPFO = ARANCEL.AR_CODIGO LEFT OUTER JOIN
					                      REGLAORIGENDET ON REGLAORIGEN.ARR_CODIGO = REGLAORIGENDET.ARR_CODIGO
					WHERE     (NAFTA.NFT_CODIGO = @nft_codigo)
					--Yolanda Avila
					--2010-09-20
					and (ArancelReglaOrigen.arr_PERINI <= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101)
					     and ArancelReglaOrigen.arr_PERFIN >= CONVERT(varchar(11), (select nafta2.nft_fecha from nafta nafta2 where nafta2.nft_codigo = @nft_codigo), 101))			
					--Yolanda Avila
					and left(arancel.ar_fraccion,len(reglaorigen.arr_partidaPT)) between reglaorigen.arr_partidaPT and arr_partidaptf
					) = 0
					begin
						print 'Algo'
						INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
						values( 'LA FRACCION ARANCELARIA DEL NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADA LA REGLA DE ORIGEN', @IML_CBFORMA, @BST_PT)
					end 
				end
			end
	
	

	

	



		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 

		SELECT 'EL NO. PARTE SUB: ' +MA_NOPARTE+' NO TIENE ASIGNADO ANALISIS NAFTA (SE INCLUYE EN ACUMULACION DEL P.T.'+@ma_noparte+')', @IML_CBFORMA, @BST_PT 
		FROM MAESTRO 
		WHERE MA_CODIGO IN
		(SELECT BST_HIJO FROM CLASIFICATLC WHERE NFT_CODIGO=@NFT_CODIGO AND BST_TIPOCOSTO='S' and BST_TRANS='S')
		AND MA_CODIGO NOT IN (SELECT MA_CODIGO FROM NAFTA WHERE SPI_CODIGO=@SPI_CODIGO)




		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
		SELECT     'NO. PARTE : ' +MAESTRO.MA_NOPARTE+' NO TIENE ASIGNADO COSTO VIGENTE', @IML_CBFORMA, @BST_PT
		FROM         CLASIFICATLC INNER JOIN
		                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO
		WHERE     (CLASIFICATLC.BST_COS_UNI IS NULL OR
		                      CLASIFICATLC.BST_COS_UNI = 0) AND (CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO)



		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA, IML_REFERENCIA) 
		SELECT     'NO. PARTE : ' +MAESTRO.MA_NOPARTE+' NO TIENE ASIGNADA FRACCION ARANCELARIA', @IML_CBFORMA, @BST_PT
		FROM         CLASIFICATLC INNER JOIN
		                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      ARANCEL ON CLASIFICATLC.AR_CODIGO = ARANCEL.AR_CODIGO
		WHERE     (ARANCEL.AR_FRACCION IS NULL OR
		                      ARANCEL.AR_FRACCION = '' OR
		                      ARANCEL.AR_FRACCION = 'SINFRACCION' OR
		                      ARANCEL.AR_FRACCION = 'SIN FRACCION') AND (CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO)

GO
