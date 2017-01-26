SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_DescExplosionBomFactExp] (@CodigoFactura Int)    as

SET NOCOUNT ON 

declare @FED_INDICED INT, @BST_PT INT, @FED_CANT decimal(38,6), @FED_FECHA_STRUCT DATETIME, @countbom int, @RETRABAJO char(1),
@incorpor decimal(38,6), @fecha varchar(11), @BST_TIPODESC char(1), @ME_GEN INT, @usoFinalIncluido decimal(38,6), 
@saldoactual decimal(38,6), @usoFinal decimal(38,6), @CantAlcanza decimal(38,6), @CantaExplosionar decimal(38,6), @Sumcantidadusofinal decimal(38,6),
@saldoUsable decimal(38,6), @FED_TIP_ENS char(1), @existe smallint, @nivel smallint, @CFT_TIPO char(1)

	


	if (SELECT  CFQ_TIPO
		FROM CONFIGURATEMBARQUE 
		WHERE TQ_CODIGO IN (SELECT TQ_CODIGO FROM FACTEXP WHERE FE_CODIGO=@CODIGOFACTURA))='D'
	set @BST_TIPODESC='D'
	else 
	set @BST_TIPODESC='N'


	select @fecha=convert(varchar(11),fe_fecha,101) from factexp where fe_codigo=@CodigoFactura




	IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
	   WHERE name = '##TempSubExplosiona'  AND  type = 'U')
	begin
		drop table ##TempSubExplosiona
	end
	
	CREATE TABLE ##TempSubExplosiona (
		[bsu_subensamble] [int] NULL ,
		[bst_incorpor] [decimal](38, 6) NULL ,
		[fed_fecha_struct] [datetime] NULL ,
		[fed_indiced] [int] NULL ,
		[fe_codigo] [int] NULL ,
		[fed_cant] [decimal](38, 6) NULL,
		[eq_gen] [decimal](38, 6) NULL,
		[Nivel] [varchar] (20) NULL 
	) ON [PRIMARY]


	if  (select CF_FISCOMP_EXPDESC from configuracion)<>'S'		
	begin
			
		insert into ##TempSubExplosiona (bsu_subensamble, bst_incorpor, fed_fecha_struct, fed_indiced, fe_codigo, fed_cant, Nivel, eq_gen)
		SELECT    MA_CODIGO, 1, FACTEXPDET.FED_FECHA_STRUCT, FED_INDICED, FACTEXPDET.FE_CODIGO, ROUND(FED_CANT,6), 'B0', 1
		FROM          FACTEXPDET LEFT OUTER JOIN
			        CONFIGURATIPO CONFIGURATIPO_2 ON FACTEXPDET.TI_CODIGO = CONFIGURATIPO_2.TI_CODIGO 
		WHERE FACTEXPDET.FE_CODIGO=@CodigoFactura
			AND (CONFIGURATIPO_2.CFT_TIPO = 'S' OR
		                      CONFIGURATIPO_2.CFT_TIPO = 'P') AND (FACTEXPDET.FED_RETRABAJO = 'N'
			        or FACTEXPDET.FED_RETRABAJO = 'C' or FACTEXPDET.FED_RETRABAJO = 'A')
			AND ((dbo.FACTEXPDET.FED_TIP_ENS = 'A' AND dbo.FACTEXPDET.FED_DISCHARGE='S') OR
				FACTEXPDET.FED_TIP_ENS = 'F' OR FACTEXPDET.FED_TIP_ENS = 'E'or FACTEXPDET.FED_TIP_ENS = 'O') 
			AND (FACTEXPDET.FED_CANT > 0) 
			AND FACTEXPDET.PID_INDICED=-1
				

		set @nivel=1

		-- explosion de primer nivel
		insert into ##TempSubExplosiona (bsu_subensamble, bst_incorpor, fed_fecha_struct, fed_indiced, fe_codigo, fed_cant, Nivel, eq_gen)

		SELECT     bst_hijo, ##TempSubExplosiona.bst_incorpor * (BOM_STRUCT.BST_INCORPOR+
			        (CASE WHEN isnull(MAESTRO.MA_POR_DESP,0)<0 and isnull(MAESTRO.MA_POR_DESP,0)<>0 
				then ((BOM_STRUCT.BST_INCORPOR*MAESTRO.MA_POR_DESP)/100) else 0 end)) AS BST_INCORPOR, 
				fed_fecha_struct, FED_INDICED, FE_CODIGO, FED_CANT, 'B1', FACTCONV
		FROM    ##TempSubExplosiona INNER JOIN
              		BOM_STRUCT ON ##TempSubExplosiona.bsu_subensamble = BOM_STRUCT.BSU_SUBENSAMBLE AND
		                      BOM_STRUCT.BST_PERINI <= ##TempSubExplosiona.fed_fecha_struct AND 
		                      BOM_STRUCT.BST_PERFIN >= ##TempSubExplosiona.fed_fecha_struct LEFT OUTER JOIN
			         MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
		                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
			         MAESTROREFER ON BOM_STRUCT.BST_HIJO = MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
		                      CONFIGURATIPO CONFIGURATIPO2 ON MAESTROREFER.TI_CODIGO = CONFIGURATIPO2.TI_CODIGO
		WHERE ##TempSubExplosiona.FE_CODIGO=@CodigoFactura
			AND (ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'P' OR ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'S') 
			 AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'C') AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'P')
		AND BOM_STRUCT.BST_HIJO IS NOT NULL AND BOM_STRUCT.BST_INCORPOR >0
	
	
		-- continua explosion a niveles inferiores
		inicio0:
	
		SET @nivel=@nivel+1



				insert into ##TempSubExplosiona (bsu_subensamble, bst_incorpor, fed_fecha_struct, fed_indiced, fe_codigo, fed_cant, Nivel, eq_gen)
	
				SELECT     bst_hijo, ##TempSubExplosiona.bst_incorpor * (BOM_STRUCT.BST_INCORPOR+
					        (CASE WHEN isnull(MAESTRO.MA_POR_DESP,0)<0 and isnull(MAESTRO.MA_POR_DESP,0)<>0 
						then ((BOM_STRUCT.BST_INCORPOR*MAESTRO.MA_POR_DESP)/100) else 0 end)) AS BST_INCORPOR, 
						fed_fecha_struct, FED_INDICED, FE_CODIGO, FED_CANT, 'B'+CONVERT(VARCHAR(20),@nivel), FACTCONV
				FROM    ##TempSubExplosiona INNER JOIN
	                      		BOM_STRUCT ON ##TempSubExplosiona.bsu_subensamble = BOM_STRUCT.BSU_SUBENSAMBLE AND
				                      BOM_STRUCT.BST_PERINI <= ##TempSubExplosiona.fed_fecha_struct AND 
				                      BOM_STRUCT.BST_PERFIN >= ##TempSubExplosiona.fed_fecha_struct LEFT OUTER JOIN
					         MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
				                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO LEFT OUTER JOIN
					         MAESTROREFER ON BOM_STRUCT.BST_HIJO = MAESTROREFER.MA_CODIGO LEFT OUTER JOIN
				                      CONFIGURATIPO CONFIGURATIPO2 ON MAESTROREFER.TI_CODIGO = CONFIGURATIPO2.TI_CODIGO
				WHERE ##TempSubExplosiona.FE_CODIGO=@CodigoFactura
					AND (ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'P' OR ISNULL(dbo.CONFIGURATIPO.CFT_TIPO, CONFIGURATIPO2.CFT_TIPO) = 'S') 
					 AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'C') AND (dbo.BOM_STRUCT.BST_TIP_ENS <> 'P')
					AND CONVERT(INT,REPLACE(##TempSubExplosiona.NIVEL,'B',''))=@nivel-1
				AND BOM_STRUCT.BST_HIJO IS NOT NULL AND BOM_STRUCT.BST_INCORPOR >0


			if (SELECT     COUNT(*)
			    FROM         ##TempSubExplosiona
			    WHERE     CONVERT(INT,REPLACE(NIVEL,'B','')) =@nivel-1
			    AND FE_CODIGO = @CodigoFactura)>0

			set @existe=1
			else
			set @existe=0
	
	
		while (@existe>0)	
		begin
	
			goto inicio0
	
	
		end


	end
	else
	begin

		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##TempFiscComp'  AND  type = 'U')
		begin
			drop table ##TempFiscComp
		end
		
		CREATE TABLE ##TempFiscComp (
			[bsu_subensamble] [int] NULL ,
			[bst_cantidadusofinal] [decimal](38, 6) NULL 
		) ON [PRIMARY]
		

		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##VPIDescarga'  AND  type = 'U')
		begin
			drop table ##VPIDescarga
		end
		

		SELECT     SUM(PID_SALDOGEN) AS PID_SALDOGEN, MA_CODIGO
		into ##VPIDescarga
		FROM         VPIDescarga
		GROUP BY MA_CODIGO
		ORDER BY MA_CODIGO



		/* se corren los stored para cada uno de los pt o sub del detalle de la factura*/
	
		
		declare CUR_DETALLEFACTPT cursor for
		-- selecciona Producto Terminados o Subensambles para esa Factura
			SELECT     dbo.FACTEXPDET.FED_INDICED, dbo.FACTEXPDET.MA_CODIGO, (dbo.FACTEXPDET.FED_CANT) AS FED_CANT, 
			          isnull(convert(varchar(10),dbo.FACTEXPDET.FED_FECHA_STRUCT,101), @fecha), dbo.FACTEXPDET.FED_TIP_ENS,
				dbo.FACTEXPDET.ME_GENERICO, dbo.CONFIGURATIPO.CFT_TIPO
			FROM         dbo.FACTEXPDET LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.FACTEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
			                      dbo.CONFIGURATIPO.CFT_TIPO = 'P') AND (dbo.FACTEXPDET.FE_CODIGO = @CodigoFactura) AND (dbo.FACTEXPDET.FED_RETRABAJO = 'N'
				        or dbo.FACTEXPDET.FED_RETRABAJO = 'C' or dbo.FACTEXPDET.FED_RETRABAJO = 'A') AND
					 ((dbo.FACTEXPDET.FED_TIP_ENS = 'A' AND dbo.FACTEXPDET.FED_DISCHARGE='S')
					or dbo.FACTEXPDET.FED_TIP_ENS = 'F' OR dbo.FACTEXPDET.FED_TIP_ENS = 'E'or dbo.FACTEXPDET.FED_TIP_ENS = 'O') 
					AND (dbo.FACTEXPDET.FED_CANT > 0)  
				AND dbo.FACTEXPDET.PID_INDICED=-1 AND dbo.FACTEXPDET.FED_CANT>0
			ORDER BY dbo.FACTEXPDET.MA_CODIGO
		 OPEN CUR_DETALLEFACTPT
		
		  FETCH NEXT FROM CUR_DETALLEFACTPT
			INTO @FED_INDICED, @BST_PT, @FED_CANT, @FED_FECHA_STRUCT, @FED_TIP_ENS, @ME_GEN, @CFT_TIPO
		
		  WHILE (@@fetch_status = 0) 
		  BEGIN  
		
					-- si no hay saldo del producto, se explosiona.									Se agrego opcion validaTipoDescargaPR 25-Ago-10 Manuel G. (para que explosione PT si tiene dicha configuracion aunque tenga saldo el PT)
					if not exists(select ma_codigo from ##VPIDescarga where ma_codigo=@BST_PT) or ((select cf_ValidaTipoDescargaPT from configuracion) = 'S' and @CFT_TIPO = 'P') --or @FED_TIP_ENS<>'A'
					begin
						insert into ##TempSubExplosiona (bsu_subensamble, bst_incorpor, fed_fecha_struct, fed_indiced, fe_codigo, fed_cant, eq_gen)
						values(@BST_PT, 1, @FED_FECHA_STRUCT, @FED_INDICED, @CODIGOFACTURA, @FED_CANT, 1)
						
						
						
						EXEC SP_FILL_BOM_DESCTEMPFisComp @FED_INDICED, @BST_PT, @FED_FECHA_STRUCT, @FED_CANT, @CODIGOFACTURA
		
					end
					else
					begin			
						-- se descarga directamente el producto

						-- calculo de uso final del producto a descargar
						select @Sumcantidadusofinal=round(sum(isnull(bst_cantidadusofinal,0)),6) from ##TempFiscComp where bsu_subensamble=@BST_PT
			
						if @Sumcantidadusofinal is null	
						set @Sumcantidadusofinal=0
			
						set @usoFinal = round(@FED_CANT,6)
			
						set @usoFinalIncluido=@Sumcantidadusofinal+@usoFinal
			
						select @saldoactual=round(sum(pid_saldogen),6) from ##VPIDescarga where ma_codigo=@BST_PT
			
						if @saldoactual is null
						set @saldoactual=0
		
		
		
				
						if @saldoactual=@usoFinalIncluido
						begin
							-- 
							insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
							   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR)
							values(@BST_PT, 1, 'S', 'S', 1, @ME_GEN, 'C', @FED_CANT, @CODIGOFACTURA, 1,
							@BST_TIPODESC, 0, @FED_INDICED, @BST_PT, @FED_FECHA_STRUCT)
			
							insert into ##TempFiscComp(bsu_subensamble, bst_cantidadusofinal)
							values(@BST_PT, @usoFinal)
						end
						else
						begin
			
			
							if @usoFinalIncluido<=@saldoactual
							begin
								insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
								   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR)
								values(@BST_PT, 1, 'S', 'S', 1, @ME_GEN, 'C', @FED_CANT, @CODIGOFACTURA, 1,
								@BST_TIPODESC, 0, @FED_INDICED, @BST_PT, @FED_FECHA_STRUCT)
			
			
								insert into ##TempFiscComp(bsu_subensamble, bst_cantidadusofinal)
								values(@BST_PT, @usoFinal)
							end
							else
							begin
			
			
								select @saldoUsable=round(@saldoactual-@Sumcantidadusofinal,6)
			
								select @CantAlcanza = round(@saldoUsable,6)
			
								
								select @CantaExplosionar = round((@FED_CANT)-@CantAlcanza,6)
			
			
								insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO, FACTCONV, ME_GEN, 
								   MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_NIVEL, BST_TIPODESC, BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR)
								values(@BST_PT, 1, 'S', 'S', 1, @ME_GEN, 'C', @CantAlcanza, @CODIGOFACTURA, 1,
								@BST_TIPODESC, 0, @FED_INDICED, @BST_PT, @FED_FECHA_STRUCT)
			
			
								insert into ##TempFiscComp(bsu_subensamble, bst_cantidadusofinal)
								values(@BST_PT, @saldoUsable)
		
		
								insert into ##TempSubExplosiona (bsu_subensamble, bst_incorpor, fed_fecha_struct, fed_indiced, fe_codigo, fed_cant, eq_gen)
								values(@BST_PT, 1, @FED_FECHA_STRUCT, @FED_INDICED, @CODIGOFACTURA, @CantaExplosionar, 1)

			
								-- se explosiona para la cantidad faltante del producto
								EXEC SP_FILL_BOM_DESCTEMPFisComp @FED_INDICED, @BST_PT, @FED_FECHA_STRUCT, @CantaExplosionar, @CODIGOFACTURA
							end
			
						end
			
					end
			
			
			
		
		
			FETCH NEXT FROM CUR_DETALLEFACTPT INTO @FED_INDICED, @BST_PT, @FED_CANT, @FED_FECHA_STRUCT, @FED_TIP_ENS, @ME_GEN, @CFT_TIPO
		
		END
		
			CLOSE CUR_DETALLEFACTPT
			DEALLOCATE CUR_DETALLEFACTPT





		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##TempFiscComp'  AND  type = 'U')
		begin
			drop table ##TempFiscComp
		end
		
		

		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##VPIDescarga'  AND  type = 'U')
		begin
			drop table ##VPIDescarga
		end
		

		
	end

		if exists(select * from ##TempSubExplosiona)
		begin
			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##TempSubExplosiona1'  AND  type = 'U')
			begin
				drop table ##TempSubExplosiona1
			end

			select bsu_subensamble, sum(bst_incorpor) bst_incorpor, fed_fecha_struct, fed_indiced, fe_codigo, fed_cant, eq_gen
			into ##TempSubExplosiona1
			from ##TempSubExplosiona
			group by bsu_subensamble, fed_fecha_struct, fed_indiced, fe_codigo, fed_cant, eq_gen
		
	
			--if (select CF_FISCOMP_EXPDESC from configuracion)<>'S' 
			begin
					insert into bom_desctemp (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO,  ME_CODIGO, FACTCONV, ME_GEN, 
					    MA_TIP_ENS, FED_CANT, FE_CODIGO, BST_TIPODESC,
					   BST_PERTENECE, FED_INDICED, BST_PT, BST_ENTRAVIGOR, BST_PESO_KG)
		
					SELECT     BOM_STRUCT.BST_HIJO, TempSubExplosiona.bst_incorpor *--TempSubExplosiona.eq_gen* 
							(BOM_STRUCT.BST_INCORPOR+
						        (CASE WHEN isnull(MAESTRO.MA_POR_DESP,0)<0 and isnull(MAESTRO.MA_POR_DESP,0)<>0 
							then ((BOM_STRUCT.BST_INCORPOR*MAESTRO.MA_POR_DESP)/100) else 0 end)) AS BST_INCORPOR, 
						         'S', CONFIGURATIPO.CFT_TIPO, BOM_STRUCT.ME_CODIGO, BOM_STRUCT.FACTCONV, BOM_STRUCT.ME_GEN, 
					                      'C', FED_CANT, FE_CODIGO, @BST_TIPODESC,
						        TempSubExplosiona.bsu_subensamble, FED_INDICED, (select ma_codigo from factexpdet where fed_indiced=TempSubExplosiona.fed_indiced), 
						TempSubExplosiona.fed_fecha_struct, MAESTRO.MA_PESO_KG
					FROM         ##TempSubExplosiona1 TempSubExplosiona INNER JOIN
		                      		BOM_STRUCT ON TempSubExplosiona.bsu_subensamble = BOM_STRUCT.BSU_SUBENSAMBLE AND
					                      BOM_STRUCT.BST_PERINI <= TempSubExplosiona.fed_fecha_struct AND 
					                      BOM_STRUCT.BST_PERFIN >= TempSubExplosiona.fed_fecha_struct LEFT OUTER JOIN
					                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
					                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
					WHERE TempSubExplosiona.FE_CODIGO=@CodigoFactura and  
					BOM_STRUCT.BST_DISCH ='S' --and CONFIGURATIPO.CFT_TIPO not in ('P','S')
					and (BOM_STRUCT.BST_TIP_ENS='C' or BOM_STRUCT.BST_TIP_ENS='E')
					AND BOM_STRUCT.BST_HIJO IS NOT NULL AND BOM_STRUCT.BST_INCORPOR >0

				--PRINT 'HOLA'
	
			end


			IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
			   WHERE name = '##TempSubExplosiona1'  AND  type = 'U')
			begin
				drop table ##TempSubExplosiona1
			end

		end		

		IF EXISTS (SELECT name FROM  [tempdb].dbo.sysobjects 
		   WHERE name = '##TempSubExplosiona'  AND  type = 'U')
		begin
			drop table ##TempSubExplosiona
		end

GO
