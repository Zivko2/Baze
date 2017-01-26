SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_descarga_entsalalm] (@EN_CODIGO int)   as

SET NOCOUNT ON 
declare @END_INDICED int, @END_CANT decimal(38,6), @END_CANTALM decimal(38,6), @MA_HIJO int, @BST_INCORPOR decimal(38,6), @Factconv decimal(28,14), 
	@BST_TIPODESC char(1), @ALM_ORIGEN int, @ALM_DESTINO int, @ME_GEN int, @end_noorden varchar(25),
	@end_ord_comp varchar(25), @end_lote varchar(25), @fi_folio varchar(25), @cl_codigo int, @ot_codigo int
/*
DECLARE @FECHAHOY datetime, @TM_ALMACENES char(1), @QtyADescargar decimal(38,6), @ENDSALDOGEN decimal(38,6), 
@QtyTotDesc decimal(38,6), @en_fecha datetime, @SaldoDescargar decimal(38,6), @ENDINDICED int, @SaldoAlmacen decimal(38,6), @CFM_TIPO varchar(2),
@SUMKAP_CANTDESC decimal(38,6), @QtyASumar decimal(38,6), @SaldoTotal decimal(38,6), @SaldoxSumar decimal(38,6), @CF_TIPODESCALM CHAR(1),
@CF_CTRLLOCPRODUC char(1), @ALMD_ORIGEN INT, @cft_tipo char(1), @QtyADescargar1 decimal(38,6),
@QtyTotDesc1 decimal(38,6), @SaldoDescargar1 decimal(38,6), @OTDINDICED int, @OTDSALDOGEN decimal(38,6), @SaldoOrdTrabajo decimal(38,6),
@OT_FOLIO varchar(25), @PD_FOLIO VARCHAR(25), @END_CANTEMP decimal(38,6), @FALM_CORTO VARCHAR(30), @MA_CANTXEMP decimal(38,6),
@ALMD_PASILLO varchar(50), @ALMD_NIVEL varchar(15), @ALMD_LOCALIDAD varchar(150), @LOCALIDAD varchar(250),
@END_PASILLO varchar(50), @END_NIVEL varchar(15), @END_LOCALIDAD varchar(150)


	SELECT     @CF_TIPODESCALM=CF_TIPODESCALM, @CF_CTRLLOCPRODUC = CF_CTRLLOCPRODUC
	FROM         dbo.CONFIGURACION
	
	SELECT     @CFM_TIPO= dbo.CONFIGURATMOVIMIENTO.CFM_TIPO
	FROM         dbo.ENTSALALM LEFT OUTER JOIN
	                      dbo.CONFIGURATMOVIMIENTO ON dbo.ENTSALALM.TM_CODIGO = dbo.CONFIGURATMOVIMIENTO.TM_CODIGO
	WHERE dbo.ENTSALALM.EN_CODIGO=@EN_CODIGO


	set @FECHAHOY = convert(datetime, convert(varchar(11), getdate(),101))

	SELECT @TM_ALMACENES=TM_ALMACENES FROM TMOVIMIENTO 
	WHERE TM_CODIGO IN(SELECT TM_CODIGO FROM ENTSALALM WHERE EN_CODIGO=@EN_CODIGO)
	
	SELECT @EN_FECHA= EN_FECHA FROM ENTSALALM WHERE EN_CODIGO=@EN_CODIGO


	if exists(select * from TempBOM_DESCALM WHERE EN_CODIGO=@EN_CODIGO)
	DELETE FROM TempBOM_DESCALM WHERE EN_CODIGO=@EN_CODIGO
		
	EXEC SP_DescExplosionBomAlm @EN_CODIGO





-- ====================== suma =======================



	--se le suma al almacen destino ya sea productos o materias primas
	declare cur_sumalmacen cursor for
		SELECT     ENTSALALMDET.END_INDICED, ENTSALALMDET.END_CANT, ENTSALALMDET.MA_CODIGO, 1 AS BST_INCORPOR, ISNULL(ENTSALALMDET.EQ_ALM, 
		                      1), ENTSALALMDET.END_TIPODESCARGA, ENTSALALM.ALM_ORIGEN, ENTSALALM.ALM_DESTINO, ENTSALALMDET.ME_ALM, 
		                      ENTSALALMDET.END_CANTEMP, FAMILIAALM.FALM_CORTO
		FROM         FAMILIAALM RIGHT OUTER JOIN
		                      ENTSALALMDET ON FAMILIAALM.FALM_CODIGO = ENTSALALMDET.MA_FAMILIA RIGHT OUTER JOIN
		                      ENTSALALM ON ENTSALALMDET.EN_CODIGO = ENTSALALM.EN_CODIGO
		WHERE     (dbo.ENTSALALM.EN_CODIGO = @EN_CODIGO)
		GROUP BY dbo.ENTSALALMDET.END_INDICED, dbo.ENTSALALMDET.MA_CODIGO, dbo.ENTSALALMDET.END_TIPODESCARGA, 
		                      dbo.ENTSALALM.ALM_ORIGEN, dbo.ENTSALALM.ALM_DESTINO, ENTSALALMDET.ME_ALM, 
		                      ISNULL(dbo.ENTSALALMDET.EQ_ALM, 1), dbo.ENTSALALMDET.END_CANT, dbo.ENTSALALMDET.END_CANTEMP, FAMILIAALM.FALM_CORTO
		HAVING      (SUM(dbo.ENTSALALMDET.END_CANT) > 0)
		ORDER BY ENTSALALMDET.END_INDICED
	open cur_sumalmacen

	FETCH NEXT FROM cur_sumalmacen INTO @END_INDICED, @END_CANT, @MA_HIJO, @BST_INCORPOR, @FACTCONV, 
					@BST_TIPODESC, @ALM_ORIGEN, @ALM_DESTINO, @ME_GEN, @END_CANTEMP, @FALM_CORTO

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

		select @cft_tipo=cft_tipo from configuratipo where ti_codigo in (select ti_codigo from maestro where ma_codigo=@MA_HIJO)

		if @CFM_TIPO='SA' and (@cft_tipo='P' or @cft_tipo='S')
		begin
			SET @QtyADescargar1 = @END_CANT  * @FACTCONV
			SET @QtyTotDesc1 = @QtyADescargar1
			SET @SaldoDescargar1 = @QtyTotDesc1
		end


		
				-- en este tipo de movimiento se usan A=ambos almacenes o solo D=destino
				if  @TM_ALMACENES='A' or @TM_ALMACENES='D'
				begin --1A
		
					SET @QtyASumar = @END_CANT * @FACTCONV
					SET @SaldoxSumar = @QtyASumar
				
			
			
	--				if @CFM_TIPO='LC' and @CF_CTRLLOCPRODUC='S'
	
					IF (SELECT ALM_USALOCALIDAD FROM ALMACEN WHERE ALM_CODIGO=@ALM_DESTINO)='S'
					begin

						set @MA_CANTXEMP= (SELECT MA_CANTXEMP FROM FAMILIAALMDET WHERE MA_CODIGO = @MA_HIJO)

						if (@MA_CANTXEMP > 0)
						DECLARE curAlmDestino CURSOR FOR 
							SELECT     ALMD_PASILLO, ALMD_NIVEL, ALMD_LOCALIDAD, ALMD_PASILLO+'-'+ALMD_NIVEL+'-'+ALMD_LOCALIDAD
							FROM         ALMACENDET
							WHERE     (ALM_CODIGO = @ALM_DESTINO) AND (FALM_CORTO =@FALM_CORTO)
							ORDER BY ALMD_ORDENLLENADO
						open curAlmDestino
						FETCH NEXT FROM curAlmDestino INTO @ALMD_PASILLO, @ALMD_NIVEL, @ALMD_LOCALIDAD, @LOCALIDAD
						      WHILE (@@fetch_status <> -1)
						      BEGIN  --2A


								IF @SaldoxSumar > 0 and @LOCALIDAD NOT IN
								-- localidades ocupadas
									(SELECT  ENTSALALMSALDO.ALMD_PASILLO+'-'+ENTSALALMSALDO.ALMD_NIVEL+'-'+ENTSALALMSALDO.ALMD_LOCALIDAD
									FROM    ENTSALALMSALDO INNER JOIN
									        ENTSALALM ON ENTSALALMSALDO.EN_CODIGO = ENTSALALM.EN_CODIGO
									WHERE   (ENTSALALMSALDO.ALM_DESTINO =@ALM_DESTINO) AND (ENTSALALMSALDO.END_SALDOALM > 0) )
								BEGIN

	
									IF @LOCALIDAD NOT IN
									(SELECT  ENTSALALMSALDO.ALMD_PASILLO+'-'+ENTSALALMSALDO.ALMD_NIVEL+'-'+ENTSALALMSALDO.ALMD_LOCALIDAD
									FROM    ENTSALALMSALDO  WHERE   ENTSALALMSALDO.END_INDICED =@END_INDICED)
									BEGIN
	
										INSERT INTO ENTSALALMSALDO (EN_CODIGO, END_INDICED, END_SALDOALM, END_USO_SALDO, END_SALDOFE, END_ENUSO, END_CANTALLOCATE, END_USAALLOCATE, 
										                      ALM_ORIGEN, ALM_DESTINO, ALMD_PASILLO, ALMD_NIVEL, ALMD_LOCALIDAD)
										
										VALUES (@EN_CODIGO, @END_INDICED, @MA_CANTXEMP, 'N', @MA_CANTXEMP, 'N', 0, 'N', @ALM_ORIGEN, @ALM_DESTINO, @ALMD_PASILLO, @ALMD_NIVEL, @ALMD_LOCALIDAD)
	
										SET @SaldoxSumar = @SaldoxSumar - @MA_CANTXEMP
									END

								END				
				
				
								FETCH NEXT FROM curAlmDestino INTO @ALMD_PASILLO, @ALMD_NIVEL, @ALMD_LOCALIDAD, @LOCALIDAD
				
							END  --2A
			
						CLOSE curAlmDestino
						DEALLOCATE curAlmDestino


								IF @SaldoxSumar > 0
								INSERT INTO ENTSALALMNOINTEGRA (EN_CODIGO, END_INDICED, END_CANTALMNOINTEGRA)
								VALUES (@EN_CODIGO, @END_INDICED, @SaldoxSumar)
	
					end
					else
					begin
						INSERT INTO ENTSALALMSALDO (EN_CODIGO, END_INDICED, END_SALDOALM, END_USO_SALDO, END_SALDOFE, END_ENUSO, END_CANTALLOCATE, END_USAALLOCATE, 
						                      ALM_ORIGEN, ALM_DESTINO, ALMD_PASILLO, ALMD_NIVEL, ALMD_LOCALIDAD)
						
						VALUES (@EN_CODIGO, @END_INDICED, @QtyASumar, 'N', @QtyASumar, 'N', 0, 'N', @ALM_ORIGEN, @ALM_DESTINO, '', '', '')
					end
			          
				end --1A
		
		
				-- ==================== orden de trabajo ========================
		
				if @CFM_TIPO='SA' and (@cft_tipo='P' or @cft_tipo='S')
				begin --1b
					DECLARE curOrdTrabajoSurt CURSOR FOR 
						SELECT     dbo.ORDTRABAJODET.OTD_INDICED, dbo.ORDTRABAJODET.OTD_SALDOSURT, dbo.ORDTRABAJO.OT_FOLIO, dbo.ORDTRABAJO.OT_CODIGO, 
						                      dbo.PEDIDO.PD_FOLIO
						FROM         dbo.ORDTRABAJO INNER JOIN
						                      dbo.ORDTRABAJODET ON dbo.ORDTRABAJO.OT_CODIGO = dbo.ORDTRABAJODET.OT_CODIGO INNER JOIN
						                      dbo.PEDIDO ON dbo.ORDTRABAJODET.PD_CODIGO = dbo.PEDIDO.PD_CODIGO
						where dbo.ORDTRABAJO.ot_fecha<=@en_fecha and dbo.ORDTRABAJODET.otd_saldosurt>0 and dbo.ORDTRABAJODET.ma_codigo=@MA_HIJO
						order by dbo.ORDTRABAJO.ot_fecha, dbo.ORDTRABAJODET.ot_codigo
		
					open curOrdTrabajoSurt
					FETCH NEXT FROM curOrdTrabajoSurt INTO @OTDINDICED, @OTDSALDOGEN, @OT_FOLIO, @OT_CODIGO, @PD_FOLIO
					      WHILE (@@fetch_status <> -1)
					      BEGIN  --2b
		
		
							SET @QtyADescargar1 = @SaldoDescargar1   --Cantidad a descargar (o descargada)  = salod por descargar
							SET @SaldoOrdTrabajo = ROUND(@OTDSALDOGEN - @QtyADescargar1,6) -- saldo posterior del ped = saldo actual menos cantidad a descargar
		
							IF(@SaldoOrdTrabajo < 0)  -- si saldo posterior es negativo
							BEGIN 
								SET @SaldoDescargar1 = ABS(@SaldoOrdTrabajo) -- cantidad que queda a descargar = al saldo negativo (absoluto)
								SET @QtyADescargar1 =  @OTDSALDOGEN -- cantidad descargada = saldo anterior (porque es lo que le quedaba)
								SET @SaldoOrdTrabajo = 0 --saldo del almacen =0
							END 
							ELSE
							BEGIN 
								SET @SaldoDescargar1 = 0 -- si saldo posterior no es < a cero entonces cant. que queda por descargar igual a cero
							END 
		
								--print 'si entra'
		
								update ordtrabajodet
								set otd_saldosurt=@SaldoOrdTrabajo
								where otd_indiced=@OTDINDICED
								
		
								
								update entsalalmdet
								set otd_indiced=@OTDINDICED, OT_CODIGO=@OT_CODIGO, END_NOORDEN=@OT_FOLIO,
								end_ord_comp=@PD_FOLIO
								where end_indiced=@END_INDICED
		
								select @ot_codigo=ot_codigo from ordtrabajodet where otd_indiced=@OTDINDICED
		
				
								exec SP_ACTUALIZAESTATUSORDTRABAJOSURT @ot_codigo	
				
							FETCH NEXT FROM curOrdTrabajoSurt INTO @OTDINDICED, @OTDSALDOGEN, @OT_FOLIO, @OT_CODIGO, @PD_FOLIO
		
						END  --2b
		    
		
					CLOSE curOrdTrabajoSurt
					DEALLOCATE curOrdTrabajoSurt
				end --1b



	FETCH NEXT FROM cur_sumalmacen INTO @END_INDICED, @END_CANT, @MA_HIJO, @BST_INCORPOR, @FACTCONV, 
					@BST_TIPODESC, @ALM_ORIGEN, @ALM_DESTINO, @ME_GEN, @END_CANTEMP, @FALM_CORTO

	END
		
	CLOSE cur_sumalmacen
	DEALLOCATE cur_sumalmacen




	--=========================== resta ==========================
	
	
		declare cur_descalmacen cursor for
			SELECT     dbo.TempBOM_DESCALM.END_INDICED, dbo.ENTSALALMDET.END_CANT AS FED_CANT, dbo.TempBOM_DESCALM.BST_HIJO, 
			                      SUM(dbo.TempBOM_DESCALM.BST_INCORPOR) AS BST_INCORPOR, isnull(dbo.TempBOM_DESCALM.FACTCONVALM,1),
			                      TempBOM_DESCALM.BST_TIPODESC, dbo.TempBOM_DESCALM.ALM_ORIGEN, dbo.TempBOM_DESCALM.ALM_DESTINO,
				      dbo.TempBOM_DESCALM.ME_ALM, dbo.ENTSALALMDET.END_PASILLO,  dbo.ENTSALALMDET.END_NIVEL, dbo.ENTSALALMDET.END_LOCALIDAD

			FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
			                      dbo.ENTSALALMDET ON MAESTRO_1.MA_CODIGO = dbo.ENTSALALMDET.MA_CODIGO RIGHT OUTER JOIN
			                      dbo.TempBOM_DESCALM LEFT OUTER JOIN
			                      dbo.MAESTRO MAESTRO_2 ON dbo.TempBOM_DESCALM.BST_HIJO = MAESTRO_2.MA_CODIGO ON 
			                      dbo.ENTSALALMDET.END_INDICED = dbo.TempBOM_DESCALM.END_INDICED RIGHT OUTER JOIN
			                      dbo.ENTSALALM ON dbo.TempBOM_DESCALM.EN_CODIGO = dbo.ENTSALALM.EN_CODIGO
			WHERE    (dbo.TempBOM_DESCALM.BST_DISCH = 'S') AND (dbo.TempBOM_DESCALM.EN_CODIGO = @EN_CODIGO) 
			GROUP BY dbo.TempBOM_DESCALM.END_INDICED, dbo.TempBOM_DESCALM.BST_HIJO, dbo.TempBOM_DESCALM.FACTCONVALM, 
			                      dbo.ENTSALALMDET.END_CANT, TempBOM_DESCALM.BST_TIPODESC, dbo.TempBOM_DESCALM.ALM_ORIGEN, dbo.TempBOM_DESCALM.ALM_DESTINO,
					      dbo.TempBOM_DESCALM.ME_ALM, dbo.ENTSALALMDET.END_PASILLO,  dbo.ENTSALALMDET.END_NIVEL, dbo.ENTSALALMDET.END_LOCALIDAD
			HAVING  (SUM(dbo.TempBOM_DESCALM.BST_INCORPOR) > 0) AND (dbo.ENTSALALMDET.END_CANT > 0)
		open cur_descalmacen
	
		FETCH NEXT FROM cur_descalmacen INTO @END_INDICED, @END_CANT, @MA_HIJO, @BST_INCORPOR, @FACTCONV, 
						@BST_TIPODESC, @ALM_ORIGEN, @ALM_DESTINO, @ME_GEN, @END_PASILLO,  @END_NIVEL, @END_LOCALIDAD
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	
	
			-- en este tipo de movimiento se usan A=ambos almacenes o solo O=origen
			if  @TM_ALMACENES='A' or @TM_ALMACENES='O'
			begin --1b
	
				SET @QtyADescargar = @END_CANT * @BST_INCORPOR * @FACTCONV
				SET @QtyTotDesc = @QtyADescargar
				SET @SaldoDescargar = @QtyTotDesc
	
	
				--se le resta al almacen origen
				--if @CFM_TIPO='LC' and @CF_CTRLLOCPRODUC='S'		 LC=MOVIMIENTO DE LOCALIDAD EN PRODUCCION
				IF (SELECT ALM_USALOCALIDAD FROM ALMACEN WHERE ALM_CODIGO=@ALM_DESTINO)='S'				begin
					IF @CF_TIPODESCALM='P'
					begin
						DECLARE curAlmOrigen CURSOR FOR 
							SELECT     dbo.ENTSALALMDET.END_INDICED, dbo.ENTSALALMSALDO.END_SALDOALM
							FROM         dbo.ENTSALALM INNER JOIN
					                      dbo.ENTSALALMDET ON dbo.ENTSALALM.EN_CODIGO = dbo.ENTSALALMDET.EN_CODIGO INNER JOIN
					                      dbo.ENTSALALMSALDO ON dbo.ENTSALALMDET.END_INDICED = dbo.ENTSALALMSALDO.END_INDICED
							where dbo.ENTSALALM.en_fecha<=@en_fecha and dbo.ENTSALALM.alm_destino=@ALM_ORIGEN
							and dbo.ENTSALALMSALDO.END_SALDOALM>0 and dbo.ENTSALALMDET.ma_codigo=@MA_HIJO
							and dbo.ENTSALALMSALDO.ALMD_PASILLO =@END_PASILLO and dbo.ENTSALALMSALDO.ALMD_NIVEL= @END_NIVEL
							and dbo.ENTSALALMSALDO.ALMD_LOCALIDAD = @END_LOCALIDAD
							order by dbo.ENTSALALM.en_fecha desc, dbo.ENTSALALMDET.en_codigo desc
					end
					else
					begin
						DECLARE curAlmOrigen CURSOR FOR 
							SELECT     dbo.ENTSALALMDET.END_INDICED, dbo.ENTSALALMSALDO.END_SALDOALM
							FROM         dbo.ENTSALALM INNER JOIN
					                      dbo.ENTSALALMDET ON dbo.ENTSALALM.EN_CODIGO = dbo.ENTSALALMDET.EN_CODIGO INNER JOIN
					                      dbo.ENTSALALMSALDO ON dbo.ENTSALALMDET.END_INDICED = dbo.ENTSALALMSALDO.END_INDICED
							where dbo.ENTSALALM.en_fecha<=@en_fecha and dbo.ENTSALALM.alm_destino=@ALM_ORIGEN
							and dbo.ENTSALALMSALDO.END_SALDOALM>0 and dbo.ENTSALALMDET.ma_codigo=@MA_HIJO
							and dbo.ENTSALALMSALDO.ALMD_PASILLO =@END_PASILLO and dbo.ENTSALALMSALDO.ALMD_NIVEL= @END_NIVEL
							and dbo.ENTSALALMSALDO.ALMD_LOCALIDAD = @END_LOCALIDAD
							order by dbo.ENTSALALM.en_fecha, dbo.ENTSALALMDET.en_codigo
					end
				end
				else
				begin
					IF @CF_TIPODESCALM='P'
					begin
						DECLARE curAlmOrigen CURSOR FOR 
							SELECT     dbo.ENTSALALMDET.END_INDICED, dbo.ENTSALALMSALDO.END_SALDOALM
							FROM         dbo.ENTSALALM INNER JOIN
					                      dbo.ENTSALALMDET ON dbo.ENTSALALM.EN_CODIGO = dbo.ENTSALALMDET.EN_CODIGO INNER JOIN
					                      dbo.ENTSALALMSALDO ON dbo.ENTSALALMDET.END_INDICED = dbo.ENTSALALMSALDO.END_INDICED
							where dbo.ENTSALALM.en_fecha<=@en_fecha and dbo.ENTSALALM.alm_destino=@ALM_ORIGEN
							and dbo.ENTSALALMSALDO.end_saldoalm>0 and dbo.ENTSALALMDET.ma_codigo=@MA_HIJO
							order by dbo.ENTSALALM.en_fecha desc, dbo.ENTSALALMDET.en_codigo desc
					end
					else
					begin
						DECLARE curAlmOrigen CURSOR FOR 
							SELECT     dbo.ENTSALALMDET.END_INDICED, dbo.ENTSALALMSALDO.END_SALDOALM
							FROM         dbo.ENTSALALM INNER JOIN
					                      dbo.ENTSALALMDET ON dbo.ENTSALALM.EN_CODIGO = dbo.ENTSALALMDET.EN_CODIGO INNER JOIN
					                      dbo.ENTSALALMSALDO ON dbo.ENTSALALMDET.END_INDICED = dbo.ENTSALALMSALDO.END_INDICED
							where dbo.ENTSALALM.en_fecha<=@en_fecha and dbo.ENTSALALM.alm_destino=@ALM_ORIGEN
							and dbo.ENTSALALMSALDO.end_saldoalm>0 and dbo.ENTSALALMDET.ma_codigo=@MA_HIJO
							order by dbo.ENTSALALM.en_fecha, dbo.ENTSALALMDET.en_codigo
					end
				end
				open curAlmOrigen
				FETCH NEXT FROM curAlmOrigen INTO @ENDINDICED, @ENDSALDOGEN
				      WHILE (@@fetch_status <> -1)
				      BEGIN  --2b
						IF(@@fetch_status <> -2)
						BEGIN --3b
		
							select @end_noorden=end_noorden, @end_ord_comp=end_ord_comp, @end_lote=end_lote,
							 @fi_folio=fi_folio, @cl_codigo=cl_codigo from entsalalmdet where end_indiced=@ENDINDICED
		
		
							update entsalalmdet
							set end_noorden=@end_noorden,
							end_ord_comp=@end_ord_comp,
							end_lote=@end_lote,
							fi_folio=@fi_folio,
							cl_codigo=@cl_codigo
							where end_indiced=@END_INDICED
		
		
							SET @QtyADescargar = @SaldoDescargar   --Cantidad a descargar (o descargada)  = salod por descargar
							SET @SaldoAlmacen = ROUND(@ENDSALDOGEN - @QtyADescargar,6) -- saldo posterior del ped = saldo actual menos cantidad a descargar
		
							IF(@SaldoAlmacen < 0)  -- si saldo posterior es negativo
							BEGIN 
								SET @SaldoDescargar = ABS(@SaldoAlmacen) -- cantidad que queda a descargar = al saldo negativo (absoluto)
								SET @QtyADescargar =  @ENDSALDOGEN -- cantidad descargada = saldo anterior (porque es lo que le quedaba)
								SET @SaldoAlmacen = 0 --saldo del almacen =0
							END 
							ELSE
							BEGIN 
								SET @SaldoDescargar = 0 -- si saldo posterior no es < a cero entonces cant. que queda por descargar igual a cero
							END 
		
		
								insert into KARDESALMACEN (KAA_FECHADESC, ALM_CODIGO, KAA_FACTRANS, KAA_INDICED_FACT, 
									KAA_INDICED_PED, MA_HIJO, KAA_TIPO_DESC, EQ_ALM, KAA_TIPO, KAA_CANTDESC, 
									KAA_SALDO_PED, KAA_CantTotADescargar, KAA_SALDO_FED, ME_GENERICO)
			
								values (@FECHAHOY, @ALM_ORIGEN, @EN_CODIGO, @END_INDICED, 
									@ENDINDICED, @MA_HIJO, @BST_TIPODESC, @FACTCONV, 'R', @QtyADescargar, 
									@SaldoAlmacen,  @QtyTotDesc, @SaldoDescargar, @ME_GEN)


							UPDATE ENTSALALM
							SET ALM_SALDOAFECTADO='S'
							FROM ENTSALALM INNER JOIN ENTSALALMSALDO 
							ON ENTSALALM.EN_CODIGO = ENTSALALMSALDO.EN_CODIGO 
							WHERE ENTSALALMSALDO.END_INDICED =@ENDINDICED

			
								
								EXEC sp_SetSaldoAlmacen @ENDINDICED, @SaldoAlmacen
		
		
								IF (@SaldoDescargar = 0) 
									BREAK --Jump out of Almacen Cycle
			
				
							FETCH NEXT FROM curAlmOrigen INTO @ENDINDICED, @ENDSALDOGEN		
							END --3b
		
						END  --2b
		--				CLOSE curAlmOrigen
		
		
			            
						IF (@SaldoDescargar <> 0) 
						BEGIN --4b
		
				
			
							SELECT     @SUMKAP_CANTDESC = isnull(SUM(KAA_CANTDESC),0)
							FROM         KARDESALMACEN
							WHERE    (KAA_INDICED_FACT = @END_INDICED) 
			
					
							IF (@SUMKAP_CANTDESC = 0)
							BEGIN --5b
		
								insert into KARDESALMACEN (KAA_FECHADESC, ALM_CODIGO, KAA_FACTRANS, KAA_INDICED_FACT, 
									MA_HIJO, KAA_TIPO_DESC, KAA_TIPO, KAA_CANTDESC, 
									KAA_CantTotADescargar, KAA_SALDO_FED, ME_GENERICO)
			
		
								values (@FECHAHOY, @ALM_ORIGEN, @EN_CODIGO, @END_INDICED, 
									@MA_HIJO, @BST_TIPODESC, 'R', 0, 
									@QtyTotDesc, @SaldoDescargar, @ME_GEN)
							
							END --5b
						END --4b
		
					CLOSE curAlmOrigen
					DEALLOCATE curAlmOrigen
			end --1b
	
		FETCH NEXT FROM cur_descalmacen INTO @END_INDICED, @END_CANT, @MA_HIJO, @BST_INCORPOR, @FACTCONV, 
						@BST_TIPODESC, @ALM_ORIGEN, @ALM_DESTINO, @ME_GEN, @END_PASILLO,  @END_NIVEL, @END_LOCALIDAD
	
		END --1
		CLOSE cur_descalmacen
		DEALLOCATE cur_descalmacen				
	

	



	UPDATE ENTSALALM
	SET     EN_ESTATUS='C'
	WHERE     (EN_CODIGO = @EN_CODIGO)



*/

GO
