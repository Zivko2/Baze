SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_AJUSTAVENCE1a] (@fecha datetime)   as

/* la @fecha es la fecha final hasta la cual se deben de checar los pedimentos,
 este procedimiento incluye solo los fed_indiced que no contemplan el ma_generico a descargar y que sean de pt o sub*/
DECLARE @RestaDescargar decimal(38,6), @PID_INDICED INT, @MA_CODIGO INT, @MA_GENERICO INT, @PI_FEC_ENT DATETIME, @PID_FECHAVENCE DATETIME,
@CONSECUTIVO INT, @KAP_INDICED_FACT INT, @fQtyADescargar decimal(38,6), @fed_cant decimal(38,6), @fSaldoFact decimal(38,6), @FED_INDICED INT

	
	EXEC SP_DROPTABLE 'AJUSTEVENCEPEND'
	
	CREATE TABLE [dbo].[AJUSTEVENCEPEND] 
	([KAP_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
	[KAP_INDICED_FACT] [int] NULL ,
	[MA_HIJO] [int] NULL ,
	[PID_INDICED] [int] NULL ,
	[KAP_CANTDESC] decimal(38,6) NULL 
	) ON [PRIMARY]


	EXEC SP_DROPTABLE 'AJUSTEVENCEPEND1'
	
	CREATE TABLE [dbo].[AJUSTEVENCEPEND1] 
	([KAP_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
	[KAP_INDICED_FACT] [int] NULL ,
	[MA_HIJO] [int] NULL ,
	[PID_INDICED] [int] NULL ,
	[KAP_CANTDESC] decimal(38,6) NULL 
	) ON [PRIMARY]

	EXEC SP_DROPTABLE 'AJUSTEVENCEPEND2'
	
	CREATE TABLE [dbo].[AJUSTEVENCEPEND2] 
	([KAP_CODIGO] [int] IDENTITY (1, 1) NOT NULL ,
	[KAP_INDICED_FACT] [int] NULL ,
	[MA_HIJO] [int] NULL ,
	[PID_INDICED] [int] NULL ,
	[KAP_CANTDESC] decimal(38,6) NULL 
	) ON [PRIMARY]


		SELECT @CONSECUTIVO=ISNULL(MAX(KAP_CODIGO),0)+1 FROM KARDESPED
		DBCC CHECKIDENT (AJUSTEVENCEPEND, RESEED, @CONSECUTIVO) WITH NO_INFOMSGS


	exec sp_droptable 'TEMP_RETRABAJO'
	exec SP_GENERATEMP_RETRABAJO


--		SELECT @CONSECUTIVO=ISNULL(MAX(re_indicer),0)+1 FROM retrabajo
		DBCC CHECKIDENT (TEMP_RETRABAJO, RESEED, 1) WITH NO_INFOMSGS
	



	-- GENERACION DE LA TABLA RELGENERICOFED (los fed_indiced que no se pueden usar porque ya tienen el grupo)
	EXEC SP_DROPTABLE 'RELGENERICOFED'

	SELECT     dbo.MAESTRO.MA_GENERICO, dbo.KARDESPED.KAP_INDICED_FACT, dbo.FACTEXP.FE_FECHA
	INTO dbo.RELGENERICOFED
	FROM         dbo.KARDESPED INNER JOIN
	                      dbo.MAESTRO ON dbo.KARDESPED.MA_HIJO = dbo.MAESTRO.MA_CODIGO INNER JOIN
	                      dbo.FACTEXPDET ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED INNER JOIN
	                      dbo.FACTEXP ON dbo.KARDESPED.KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO
	WHERE     (dbo.MAESTRO.TI_CODIGO IN
	                          (SELECT     TI_CODIGO
	                            FROM          CONFIGURATIPO
	                            WHERE      CFT_TIPO = 'P' OR
	                                                   CFT_TIPO = 'S')) AND
	dbo.MAESTRO.MA_GENERICO IN
	(SELECT     TOP 100 PERCENT MA_GENERICO
		FROM         dbo.PIDescarga
		WHERE     (PI_ACTIVOFIJO = 'N') AND 
		          (PID_SALDOGEN > 0)
		GROUP BY MA_GENERICO)
	GROUP BY dbo.MAESTRO.MA_GENERICO, dbo.KARDESPED.KAP_INDICED_FACT, dbo.FACTEXP.FE_FECHA


	
-- los mayores a 5
declare cur_ajustavence cursor for
	SELECT     TOP 100 PERCENT PID_SALDOGEN, PID_INDICED, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, PID_FECHAVENCE
	FROM         dbo.PIDescarga
	WHERE     (PI_ACTIVOFIJO = 'N') AND 
	          (PID_SALDOGEN > 0) 
	ORDER BY PID_SALDOGEN, pid_fechavence

open cur_ajustavence

	FETCH NEXT FROM cur_ajustavence INTO @RestaDescargar, @PID_INDICED, @MA_CODIGO, @MA_GENERICO, @PI_FEC_ENT, @PID_FECHAVENCE

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

			declare cur_ajustafactsinDescargar cursor for		
				SELECT dbo.FACTEXPDET.FED_INDICED
				FROM         dbo.FACTEXPDET INNER JOIN
				                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO LEFT OUTER JOIN
				                      dbo.CONFIGURATFACT ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO
				WHERE     dbo.FACTEXP.FE_FECHA < @PID_FECHAVENCE AND dbo.FACTEXP.FE_FECHA >= @PI_FEC_ENT
				            AND dbo.FACTEXP.FE_DESCARGADA='N' AND dbo.FACTEXP.FE_CANCELADO='N'
					    AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = 'A') 
					AND (dbo.FACTEXP.TQ_CODIGO = 3 OR
				                      dbo.FACTEXP.TQ_CODIGO = 12) 
					AND dbo.FACTEXPDET.FED_INDICED IN (SELECT     dbo.FACTEXPDET.FED_INDICED
									FROM         dbo.FACTEXPDET INNER JOIN
									                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
									WHERE     (dbo.FACTEXPDET.TI_CODIGO IN
									                          (SELECT     TI_CODIGO
									                            FROM          CONFIGURATIPO									                            WHERE      CFT_TIPO = 'P' OR
									                                                   CFT_TIPO = 'S')) AND 
									                      dbo.FACTEXP.FE_FECHA >= @PI_FEC_ENT and dbo.FACTEXPDET.FED_CANT >0)
				group by dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
				ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
			open cur_ajustafactsinDescargar
			
				FETCH NEXT FROM cur_ajustafactsinDescargar INTO @FED_INDICED
			
				WHILE (@@FETCH_STATUS = 0) 
				BEGIN
	
					select @fed_cant=fed_cant from factexpdet where fed_indiced=@FED_INDICED
	
	
						if @RestaDescargar>0
						begin
							if @fed_cant>=@RestaDescargar
							begin
								set @fQtyADescargar=@RestaDescargar
								set @RestaDescargar=0
							end
							
							if @fed_cant<@RestaDescargar
							begin
								set @fQtyADescargar=@fed_cant
								set @RestaDescargar=@RestaDescargar-@fed_cant
	
							end
	
							if @fQtyADescargar>0
							INSERT INTO AJUSTEVENCEPEND (KAP_INDICED_FACT, MA_HIJO, PID_INDICED, KAP_CANTDESC)
							VALUES (@FED_INDICED, @MA_CODIGO, @PID_INDICED, @fQtyADescargar)
	
						end
	
						if @RestaDescargar=0
						break
	
	
				FETCH NEXT FROM cur_ajustafactsinDescargar INTO @FED_INDICED
	
				END
				
				CLOSE cur_ajustafactsinDescargar
				DEALLOCATE cur_ajustafactsinDescargar
	
	
				UPDATE PIDESCARGA
				SET PID_SALDOGEN=PID_SALDOGEN-isnull((SELECT SUM(isnull(KAP_CANTDESC,0)) FROM AJUSTEVENCEPEND WHERE PID_INDICED=PIDESCARGA.PID_INDICED),0)
				WHERE PID_INDICED=	@PID_INDICED


/*==================================================== se va con las facturas ya descargadas ===================================================================*/

	SELECT @RestaDescargar=PID_SALDOGEN
	FROM PIDescarga
	WHERE PID_INDICED=@PID_INDICED

		declare cur_ajustafactIncluyeGen cursor for		
			SELECT dbo.KARDESPED.KAP_INDICED_FACT
			FROM         dbo.KARDESPED INNER JOIN
			                      dbo.FACTEXP ON dbo.KARDESPED.KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO
			WHERE     dbo.FACTEXP.FE_FECHA < @PID_FECHAVENCE AND dbo.FACTEXP.FE_FECHA >= @PI_FEC_ENT
				AND (dbo.FACTEXP.TQ_CODIGO = 3 OR
			                      dbo.FACTEXP.TQ_CODIGO = 12) 
				AND KAP_INDICED_FACT IN (SELECT     dbo.FACTEXPDET.FED_INDICED
								FROM         dbo.FACTEXPDET INNER JOIN
								                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
								WHERE     (dbo.FACTEXPDET.TI_CODIGO IN
								                          (SELECT     TI_CODIGO
								                            FROM          CONFIGURATIPO
								                            WHERE      CFT_TIPO = 'P' OR
								                                                   CFT_TIPO = 'S')) AND 
								                      dbo.FACTEXP.FE_FECHA >= @PI_FEC_ENT and dbo.FACTEXPDET.FED_CANT >0)
				/* excluyendo las facturas que ya contienen el generico */
				AND dbo.KARDESPED.KAP_INDICED_FACT NOT IN (SELECT KARDESPED_1.KAP_INDICED_FACT FROM RELGENERICOFED KARDESPED_1  
											WHERE KARDESPED_1.MA_GENERICO = @ma_generico AND KARDESPED_1.FE_FECHA < @PID_FECHAVENCE AND KARDESPED_1.FE_FECHA >= @PI_FEC_ENT
										         GROUP BY KARDESPED_1.KAP_INDICED_FACT)
/*			AND KAP_INDICED_FACT IN (SELECT FED_INDICED FROM FACTEXPDET INNER JOIN FACTEXP ON FACTEXPDET.FE_CODIGO=FACTEXP.FE_CODIGO
			WHERE (FED_NOMBRE LIKE '%BAJO%' OR FED_NOMBRE LIKE '%GUITARRA%')  AND dbo.FACTEXP.FE_FECHA < @PID_FECHAVENCE AND dbo.FACTEXP.FE_FECHA >= @PI_FEC_ENT AND TI_CODIGO =14)	*/
			group by dbo.KARDESPED.KAP_INDICED_FACT, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
			ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
		open cur_ajustafactIncluyeGen
		
			FETCH NEXT FROM cur_ajustafactIncluyeGen INTO @KAP_INDICED_FACT
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN

				select @fed_cant=fed_cant from factexpdet where fed_indiced=@KAP_INDICED_FACT


					if @RestaDescargar>0
					begin
						/*Aqui manipulamos las cantidades*/

						if @fed_cant>=@RestaDescargar
						begin
							set @fQtyADescargar=@RestaDescargar
							set @RestaDescargar=0
						end
						
						if @fed_cant<@RestaDescargar
						begin
							set @fQtyADescargar=@fed_cant
							set @RestaDescargar=@RestaDescargar-@fed_cant

						end

						if @fQtyADescargar>0
						INSERT INTO AJUSTEVENCEPEND1 (KAP_INDICED_FACT, MA_HIJO, PID_INDICED, KAP_CANTDESC)
						VALUES (@KAP_INDICED_FACT, @MA_CODIGO, @PID_INDICED, @fQtyADescargar)

					end

					if @RestaDescargar=0
					break


			FETCH NEXT FROM cur_ajustafactIncluyeGen INTO @KAP_INDICED_FACT

			END
			
			CLOSE cur_ajustafactIncluyeGen
			DEALLOCATE cur_ajustafactIncluyeGen


			UPDATE PIDESCARGA
			SET PID_SALDOGEN=PID_SALDOGEN-isnull((SELECT SUM(isnull(KAP_CANTDESC,0)) FROM AJUSTEVENCEPEND1 WHERE PID_INDICED=PIDESCARGA.PID_INDICED),0)
			WHERE PID_INDICED=	@PID_INDICED


/*==================================================== se va con las facturas ya descargadas que inclyen o no el generico ===================================================================*/
	SELECT @RestaDescargar=PID_SALDOGEN
	FROM PIDescarga
	WHERE PID_INDICED=@PID_INDICED

		declare cur_ajustafactNoIncluyeGen cursor for		
			SELECT dbo.KARDESPED.KAP_INDICED_FACT
			FROM         dbo.KARDESPED INNER JOIN
			                      dbo.FACTEXP ON dbo.KARDESPED.KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO
			WHERE     dbo.FACTEXP.FE_FECHA < @PID_FECHAVENCE AND dbo.FACTEXP.FE_FECHA >= @PI_FEC_ENT
				AND (dbo.FACTEXP.TQ_CODIGO = 3 OR
			                      dbo.FACTEXP.TQ_CODIGO = 12) 
				AND KAP_INDICED_FACT IN (SELECT     dbo.FACTEXPDET.FED_INDICED
								FROM         dbo.FACTEXPDET INNER JOIN
								                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
								WHERE     (dbo.FACTEXPDET.TI_CODIGO IN
								                          (SELECT     TI_CODIGO
								                            FROM          CONFIGURATIPO								                            WHERE      CFT_TIPO = 'P' OR
								                                                   CFT_TIPO = 'S')) AND 
								                      dbo.FACTEXP.FE_FECHA >= @PI_FEC_ENT and dbo.FACTEXPDET.FED_CANT >0)
			group by dbo.KARDESPED.KAP_INDICED_FACT, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
			ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO
		open cur_ajustafactNoIncluyeGen
		
			FETCH NEXT FROM cur_ajustafactNoIncluyeGen INTO @KAP_INDICED_FACT
		
			WHILE (@@FETCH_STATUS = 0) 
			BEGIN

				select @fed_cant=fed_cant from factexpdet where fed_indiced=@KAP_INDICED_FACT


					if @RestaDescargar>0
					begin

						if @fed_cant>=@RestaDescargar
						begin
							set @fQtyADescargar=@RestaDescargar
							set @RestaDescargar=0
						end
						
						if @fed_cant<@RestaDescargar
						begin
							set @fQtyADescargar=@fed_cant
							set @RestaDescargar=@RestaDescargar-@fed_cant

						end

						if @fQtyADescargar>0
						INSERT INTO AJUSTEVENCEPEND2 (KAP_INDICED_FACT, MA_HIJO, PID_INDICED, KAP_CANTDESC)
						VALUES (@KAP_INDICED_FACT, @MA_CODIGO, @PID_INDICED, @fQtyADescargar)

					end

					if @RestaDescargar=0
					break


			FETCH NEXT FROM cur_ajustafactNoIncluyeGen INTO @KAP_INDICED_FACT

			END
			
			CLOSE cur_ajustafactNoIncluyeGen
			DEALLOCATE cur_ajustafactNoIncluyeGen


			UPDATE PIDESCARGA
			SET PID_SALDOGEN=PID_SALDOGEN-isnull((SELECT SUM(isnull(KAP_CANTDESC,0)) FROM AJUSTEVENCEPEND2 WHERE PID_INDICED=PIDESCARGA.PID_INDICED),0)
			WHERE PID_INDICED=	@PID_INDICED


	FETCH NEXT FROM cur_ajustavence INTO @RestaDescargar, @PID_INDICED, @MA_CODIGO, @MA_GENERICO, @PI_FEC_ENT, @PID_FECHAVENCE

END

CLOSE cur_ajustavence
DEALLOCATE cur_ajustavence



		INSERT INTO TEMP_RETRABAJO (TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
					        TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES)
				
		SELECT     'F', (SELECT FE_CODIGO FROM FACTEXPDET WHERE FED_INDICED=KAP_INDICED_FACT), KAP_INDICED_FACT, MA_HIJO, (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
		(SELECT MA_NOMBRE FROM MAESTRO WHERE MA_CODIGO=MA_HIJO), (SELECT MA_NAME FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
		KAP_CANTDESC, (SELECT TI_CODIGO FROM MAESTRO WHERE MA_CODIGO=MA_HIJO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
		(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=MA_HIJO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
		KAP_CANTDESC, 1, 'N'
		FROM AJUSTEVENCEPEND


		if exists (select * from AJUSTEVENCEPEND1)
		begin
			INSERT INTO TEMP_RETRABAJO (TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
						        TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES)
					
			SELECT     'F', (SELECT FE_CODIGO FROM FACTEXPDET WHERE FED_INDICED=KAP_INDICED_FACT), KAP_INDICED_FACT, MA_HIJO, (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
			(SELECT MA_NOMBRE FROM MAESTRO WHERE MA_CODIGO=MA_HIJO), (SELECT MA_NAME FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
			KAP_CANTDESC, (SELECT TI_CODIGO FROM MAESTRO WHERE MA_CODIGO=MA_HIJO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
			(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=MA_HIJO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
			KAP_CANTDESC, 1, 'N'
			FROM AJUSTEVENCEPEND1
		end

		if exists (select * from AJUSTEVENCEPEND2)
		begin
			INSERT INTO TEMP_RETRABAJO (TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
						        TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES)
					
			SELECT     'F', (SELECT FE_CODIGO FROM FACTEXPDET WHERE FED_INDICED=KAP_INDICED_FACT), KAP_INDICED_FACT, MA_HIJO, (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
			(SELECT MA_NOMBRE FROM MAESTRO WHERE MA_CODIGO=MA_HIJO), (SELECT MA_NAME FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
			KAP_CANTDESC, (SELECT TI_CODIGO FROM MAESTRO WHERE MA_CODIGO=MA_HIJO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
			(SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO=MA_HIJO), (SELECT ME_COM FROM MAESTRO WHERE MA_CODIGO=MA_HIJO),
			KAP_CANTDESC, 1, 'N'
			FROM AJUSTEVENCEPEND2
		end



	UPDATE FACTEXPDET
	SET FED_RETRABAJO='A'
	WHERE FED_INDICED IN (SELECT FETR_INDICED FROM TEMP_RETRABAJO) AND
	 FED_RETRABAJO<>'A'


		-- insercion a kardesped
		INSERT INTO KARDESPED(KAP_CODIGO, KAP_INDICED_PED, MA_HIJO, KAP_CANTDESC, KAP_INDICED_FACT, KAP_TIPO_DESC, KAP_CantTotADescargar, KAP_Saldo_FED)
		SELECT KAP_CODIGO, PID_INDICED, MA_HIJO, KAP_CANTDESC, KAP_INDICED_FACT, (SELECT MAX(KAP_TIPO_DESC) FROM KARDESPED WHERE KAP_INDICED_FACT=KAP_INDICED_FACT), KAP_CANTDESC, 0
		FROM AJUSTEVENCEPEND


		INSERT INTO KARDESPED(KAP_CODIGO, KAP_INDICED_PED, MA_HIJO, KAP_CANTDESC, KAP_INDICED_FACT, KAP_TIPO_DESC, KAP_CantTotADescargar, KAP_Saldo_FED)
		SELECT KAP_CODIGO+(select max(kap_codigo) from KARDESPED), PID_INDICED, MA_HIJO, KAP_CANTDESC, KAP_INDICED_FACT, (SELECT MAX(KAP_TIPO_DESC) FROM KARDESPED WHERE KAP_INDICED_FACT=KAP_INDICED_FACT), KAP_CANTDESC, 0
		FROM AJUSTEVENCEPEND1

		INSERT INTO KARDESPED(KAP_CODIGO, KAP_INDICED_PED, MA_HIJO, KAP_CANTDESC, KAP_INDICED_FACT, KAP_TIPO_DESC, KAP_CantTotADescargar, KAP_Saldo_FED)
		SELECT KAP_CODIGO+(select max(kap_codigo) from KARDESPED), PID_INDICED, MA_HIJO, KAP_CANTDESC, KAP_INDICED_FACT, (SELECT MAX(KAP_TIPO_DESC) FROM KARDESPED WHERE KAP_INDICED_FACT=KAP_INDICED_FACT), KAP_CANTDESC, 0
		FROM AJUSTEVENCEPEND2


		UPDATE KARDESPED
		SET KAP_FACTRANS=(SELECT FE_CODIGO FROM FACTEXPDET WHERE FED_INDICED=KAP_INDICED_FACT)
		WHERE KAP_FACTRANS<>(SELECT FE_CODIGO FROM FACTEXPDET WHERE FED_INDICED=KAP_INDICED_FACT)
		OR KAP_FACTRANS IS NULL


	-- insert a la tabla de retrabajo
		-- inserta a la tabla de temp_retrabajo lo que ya existe en retrabajo con el fin de hacer una agrupacion y no se repita la llave primaria
		INSERT INTO TEMP_RETRABAJO(TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, 
		                      RE_INCORPOR, TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES)
	
		SELECT     TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR, TI_HIJO, 
		                      ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES
		FROM         RETRABAJO
		WHERE     (TIPO_FACTRANS = 'F') 

		-- los borra de la tabla de retrabajo
		DELETE FROM RETRABAJO WHERE TIPO_FACTRANS = 'F' AND (FETR_INDICED IN
		                          (SELECT     FETR_INDICED
		                            FROM          TEMP_RETRABAJO))

	-- los inserta pero ya agrupados
	INSERT INTO RETRABAJO(RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, 
	                      RE_INCORPOR, TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES)
	
	SELECT     MAX(RE_INDICER), TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, MAX(RE_NOPARTE), MAX(RE_NOMBRE), MAX(RE_NAME), 
	                      SUM(RE_INCORPOR), MAX(TI_HIJO), MAX(ME_CODIGO), MAX(MA_GENERICO), MAX(ME_GEN), SUM(RE_INCORPORGEN), MAX(FACTCONV), 
	                      FETR_RETRABAJODES
	FROM         TEMP_RETRABAJO	GROUP BY TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, FETR_RETRABAJODES


	UPDATE dbo.FACTEXP
	SET     FE_FECHADESCARGA=GETDATE(),
		FE_DESCARGADA='S'
	FROM         dbo.FACTEXP
	WHERE     (FE_FECHADESCARGA IS NULL) AND (FE_CODIGO IN
	                          (SELECT     KAP_FACTRANS
	                            FROM          KARDESPED
	                            GROUP BY KAP_FACTRANS))

	EXEC SP_DROPTABLE 'AJUSTEVENCEPEND'
	EXEC SP_DROPTABLE 'AJUSTEVENCEPEND1'
	EXEC SP_DROPTABLE 'AJUSTEVENCEPEND2'

GO
