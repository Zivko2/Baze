SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_FILL_BOM_DESCTEMPFisComp1] (@FED_INDICED INT, @BST_PT INT, @BST_HIJO INT, @BST_ENTRAVIGOR DATETIME, @BST_PERINI DATETIME, @FED_CANT decimal(38,6), @CODIGOFACTURA INT, @BST_INCORPORAcum decimal(38,6), @nivel int, @FACTCONV1 decimal(38,6), @mensaje char(1) output)   as

SET NOCOUNT ON 
declare @BST_HIJO1 int, @BST_INCORPOR decimal(38,6), @BST_PERINI1 datetime, @nivelr int, @BST_TIPODESC VARCHAR(5), @incorporacionfinal decimal(38,6),@TEmbarque char(1),
@ME_GEN INT, @usoFinalIncluido decimal(38,6), @saldoactual decimal(38,6), @usoFinal decimal(38,6), @CantAlcanza decimal(38,6), @CantaExplosionar decimal(38,6), @Sumcantidadusofinal decimal(38,6),
@saldoUsable decimal(38,6), @MA_PESO_KG decimal(38,6), @FACTCONV decimal(38,6)


	SET @nivelr=@nivel+1

	SELECT     @TEmbarque = CFQ_TIPO
	FROM CONFIGURATEMBARQUE 
	WHERE TQ_CODIGO IN (SELECT TQ_CODIGO FROM FACTEXP WHERE FE_CODIGO=@CODIGOFACTURA)


	if @TEmbarque='D'
	set @BST_TIPODESC='D'
	else 
	set @BST_TIPODESC='N'
	

			/*if @BST_HIJO=2287
			begin
				print '---'
				print @BST_INCORPORAcum
				print @FED_CANT
				print @FACTCONV1

			end*/
			-- si no tiene componentes mp no se inserta, ya que no se requiere que se explosione, y de los subensambles se hace su verificacion con el proceso que sigue
			if exists (SELECT     dbo.BOM_STRUCT.BST_HIJO
			FROM         dbo.BOM_STRUCT 
			WHERE   (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_HIJO) 
				AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR) 
				AND (dbo.BOM_STRUCT.BST_DISCH = 'S') AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL 
				AND (dbo.BOM_STRUCT.BST_INCORPOR) >0
			GROUP BY dbo.BOM_STRUCT.BST_HIJO)

		
			insert into ##TempSubExplosiona (bsu_subensamble, bst_incorpor, fed_fecha_struct, fed_indiced, fe_codigo, fed_cant, eq_gen)
			values(@BST_HIJO, @BST_INCORPORAcum, @BST_ENTRAVIGOR, @FED_INDICED, @CODIGOFACTURA, @FED_CANT, @FACTCONV1)


		DECLARE @CursorVar CURSOR
		
		SET @CursorVar = CURSOR SCROLL DYNAMIC FOR
			SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.ME_GEN,
				    max(isnull(dbo.MAESTRO.MA_PESO_KG,dbo.MAESTROREFER.MA_PESO_KG)), dbo.BOM_STRUCT.FACTCONV
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN 
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO 
					LEFT OUTER JOIN dbo.MAESTROREFER ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO CONFIGURATIPO2 ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPO2.TI_CODIGO
			WHERE   (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_HIJO) 
				AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR) 
				AND (ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'P' OR ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'S') 
				AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'C') AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'P')
				AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL 
				AND (dbo.BOM_STRUCT.BST_INCORPOR) >0
			GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.FACTCONV
		
		 OPEN @CursorVar
		  FETCH NEXT FROM @CursorVar INTO @BST_HIJO1, @BST_INCORPOR, @BST_PERINI1, @ME_GEN, @MA_PESO_KG, @FACTCONV
		
		  WHILE (@@fetch_status = 0) 
		  BEGIN  
		
			set @incorporacionfinal=@BST_INCORPOR* @BST_INCORPORAcum
	
		
				
				if @@NESTLEVEL <31
				begin
		
					if not exists(select ma_codigo from ##VPIDescarga where ma_codigo=@BST_HIJO1) 
					begin
						exec  SP_FILL_BOM_DESCTEMPFisComp1 @FED_INDICED, @BST_PT, @BST_HIJO1, @BST_ENTRAVIGOR, @BST_PERINI1, 
						@FED_CANT, @CODIGOFACTURA, @incorporacionfinal, @nivelr, @FACTCONV, @mensaje=@mensaje output
		
					end
					else
					begin			
						select @Sumcantidadusofinal=round(sum(isnull(bst_cantidadusofinal,0)),6) from ##TempFiscComp where bsu_subensamble=@BST_HIJO1
		
						if @Sumcantidadusofinal is null	
						set @Sumcantidadusofinal=0
		
						set @usoFinal = round(@incorporacionfinal*@FACTCONV*(@FED_CANT),6)

		
						set @usoFinalIncluido=@Sumcantidadusofinal+@usoFinal
			
						select @saldoactual=round(sum(pid_saldogen),6) from ##VPIDescarga where ma_codigo=@BST_HIJO1
		
						if @saldoactual is null
						set @saldoactual=0
				
						if @saldoactual=@usoFinalIncluido
						begin
							insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
							   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_PESO_KG)
							values(@BST_HIJO1, @incorporacionfinal, 'S', 'S', @FACTCONV, @ME_GEN, 'C', @FED_CANT, @CODIGOFACTURA, @nivelr,
							@BST_TIPODESC, @BST_HIJO, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, @MA_PESO_KG)
		
		
							insert into ##TempFiscComp(bsu_subensamble, bst_cantidadusofinal)
							values(@BST_HIJO1, @usoFinal)
						end
						else
						begin
		
			
							if @usoFinalIncluido<=@saldoactual
							begin
								insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
								   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_PESO_KG)
								values(@BST_HIJO1, @incorporacionfinal, 'S', 'S', @FACTCONV, @ME_GEN, 'C', @FED_CANT, @CODIGOFACTURA, @nivelr,
								@BST_TIPODESC, @BST_HIJO, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, @MA_PESO_KG)
			
			
		
								insert into ##TempFiscComp(bsu_subensamble, bst_cantidadusofinal)
								values(@BST_HIJO1, @usoFinal)
							end
							else
							begin
		

								

		
								select @saldoUsable=round(@saldoactual-@Sumcantidadusofinal,6)


				
		
								select @CantAlcanza = round(@saldoUsable/(@incorporacionfinal*@FACTCONV),6)
			
								
								--select @CantaExplosionar = round(@FED_CANT-(@CantAlcanza),6)
								select @CantaExplosionar = round(@usoFinal-(@saldoUsable),6)/@FACTCONV


			
								insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
								   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_PESO_KG)
								values(@BST_HIJO1, @incorporacionfinal, 'S', 'S', @FACTCONV, @ME_GEN, 'C', @CantAlcanza, @CODIGOFACTURA, @nivelr,
								@BST_TIPODESC, @BST_HIJO, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, @MA_PESO_KG)
			
			
								insert into ##TempFiscComp(bsu_subensamble, bst_cantidadusofinal)
								values(@BST_HIJO1, @saldoUsable)
		
			
								exec  SP_FILL_BOM_DESCTEMPFisComp1 @FED_INDICED, @BST_PT, @BST_HIJO1, @BST_ENTRAVIGOR, @BST_PERINI1, 
								@CantaExplosionar, @CODIGOFACTURA, 1/*@incorporacionfinal*/, @nivelr, @FACTCONV, @mensaje=@mensaje output
		
		
		
							end
			
						end
		
					end
				end
				else
				begin
					set @mensaje='S'
					break
				end
		
		
		
			  FETCH NEXT FROM @CursorVar INTO @BST_HIJO1, @BST_INCORPOR, @BST_PERINI1, @ME_GEN, @MA_PESO_KG, @FACTCONV
		END
			CLOSE @CursorVar
			DEALLOCATE @CursorVar


GO
