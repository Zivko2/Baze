SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_FILL_BOM_DESCTEMPFisCompEspecial] (@FED_INDICED INT, @BST_PT Int, @BST_ENTRAVIGOR DateTime, @FED_CANT decimal(38,6), @CODIGOFACTURA INT, @MENSAJE1 char(1)='N' output)   as

SET NOCOUNT ON 
declare @BST_HIJO int, @BST_INCORPOR decimal(38,6), @BST_PERINI datetime, @BST_PERINI2 datetime, @ma_struct int, @fed_tip_ens char(1), @TEmbarque char(1),
    @BST_TIPODESC varchar(5), @ME_GEN INT, @usoFinalIncluido decimal(38,6), @saldoactual decimal(38,6), @usoFinal decimal(38,6), @CantAlcanza decimal(38,6), @CantaExplosionar decimal(38,6),
@saldoUsable decimal(38,6), @Sumcantidadusofinal decimal(38,6), @FACTCONV decimal(38,6)
	--exec sp_CreaBOM_DESCTEMP

set @MENSAJE1='N'




	SELECT     @TEmbarque = CFQ_TIPO
	FROM CONFIGURATEMBARQUE 
	WHERE TQ_CODIGO IN (SELECT TQ_CODIGO FROM FACTEXP WHERE FE_CODIGO=@CODIGOFACTURA)


	if @TEmbarque='D'
	set @BST_TIPODESC='D'
	else 
	set @BST_TIPODESC='N'
	






		/* explosion de subensambles */
		declare CUR_BOMSTRUCT cursor for
			SELECT     dbo.BOM_STRUCT.BST_HIJO, sum(BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.FACTCONV
			FROM         dbo.BOM_STRUCT 
				LEFT OUTER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO 
				LEFT OUTER JOIN dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO 
				LEFT OUTER JOIN dbo.MAESTROREFER ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTROREFER.MA_CODIGO 
				LEFT OUTER JOIN dbo.CONFIGURATIPO CONFIGURATIPO2 ON dbo.MAESTROREFER.TI_CODIGO = CONFIGURATIPO2.TI_CODIGO
			WHERE   (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
				AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <= @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
				AND (ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'P' OR ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'S') 
				AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'C') AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'P')
				AND dbo.BOM_STRUCT.BST_INCORPOR >0
			GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.FACTCONV
		
		 OPEN CUR_BOMSTRUCT
		
		
			FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR, @BST_PERINI, @ME_GEN, @FACTCONV
			
		
		  WHILE (@@fetch_status = 0) 
		
		  BEGIN  
		
	
				if not exists(select ma_codigo from ##VPIDescarga where ma_codigo=@BST_HIJO) 
					--exec  SP_FILL_BOM_DESCTEMPFisComp1 @FED_INDICED, @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR, @BST_PERINI, 
					--@FED_CANT, @CODIGOFACTURA, @BST_INCORPOR, 1, @FACTCONV, @mensaje=@MENSAJE1 output
							insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
							   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR)
							values(@BST_HIJO, @BST_INCORPOR, 'S', 'R', @FACTCONV, @ME_GEN, 'C', @FED_CANT, @CODIGOFACTURA, null,
							@BST_TIPODESC, @BST_PT, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR)
				else
				begin			
					select @Sumcantidadusofinal=round(sum(isnull(bst_cantidadusofinal,0)),6) from ##TempFiscComp where bsu_subensamble=@BST_HIJO
	
					if @Sumcantidadusofinal is null	
					set @Sumcantidadusofinal=0
	
					set @usoFinal = round(@BST_INCORPOR*@FACTCONV*@FED_CANT,6)
	
					set @usoFinalIncluido=@Sumcantidadusofinal+@usoFinal
		
					select @saldoactual=round(sum(pid_saldogen),6) from ##VPIDescarga where ma_codigo=@BST_HIJO
	
					if @saldoactual is null
					set @saldoactual=0
					
			
					if @saldoactual=@usoFinalIncluido
					begin
						insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
						   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR)
						values(@BST_HIJO, @BST_INCORPOR, 'S', 'R', @FACTCONV, @ME_GEN, 'C', @FED_CANT, @CODIGOFACTURA, 1,
						@BST_TIPODESC, @BST_PT, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR)
	
						insert into ##TempFiscComp(bsu_subensamble, bst_cantidadusofinal)
						values(@BST_HIJO, @usoFinal)
					end
					else
					begin
	
		
						if @usoFinalIncluido<=@saldoactual
						begin
							insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
							   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR)
							values(@BST_HIJO, @BST_INCORPOR, 'S', 'R', @FACTCONV, @ME_GEN, 'C', @FED_CANT, @CODIGOFACTURA, 1,
							@BST_TIPODESC, @BST_PT, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR)
		
		
							insert into ##TempFiscComp(bsu_subensamble, bst_cantidadusofinal)
							values(@BST_HIJO, @usoFinal)
						end
						else
						begin
	
	
							select @saldoUsable=round(@saldoactual-@Sumcantidadusofinal,6)
	

							select @CantAlcanza = round(@saldoUsable/(@BST_INCORPOR*@FACTCONV),6)

						
							--select @CantaExplosionar = round(@FED_CANT-(@CantAlcanza),6)

							select @CantaExplosionar = round(@usoFinal-(@saldoUsable),6)/@FACTCONV/@BST_INCORPOR
		
							insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
							   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR)
							values(@BST_HIJO, @BST_INCORPOR, 'S', 'R', @FACTCONV, @ME_GEN, 'C', @CantAlcanza, @CODIGOFACTURA, 1,
							@BST_TIPODESC, @BST_PT, @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR)
		
		
							insert into ##TempFiscComp(bsu_subensamble, bst_cantidadusofinal)
							values(@BST_HIJO, @saldoUsable)
		
		
							--exec  SP_FILL_BOM_DESCTEMPFisComp1 @FED_INDICED, @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR, @BST_PERINI, 
							--@CantaExplosionar, @CODIGOFACTURA, @BST_INCORPOR, 1, @FACTCONV, @mensaje=@MENSAJE1 output
						end
		
					end
	
				end
	
	
				if @MENSAJE1='S'
				begin				
					break
				end
		
		
			FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR, @BST_PERINI, @ME_GEN, @FACTCONV
		END
		
		CLOSE CUR_BOMSTRUCT
		DEALLOCATE CUR_BOMSTRUCT



GO
