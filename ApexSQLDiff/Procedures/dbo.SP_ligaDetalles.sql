SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ligaDetalles]   as

declare @Consecutivo int, @DescSpanish varchar(250), @UnitValueUSD decimal(38,6), @PA_CODIGO int, @InvoiceNo varchar(25), @PI_CODIGO int, @AR_CODIGO int,
@PIB_INDICEB INT, @FI_CODIGO INT, @INDENTIFICADOR CHAR(1), @PIB_NOPARTE VARCHAR(30)


	update pedimpconciliaDet
	set PIB_INDICEB=0
	where PIB_INDICEB is null
	
	update pedimpconciliaDetContribucion
	set PIB_INDICEB=0
	where PIB_INDICEB is null


	if (select cf_conciliasaaisec from configuracion)='S'
	begin


			UPDATE pedimpconciliaDet
			SET    pedimpconciliaDet.PIB_INDICEB= PEDIMPDETB.PIB_INDICEB
			FROM         pedimpconciliaDet inner join PEDIMPDETB on 
			pedimpconciliaDet.PI_CODIGO = PEDIMPDETB.PI_CODIGO and 
			pedimpconciliaDet.RecordNum = PEDIMPDETB.PIB_SECUENCIA


	end
	else
	begin

		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##TempLigaDetalles'  AND  type = 'U')
		begin
			drop table ##TempLigaDetalles
		end
		--exec sp_droptable '##TempLigaDetalles'
	
		SELECT PIB_INDICEB, PIB_NOMBRE, PI_CODIGO, round(PIB_COS_UNIGEN,4) as PIB_COS_UNIGEN, PA_ORIGEN, AR_IMPMX, PIB_CODIGOFACT,
		'INDENTIFICADOR'=CASE WHEN (SELECT IDENTIFICA.IDE_CLAVE
			FROM PEDIMPDETIDENTIFICA INNER JOIN
			     IDENTIFICA ON PEDIMPDETIDENTIFICA.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
			WHERE IDENTIFICA.IDE_CODIGO IN (SELECT IDE_CODIGO FROM IDENTIFICA WHERE IDE_CLAVE IN ('TL', 'PS', 'C1'))
			AND PEDIMPDETIDENTIFICA.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB)='TL' THEN 'P'
		WHEN (SELECT IDENTIFICA.IDE_CLAVE
			FROM PEDIMPDETIDENTIFICA INNER JOIN
			     IDENTIFICA ON PEDIMPDETIDENTIFICA.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
			WHERE IDENTIFICA.IDE_CODIGO IN (SELECT IDE_CODIGO FROM IDENTIFICA WHERE IDE_CLAVE IN ('TL', 'PS', 'C1'))
			AND PEDIMPDETIDENTIFICA.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB)='PS' THEN 'S'
		WHEN (SELECT IDENTIFICA.IDE_CLAVE
			FROM PEDIMPDETIDENTIFICA INNER JOIN
			     IDENTIFICA ON PEDIMPDETIDENTIFICA.IDE_CODIGO = IDENTIFICA.IDE_CODIGO
			WHERE IDENTIFICA.IDE_CODIGO IN (SELECT IDE_CODIGO FROM IDENTIFICA WHERE IDE_CLAVE IN ('TL', 'PS', 'C1'))
			AND PEDIMPDETIDENTIFICA.PIB_INDICEB = PEDIMPDETB.PIB_INDICEB)='C1' THEN 'R'
		ELSE
		'G' END
		into dbo.##TempLigaDetalles
		FROM PEDIMPDETB WHERE PI_CODIGO in (select pi_codigo from pedimpconciliaDet group by pi_codigo)
	
	
		UPDATE ##TempLigaDetalles
		SET PIB_NOMBRE=Replace(PIB_NOMBRE,'P/','PARA')
		WHERE PIB_NOMBRE LIKE '%P/%'
	
		UPDATE ##TempLigaDetalles
		SET PIB_NOMBRE=Replace(PIB_NOMBRE,'C/','CON')
		WHERE PIB_NOMBRE LIKE '%C/%'
	
		UPDATE ##TempLigaDetalles
		SET PIB_NOMBRE=Replace(PIB_NOMBRE,'/',' ')
		WHERE PIB_NOMBRE LIKE '%/%'
	
		UPDATE ##TempLigaDetalles
		SET PIB_NOMBRE= Replace(PIB_NOMBRE,'-',' ')
		WHERE PIB_NOMBRE LIKE '%-%'
	
		UPDATE ##TempLigaDetalles
		SET PIB_NOMBRE= Replace(PIB_NOMBRE,'%',' ')
	
		UPDATE ##TempLigaDetalles
		SET PIB_NOMBRE=Replace(PIB_NOMBRE,'#','No.')
		WHERE PIB_NOMBRE LIKE '%#%'
	
	
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##TempLigaDetalles'  AND  type = 'U')
		begin
			drop table ##TempLigaDetallesArchivo
		end
	
		--exec sp_droptable '##TempLigaDetallesArchivo'
	
	
			SELECT     pedimpconciliaDet.Consecutivo, pedimpconciliaDet.DescSpanish, round(pedimpconciliaDet.UnitValueUSD,4) as UnitValueUSD, PAIS.PA_CODIGO, 
			            pedimpconciliaDet.PI_CODIGO, ARANCEL.AR_CODIGO, 'INDENTIFICADOR'=CASE WHEN (SELECT Identificator FROM pedimpconciliaDetIdentifica WHERE Identificator IN ('TL', 'PS', 'C1') 
				    and PI_CODIGO=pedimpconciliaDet.PI_CODIGO and pedimpconciliaDetIdentifica.RecordNum=pedimpconciliaDet.RecordNum)='TL' THEN
				      'P' WHEN (SELECT Identificator FROM pedimpconciliaDetIdentifica WHERE Identificator IN ('TL', 'PS', 'C1') 
				    and PI_CODIGO=pedimpconciliaDet.PI_CODIGO and pedimpconciliaDetIdentifica.RecordNum=pedimpconciliaDet.RecordNum)='C1' THEN
				      'R' WHEN (SELECT Identificator FROM pedimpconciliaDetIdentifica WHERE Identificator IN ('TL', 'PS', 'C1') 
				    and PI_CODIGO=pedimpconciliaDet.PI_CODIGO and pedimpconciliaDetIdentifica.RecordNum=pedimpconciliaDet.RecordNum)='PS' THEN
				     'S' else 'G' end
			into dbo.##TempLigaDetallesArchivo
			FROM         pedimpconciliaDet LEFT OUTER JOIN
			                      ARANCEL ON pedimpconciliaDet.HTS = replace(ARANCEL.AR_FRACCION,'.','') LEFT OUTER JOIN
			                      PAIS ON pedimpconciliaDet.CountryOrig = PAIS.PA_SAAIM3
	
	
	
	
			UPDATE dbo.pedimpconciliaDet
			SET     dbo.pedimpconciliaDet.PIB_INDICEB= dbo.##TempLigaDetalles.PIB_INDICEB
			FROM         dbo.pedimpconciliaDet INNER JOIN
			                      dbo.##TempLigaDetallesArchivo ON dbo.pedimpconciliaDet.Consecutivo = dbo.##TempLigaDetallesArchivo.Consecutivo INNER JOIN
			                      dbo.##TempLigaDetalles ON dbo.##TempLigaDetallesArchivo.UnitValueUSD = dbo.##TempLigaDetalles.PIB_COS_UNIGEN AND 
			                      dbo.##TempLigaDetallesArchivo.DescSpanish = dbo.##TempLigaDetalles.PIB_NOMBRE AND 
			                      dbo.##TempLigaDetallesArchivo.PI_CODIGO = dbo.##TempLigaDetalles.PI_CODIGO AND 
			                      dbo.##TempLigaDetallesArchivo.PA_CODIGO = dbo.##TempLigaDetalles.PA_ORIGEN AND 
			                      dbo.##TempLigaDetallesArchivo.AR_CODIGO = dbo.##TempLigaDetalles.AR_IMPMX AND 
			                      dbo.##TempLigaDetallesArchivo.INDENTIFICADOR = dbo.##TempLigaDetalles.INDENTIFICADOR
			WHERE pedimpconciliaDet.PIB_INDICEB=0
	
	
			UPDATE dbo.pedimpconciliaDet
			SET     dbo.pedimpconciliaDet.PIB_INDICEB= dbo.##TempLigaDetalles.PIB_INDICEB
			FROM         dbo.pedimpconciliaDet INNER JOIN
			                      dbo.##TempLigaDetallesArchivo ON dbo.pedimpconciliaDet.Consecutivo = dbo.##TempLigaDetallesArchivo.Consecutivo INNER JOIN
			                      dbo.##TempLigaDetalles ON dbo.##TempLigaDetallesArchivo.DescSpanish = dbo.##TempLigaDetalles.PIB_NOMBRE AND 
			                      dbo.##TempLigaDetallesArchivo.PI_CODIGO = dbo.##TempLigaDetalles.PI_CODIGO AND 
			                      dbo.##TempLigaDetallesArchivo.PA_CODIGO = dbo.##TempLigaDetalles.PA_ORIGEN AND 
			                      dbo.##TempLigaDetallesArchivo.AR_CODIGO = dbo.##TempLigaDetalles.AR_IMPMX AND 
			                      dbo.##TempLigaDetallesArchivo.INDENTIFICADOR = dbo.##TempLigaDetalles.INDENTIFICADOR
			WHERE pedimpconciliaDet.PIB_INDICEB=0
	
	
	
			UPDATE dbo.pedimpconciliaDet
			SET     dbo.pedimpconciliaDet.PIB_INDICEB= dbo.##TempLigaDetalles.PIB_INDICEB
			FROM         dbo.pedimpconciliaDet INNER JOIN
			                      dbo.##TempLigaDetallesArchivo ON dbo.pedimpconciliaDet.Consecutivo = dbo.##TempLigaDetallesArchivo.Consecutivo INNER JOIN
			                      dbo.##TempLigaDetalles ON dbo.##TempLigaDetallesArchivo.UnitValueUSD = dbo.##TempLigaDetalles.PIB_COS_UNIGEN AND 
			                      dbo.##TempLigaDetallesArchivo.DescSpanish = dbo.##TempLigaDetalles.PIB_NOMBRE AND 
			                      dbo.##TempLigaDetallesArchivo.PI_CODIGO = dbo.##TempLigaDetalles.PI_CODIGO AND 
			                      dbo.##TempLigaDetallesArchivo.PA_CODIGO = dbo.##TempLigaDetalles.PA_ORIGEN AND 
			                      dbo.##TempLigaDetallesArchivo.AR_CODIGO = dbo.##TempLigaDetalles.AR_IMPMX 
			WHERE pedimpconciliaDet.PIB_INDICEB=0
	
			UPDATE dbo.pedimpconciliaDet
			SET     dbo.pedimpconciliaDet.PIB_INDICEB= dbo.##TempLigaDetalles.PIB_INDICEB
			FROM         dbo.pedimpconciliaDet INNER JOIN
			                      dbo.##TempLigaDetallesArchivo ON dbo.pedimpconciliaDet.Consecutivo = dbo.##TempLigaDetallesArchivo.Consecutivo INNER JOIN
			                      dbo.##TempLigaDetalles ON dbo.##TempLigaDetallesArchivo.UnitValueUSD = dbo.##TempLigaDetalles.PIB_COS_UNIGEN AND 
			                      dbo.##TempLigaDetallesArchivo.DescSpanish = dbo.##TempLigaDetalles.PIB_NOMBRE AND 
			                      dbo.##TempLigaDetallesArchivo.PI_CODIGO = dbo.##TempLigaDetalles.PI_CODIGO AND 
			                      dbo.##TempLigaDetallesArchivo.PA_CODIGO = dbo.##TempLigaDetalles.PA_ORIGEN
			WHERE pedimpconciliaDet.PIB_INDICEB=0
	
	
			UPDATE dbo.pedimpconciliaDet
			SET     dbo.pedimpconciliaDet.PIB_INDICEB= dbo.##TempLigaDetalles.PIB_INDICEB
			FROM         dbo.pedimpconciliaDet INNER JOIN
			                      dbo.##TempLigaDetallesArchivo ON dbo.pedimpconciliaDet.Consecutivo = dbo.##TempLigaDetallesArchivo.Consecutivo INNER JOIN
			                      dbo.##TempLigaDetalles ON dbo.##TempLigaDetallesArchivo.DescSpanish = dbo.##TempLigaDetalles.PIB_NOMBRE AND 
			                      dbo.##TempLigaDetallesArchivo.PI_CODIGO = dbo.##TempLigaDetalles.PI_CODIGO AND 
			                      dbo.##TempLigaDetallesArchivo.PA_CODIGO = dbo.##TempLigaDetalles.PA_ORIGEN
			WHERE pedimpconciliaDet.PIB_INDICEB=0
	
	
		/*declare cur_LigaDetalles cursor for
			SELECT     pedimpconciliaDet.Consecutivo, pedimpconciliaDet.DescSpanish, round(pedimpconciliaDet.UnitValueUSD,6), PAIS.PA_CODIGO, 
			            pedimpconciliaDet.PI_CODIGO, ARANCEL.AR_CODIGO, CASE WHEN (SELECT Identificator FROM pedimpconciliaDetIdentifica WHERE Identificator IN ('TL', 'PS', 'C1') 
				    and PI_CODIGO=pedimpconciliaDet.PI_CODIGO and pedimpconciliaDetIdentifica.RecordNum=pedimpconciliaDet.RecordNum)='TL' THEN
				      'P' WHEN (SELECT Identificator FROM pedimpconciliaDetIdentifica WHERE Identificator IN ('TL', 'PS', 'C1') 
				    and PI_CODIGO=pedimpconciliaDet.PI_CODIGO and pedimpconciliaDetIdentifica.RecordNum=pedimpconciliaDet.RecordNum)='C1' THEN
				      'R' WHEN (SELECT Identificator FROM pedimpconciliaDetIdentifica WHERE Identificator IN ('TL', 'PS', 'C1') 
				    and PI_CODIGO=pedimpconciliaDet.PI_CODIGO and pedimpconciliaDetIdentifica.RecordNum=pedimpconciliaDet.RecordNum)='PS' THEN
				     'S' else 'G' end
			FROM         pedimpconciliaDet LEFT OUTER JOIN
			                      ARANCEL ON pedimpconciliaDet.HTS = replace(ARANCEL.AR_FRACCION,'.','') LEFT OUTER JOIN
			                      PAIS ON pedimpconciliaDet.CountryOrig = PAIS.PA_SAAIM3
		open cur_LigaDetalles
			FETCH NEXT FROM cur_LigaDetalles INTO @Consecutivo, @DescSpanish, @UnitValueUSD, @PA_CODIGO, 
			                      @PI_CODIGO, @AR_CODIGO, @INDENTIFICADOR
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN
				
	
					if (select pib_indiceb from pedimpconciliaDet where Consecutivo=@Consecutivo)=0
					begin
	
	
						SELECT @PIB_INDICEB=PIB_INDICEB FROM ##TempLigaDetalles WHERE PI_CODIGO=@PI_CODIGO
						AND PIB_NOMBRE=@DescSpanish AND PIB_COS_UNIGEN=@UnitValueUSD 
						AND PA_ORIGEN=@PA_CODIGO AND AR_IMPMX=@AR_CODIGO 
						AND PIB_CONTRIBPOR=@INDENTIFICADOR
		
						UPDATE pedimpconciliaDet
						SET PIB_INDICEB=@PIB_INDICEB
						WHERE Consecutivo=@Consecutivo
						and PIB_INDICEB=0
					end
	
	
					if (select pib_indiceb from pedimpconciliaDet where Consecutivo=@Consecutivo)=0
					begin
	
	
						SELECT @PIB_INDICEB=PIB_INDICEB FROM ##TempLigaDetalles WHERE PI_CODIGO=@PI_CODIGO
						AND PIB_NOMBRE=@DescSpanish AND PIB_COS_UNIGEN=@UnitValueUSD 
						AND PA_ORIGEN=@PA_CODIGO AND AR_IMPMX=@AR_CODIGO 
		
						UPDATE pedimpconciliaDet
						SET PIB_INDICEB=@PIB_INDICEB
						WHERE Consecutivo=@Consecutivo
						and PIB_INDICEB=0
					end
	
	
					if (select pib_indiceb from pedimpconciliaDet where Consecutivo=@Consecutivo)=0
					begin
	
						SELECT @PIB_INDICEB=PIB_INDICEB FROM ##TempLigaDetalles WHERE PI_CODIGO=@PI_CODIGO
						AND PIB_NOMBRE=@DescSpanish AND PIB_COS_UNIGEN=@UnitValueUSD 
						AND PA_ORIGEN=@PA_CODIGO 
		
						UPDATE pedimpconciliaDet
						SET PIB_INDICEB=@PIB_INDICEB
						WHERE Consecutivo=@Consecutivo
						and (PIB_INDICEB=0)
					end
	
					if (select pib_indiceb from pedimpconciliaDet where Consecutivo=@Consecutivo)=0
					begin
						SELECT @PIB_INDICEB=PIB_INDICEB FROM ##TempLigaDetalles WHERE PI_CODIGO=@PI_CODIGO
						AND PIB_NOMBRE=@DescSpanish AND PA_ORIGEN=@PA_CODIGO 
		
						UPDATE pedimpconciliaDet
						SET PIB_INDICEB=@PIB_INDICEB
						WHERE Consecutivo=@Consecutivo
						and (PIB_INDICEB=0)
					end
	
			FETCH NEXT FROM cur_LigaDetalles INTO @Consecutivo, @DescSpanish, @UnitValueUSD, @PA_CODIGO, 
			                      @PI_CODIGO, @AR_CODIGO, @INDENTIFICADOR
		
		END
		
		CLOSE cur_LigaDetalles
		DEALLOCATE cur_LigaDetalles*/
	
		exec sp_droptable '##TempLigaDetalles'
	
		exec sp_droptable '##TempLigaDetallesArchivo'
	
	
	
	
	
	
		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##TempLigaDetalles'  AND  type = 'U')
		begin
			drop table ##TempLigaDetalles
		end
	end



			UPDATE pedimpconciliaDetContribucion
			SET    pedimpconciliaDetContribucion.PIB_INDICEB= pedimpconciliaDet.PIB_INDICEB
			FROM        pedimpconciliaDetContribucion inner join  pedimpconciliaDet on 
			pedimpconciliaDetContribucion.PI_CODIGO = pedimpconciliaDet.PI_CODIGO and 
			pedimpconciliaDetContribucion.RecordNum = pedimpconciliaDet.RecordNum
GO
