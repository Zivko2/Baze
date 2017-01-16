SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_REVISAINFOCLASIFICATLCRango] (@noparteini varchar(30), @nopartefin varchar(30), @spi_codigo int, @FechaEntVigor Datetime, @IncluyeSub char(1), @Tabla char(1)='N', @CL_CODIGO int=0, @FechaEntVencimiento Datetime)   as

declare @BST_PT int, @NFT_CODIGO int, @spi_clave varchar(20), @spi_analisishtsmex char(1), @ma_noparte varchar(30), @ar_codigopt int, @ma_noparteaux varchar(10)
	select @spi_clave=spi_clave from spi where spi_codigo =@spi_codigo

	select @spi_analisishtsmex=spi_analisishtsmex from spi where spi_codigo=@spi_codigo

	DELETE FROM IMPORTLOG WHERE IML_CBFORMA=88
	
	if (select count(*) from IMPORTLOG)=0
	DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS
	declare @macodigo table (MA_CODIGO int)

		
	if @CL_CODIGO>0
	begin
		if @Tabla='S' 
		begin
			insert into @macodigo(ma_codigo)
		
			SELECT MA_CODIGO FROM MAESTRO
			WHERE MA_NOPARTE in (select ma_noparte from TempRangoTlc)
			AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
		end
		else
		if @IncluyeSub='S' 
		begin
			insert into @macodigo(ma_codigo)
			
			SELECT MA_CODIGO FROM MAESTRO
			WHERE MA_NOPARTE >=@noparteini 
			AND MA_NOPARTE <=@nopartefin
			AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
		end
		else
		begin
			insert into @macodigo(ma_codigo)
			
			SELECT MA_CODIGO FROM MAESTRO
			WHERE MA_NOPARTE >=@noparteini 
			AND MA_NOPARTE <=@nopartefin
			AND MA_CODIGO IN (SELECT MA_CODIGO FROM MAESTROCLIENTE WHERE CL_CODIGO=@CL_CODIGO)
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P'))
		end
	end
	else  -- sin cliente
	begin
		if @Tabla='S' 
		begin
			insert into @macodigo(ma_codigo)
		
			SELECT MA_CODIGO FROM MAESTRO
			WHERE MA_NOPARTE in (select ma_noparte from TempRangoTlc)
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
		end
		else
		if @IncluyeSub='S' 
		begin
			insert into @macodigo(ma_codigo)
			
			SELECT MA_CODIGO FROM MAESTRO
			WHERE MA_NOPARTE >=@noparteini 
			AND MA_NOPARTE <=@nopartefin
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P','S'))
		end
		else
		begin
			insert into @macodigo(ma_codigo)
			
			SELECT MA_CODIGO FROM MAESTRO
			WHERE MA_NOPARTE >=@noparteini 
			AND MA_NOPARTE <=@nopartefin
			AND TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P'))
		end
	end

	DECLARE Cur_tlcRango CURSOR FOR
		SELECT     MA_CODIGO
		FROM @macodigo
		order by MA_CODIGO
	OPEN Cur_tlcRango
	
	FETCH NEXT FROM Cur_tlcRango INTO @BST_PT
	
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		if exists(select * from maestrorefer where ma_codigo=@BST_PT)
			select @ma_noparte=ma_noparte, @ma_noparteaux=ma_noparteaux from maestrorefer where ma_codigo=@BST_PT
		else
			select @ma_noparte=ma_noparte, @ma_noparteaux=ma_noparteaux from maestro where ma_codigo=@BST_PT

		if not exists(select * from nafta where ma_codigo=@BST_PT and spi_codigo=@spi_codigo and nft_perini=@FechaEntVigor and nft_perfin=@FechaEntVencimiento)
		begin
			UPDATE NAFTA
			SET NFT_PERFIN=@FechaEntVigor-1
			WHERE  NFT_CODIGO IN
			(SELECT MAX(NF1.NFT_CODIGO) FROM NAFTA NF1 WHERE NF1.ma_codigo=@BST_PT and NF1.spi_codigo=@spi_codigo 
				AND NF1.NFT_PERFIN IN (SELECT MAX(NF2.NFT_PERFIN) FROM NAFTA NF2 WHERE NF2.ma_codigo=@BST_PT and NF2.spi_codigo=@spi_codigo))
			EXEC SP_GETCONSECUTIVO 'NFT', @VALUE = @NFT_CODIGO OUTPUT
			INSERT INTO NAFTA (NFT_CODIGO, MA_CODIGO, SPI_CODIGO, NFT_CLASE, NFT_FABRICA, NFT_CRITERIO, NFT_NETCOST, NFT_OTRASINST, NFT_PERINI, NFT_PERFIN, NFT_CALIFICO, NFT_REFERENCIA, NFT_NOPARTE, NFT_NOPARTEAUX, NFT_FECHA)
			VALUES (@NFT_CODIGO, @BST_PT, @spi_codigo, '1', '0', '1', '1', '5', @FechaEntVigor, @FechaEntVencimiento, 'N', @spi_clave+'('+Replace(convert(varchar(11),@FechaEntVigor,101),'/','')+')', @ma_noparte, @ma_noparteaux, convert(varchar(11),getdate(),101))
		end
		else
		select @NFT_CODIGO=NFT_CODIGO, @ar_codigopt=ar_codigo from nafta where ma_codigo=@BST_PT and spi_codigo=@spi_codigo and nft_perini=@FechaEntVigor and nft_perfin=@FechaEntVencimiento

			if (select CF_ANALISISCOSTOMA from configuracion)='S' AND @spi_codigo in (select spi_codigo from spi where (spi_clave ='mx' or spi_clave ='nafta'))
			begin
				if (SELECT ISNULL(MA_COSTOUNITLC,0) AS MA_COSTOUNITLC FROM MAESTRO WHERE MA_CODIGO =@BST_PT)=0
				INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
				values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADO COSTO PARA EL TRATADO SELECCIONADO', 88)
			end	
			else
			begin
				if @spi_codigo in (select spi_codigo from spi where (spi_clave ='mx' or spi_clave ='nafta'))
				begin
				    if (select count(*) AS CUENTA from maestrocost where mac_codigo in (SELECT max(mac_codigo) FROM MAESTROCOST m1 
				       WHERE m1.SPI_CODIGO in (select spi_codigo from spi where (spi_clave ='mx' or spi_clave ='nafta')) AND m1.TCO_CODIGO in (select TCO_MANUFACTURA from configuracion) AND m1.MA_PERINI <= CONVERT(varchar(11), GETDATE(), 101) 
				        AND m1.MA_PERFIN >= CONVERT(varchar(11), GETDATE(), 101) AND m1.MA_CODIGO=@BST_PT))=0 
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
					values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADO COSTO PARA EL TRATADO SELECCIONADO', 88)
				end
				else
				    if (select count(*) AS CUENTA from maestrocost where mac_codigo in (SELECT max(mac_codigo) FROM MAESTROCOST m1 
				       WHERE m1.SPI_CODIGO = @spi_codigo AND m1.TCO_CODIGO in (select TCO_MANUFACTURA from configuracion) AND m1.MA_PERINI <= CONVERT(varchar(11), GETDATE(), 101) 
				        AND m1.MA_PERFIN >= CONVERT(varchar(11), GETDATE(), 101) AND m1.MA_CODIGO=@BST_PT))=0 
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
					values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADO COSTO PARA EL TRATADO SELECCIONADO', 88)
			end
	
			if @spi_analisishtsmex='S'
			begin
	
				if @ar_codigopt=0
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
					values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADA FRACCION ARANCELARIA MEXICANA', 88)
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
	
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
					values( 'LA FRACCION ARANCELARIA DEL NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADA LA REGLA DE ORIGEN', 88)
	
				end
			end
			else
			begin
	
				if @ar_codigopt=0
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
					values( 'NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADA FRACCION ARANCELARIA AMERICANA', 88)
				else
				begin
	
					if (SELECT     count(*)
					FROM         ARANCELREGLAORIGEN INNER JOIN
					                      REGLAORIGEN INNER JOIN
					                      MAESTRO INNER JOIN
					                      NAFTA ON MAESTRO.MA_CODIGO = NAFTA.MA_CODIGO ON REGLAORIGEN.SPI_CODIGO = NAFTA.SPI_CODIGO ON 
					                      ARANCELREGLAORIGEN.ARR_CODIGO = REGLAORIGEN.ARR_CODIGO AND 
					                      ARANCELREGLAORIGEN.AR_CODIGO = MAESTRO.AR_IMPFO INNER JOIN
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
	
					INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
					values( 'LA FRACCION ARANCELARIA DEL NO. PARTE PT: ' +@ma_noparte +' NO TIENE ASIGNADA LA REGLA DE ORIGEN', 88)
	
				end
			end
	
	
			-- en este procedimiento ya se borra la tabla IMPORTLOG
			exec SP_FILL_BOMDESCTEMPtlc @BST_PT, @NFT_CODIGO, 'S'
	
	
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	
			SELECT 'EL NO. PARTE SUB: ' +MA_NOPARTE+' NO TIENE ASIGNADO ANALISIS NAFTA (SE INCLUYE EN ACUMULACION DEL P.T.'+@ma_noparte+')', 88 
			FROM MAESTRO 
			WHERE MA_CODIGO IN
			(SELECT BST_HIJO FROM CLASIFICATLC WHERE NFT_CODIGO=@NFT_CODIGO AND BST_TIPOCOSTO='S' and BST_TRANS='S')
			AND MA_CODIGO NOT IN (SELECT MA_CODIGO FROM NAFTA WHERE SPI_CODIGO=@SPI_CODIGO)
		
	
	
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO. PARTE : ' +MAESTRO.MA_NOPARTE+' NO TIENE ASIGNADO COSTO VIGENTE', 88
			FROM         CLASIFICATLC INNER JOIN
			                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO
			WHERE     (CLASIFICATLC.BST_COS_UNI IS NULL OR
			                      CLASIFICATLC.BST_COS_UNI = 0) AND (CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO)
	
	
	
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO. PARTE : ' +MAESTRO.MA_NOPARTE+' NO TIENE ASIGNADA FRACCION ARANCELARIA', 88
			FROM         CLASIFICATLC INNER JOIN
			                      MAESTRO ON CLASIFICATLC.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN	
			                      ARANCEL ON CLASIFICATLC.AR_CODIGO = ARANCEL.AR_CODIGO
			WHERE     (ARANCEL.AR_FRACCION IS NULL OR
			                      ARANCEL.AR_FRACCION = '' OR
			                      ARANCEL.AR_FRACCION = 'SINFRACCION' OR
			                      ARANCEL.AR_FRACCION = 'SIN FRACCION') AND (CLASIFICATLC.NFT_CODIGO = @NFT_CODIGO)
	
	FETCH NEXT FROM Cur_tlcRango INTO @BST_PT
	
	END
	
	CLOSE Cur_tlcRango
	DEALLOCATE Cur_tlcRango

	if @Tabla='S' 
	truncate table TempRangoTlc
GO
