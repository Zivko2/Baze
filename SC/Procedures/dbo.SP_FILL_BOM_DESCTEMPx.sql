SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE PROCEDURE [dbo].[SP_FILL_BOM_DESCTEMPx] (@FED_INDICED INT, @BST_PT Int, @BST_ENTRAVIGOR DateTime, @FED_CANT decimal(38,6), @CODIGOFACTURA INT, @MENSAJE2 char(1)='N' output)   as


DECLARE @bst_hijo int, @bst_disch char(1), @ti_codigo char(1), @me_codigo int, @Factconv decimal(28,14), @me_gen int, @bst_incorpor decimal(38,6),
               @MA_TIP_ENS char(1), @FED_RETRABAJO char(1), @CF_EXPLOSDESCADD CHAR(1)


select @CF_EXPLOSDESCADD=CF_EXPLOSDESCADD from configuracion 


--	IF EXISTS (SELECT * FROM BOM_DESCTEMP WHERE FE_CODIGO=@CODIGOFACTURA)
--	DELETE FROM BOM_DESCTEMP WHERE FE_CODIGO=@CODIGOFACTURA

	exec sp_droptable  'BOM_DESCTEMP'
	exec sp_CreaBOM_DESCTEMP


	exec SP_CREAVDESCRETRABAJO @CODIGOFACTURA

	-- creacion de la tabla CicladoTemp
	if not exists (select * from dbo.sysobjects where name='CicladoTemp')
	CREATE TABLE [dbo].[CicladoTemp]
		(fe_codigo int,
		fed_indiced int)


	TRUNCATE TABLE CicladoTemp


	-- ciclo que explosiona
	if @FED_INDICED=-1
		begin
		declare cur_bstpertenece1 cursor for
			SELECT FED_INDICED, MA_CODIGO, FED_FECHA_STRUCT, FED_CANT, FED_RETRABAJO
			FROM FACTEXPDET
			WHERE FE_CODIGO=@CODIGOFACTURA
		end
		else
		begin
		declare cur_bstpertenece1 cursor for
			SELECT FED_INDICED, MA_CODIGO, FED_FECHA_STRUCT, FED_CANT, FED_RETRABAJO
			FROM FACTEXPDET
			WHERE FED_INDICED=@FED_INDICED
	
		end
	open cur_bstpertenece1
	
	
		FETCH NEXT FROM cur_bstpertenece1 INTO @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, @FED_CANT, @FED_RETRABAJO
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN

			if @FED_RETRABAJO<>'N'
			begin

				-- se insertan los consumibles en produccion como merma
				
				insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
				me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)
			
				SELECT     FE_CODIGO, MA_CODIGO, MA_HIJO, 1, MA_DISCHARGE, CFT_TIPO, isnull(ME_COM, ME_GEN), FACTCONV, ME_GEN, RE_INCORPOR, FED_INDICED, 
						MA_TIP_ENS, 'M', 'RC'
				FROM         VDESCRETRABAJO
				WHERE FED_RETRABAJO='C' and FED_INDICED=@FED_INDICED
				and RE_INCORPOR>0
				
				-- la vista VDESCRETRABAJO ya trae integrado el producto terminado en caso de fed_retrabajo='R'
			
				if @CF_EXPLOSDESCADD='S'
				begin
					-- se insertan los diferentes de consumibles en produccion, diferentes de estructura dinamica y diferentes de adicion a descarga
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)	
					
					SELECT     FE_CODIGO, MA_CODIGO, MA_HIJO, 1, MA_DISCHARGE, CFT_TIPO, isnull(ME_COM, ME_GEN), FACTCONV, ME_GEN, RE_INCORPOR, FED_INDICED, 
							MA_TIP_ENS, 'N', 'RR'
					FROM         VDESCRETRABAJO
					WHERE FED_RETRABAJO<>'C' and FED_RETRABAJO<>'D' and FED_RETRABAJO<>'E' and FED_RETRABAJO<>'A' and FED_INDICED=@FED_INDICED
					and RE_INCORPOR>0
			
					-- se insertan los de adicion a descarga pero que sean diferentes de productos terminados y subensambles
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)	
					
					SELECT     FE_CODIGO, MA_CODIGO, MA_HIJO, 1, MA_DISCHARGE, CFT_TIPO, isnull(ME_COM, ME_GEN), FACTCONV, ME_GEN, RE_INCORPOR, FED_INDICED, 
							MA_TIP_ENS, 'N', 'RR'
					FROM         VDESCRETRABAJO 
					WHERE FED_RETRABAJO='A' AND CFT_TIPO NOT IN ('S', 'P') and FED_INDICED=@FED_INDICED
					and RE_INCORPOR>0
			
					-- explosiona los subensambles y productos que estan en la adicion a descarga
					if exists (select * from factexpdet where fed_retrabajo='A') 
					exec SP_DescExplosionBomAdicion @CodigoFactura
			
				end
				begin
			 		-- se insertan los diferentes de consumibles en produccion y diferentes de estructura dinamica como normal 
					insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
					me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)	
					
					SELECT     FE_CODIGO, MA_CODIGO, MA_HIJO, 1, MA_DISCHARGE, CFT_TIPO, isnull(ME_COM, ME_GEN), FACTCONV, ME_GEN, RE_INCORPOR, FED_INDICED, 
							MA_TIP_ENS, 'N', 'RR'
					FROM         VDESCRETRABAJO
					WHERE FED_RETRABAJO<>'C' and FED_RETRABAJO<>'D' and FED_RETRABAJO<>'E' and FED_INDICED=@FED_INDICED
					and RE_INCORPOR>0
				end
			
				-- se insertan los de estructura dinamica para que sea multiplicado por la cantidad	
				insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
				me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)	
				
				SELECT     FE_CODIGO, MA_CODIGO, MA_HIJO, FED_CANT, MA_DISCHARGE, CFT_TIPO, isnull(ME_COM, ME_GEN), FACTCONV, ME_GEN, RE_INCORPOR, FED_INDICED, 
						MA_TIP_ENS, 'N', 'RD'
				FROM         VDESCRETRABAJO
				WHERE FED_RETRABAJO in ('D', 'E') and FED_INDICED=@FED_INDICED
				and RE_INCORPOR>0

		end
		else
			exec SP_FILL_BOM_DESCTEMP @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, @FED_CANT, @CODIGOFACTURA, @MENSAJE1=@MENSAJE2 OUTPUT
	
		if @MENSAJE2='S'
		begin

			insert into CicladoTemp(fe_codigo, fed_indiced)
			values(@CODIGOFACTURA, @FED_INDICED)

		end
	
	
		FETCH NEXT FROM cur_bstpertenece1 INTO @FED_INDICED, @BST_PT, @BST_ENTRAVIGOR, @FED_CANT, @FED_RETRABAJO
	
	END
	
	CLOSE cur_bstpertenece1
	DEALLOCATE cur_bstpertenece1


	exec sp_droptable 'CicladoTemp'




GO
