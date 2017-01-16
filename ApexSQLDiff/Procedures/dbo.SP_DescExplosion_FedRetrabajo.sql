SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE dbo.SP_DescExplosion_FedRetrabajo (@FED_INDICED Int)   as

SET NOCOUNT ON 

DECLARE @bst_pt int, @bst_hijo int, @fed_cant decimal(38,6), @bst_disch char(1), @ti_codigo char(1), @me_codigo int, @factconv decimal(28,14), @me_gen int, @bst_incorpor decimal(38,6),
               @FE_CODIGO int, @MA_TIP_ENS char(1), @FED_RETRABAJO char(1), @CF_EXPLOSDESCADD CHAR(1), @TEmbarque char(1), @BST_TIPODESC char(1)


	select @CF_EXPLOSDESCADD=CF_EXPLOSDESCADD from configuracion 


	SELECT @FE_CODIGO=FE_CODIGO FROM FACTEXPDET WHERE FED_INDICED=@FED_INDICED

	exec SP_CREAVDESCFEDRETRABAJO @FED_INDICED


	SELECT     @TEmbarque = CFQ_TIPO
	FROM CONFIGURATEMBARQUE 
	WHERE TQ_CODIGO IN (SELECT TQ_CODIGO FROM FACTEXP WHERE FE_CODIGO=@FE_CODIGO)


	if @TEmbarque='D'
	set @BST_TIPODESC='D'
	else
	set @BST_TIPODESC='N'


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
				MA_TIP_ENS, @BST_TIPODESC, 'RR'
		FROM         VDESCRETRABAJO
		WHERE FED_RETRABAJO<>'C' and FED_RETRABAJO<>'D' and FED_RETRABAJO<>'E' and FED_RETRABAJO<>'A' and FED_INDICED=@FED_INDICED
--		and RE_INCORPOR>0

		-- se insertan los de adicion a descarga pero que sean diferentes de productos terminados y subensambles
		insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
		me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)	
		
		SELECT     FE_CODIGO, MA_CODIGO, MA_HIJO, 1, MA_DISCHARGE, CFT_TIPO, isnull(ME_COM, ME_GEN), FACTCONV, ME_GEN, RE_INCORPOR, FED_INDICED, 
				MA_TIP_ENS, @BST_TIPODESC, 'RR'
		FROM         VDESCRETRABAJO 
		WHERE FED_RETRABAJO='A' AND CFT_TIPO NOT IN ('S', 'P') and FED_INDICED=@FED_INDICED


		-- se incluyen los productos terminados que estan includos en la lista y son el mismo numero de parte del detalle
		insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
		me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)	
		
		SELECT     FE_CODIGO, MA_CODIGO, MA_HIJO, 1, MA_DISCHARGE, CFT_TIPO, isnull(ME_COM, ME_GEN), FACTCONV, ME_GEN, RE_INCORPOR, FED_INDICED, 
				MA_TIP_ENS, @BST_TIPODESC, 'RR'
		FROM         VDESCRETRABAJO 
		WHERE FED_RETRABAJO='A' AND CFT_TIPO IN ('S', 'P') and FED_INDICED=@FED_INDICED
		AND MA_CODIGO IN (SELECT MA_HIJO FROM RETRABAJO WHERE TIPO_FACTRANS = 'F' AND FETR_INDICED=FED_INDICED)


		-- explosiona los subensambles y productos que estan en la adicion a descarga
		if exists (select * from factexpdet where fed_retrabajo='A') 

		exec SP_DescExplosionFedBomAdicion @FED_INDICED

	end
	else
	begin
 		-- se insertan los diferentes de consumibles en produccion y diferentes de estructura dinamica como normal 
		insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
		me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)	
		
		SELECT     FE_CODIGO, MA_CODIGO, MA_HIJO, 1, MA_DISCHARGE, CFT_TIPO, isnull(ME_COM, ME_GEN), FACTCONV, ME_GEN, RE_INCORPOR, FED_INDICED, 
				MA_TIP_ENS, @BST_TIPODESC, 'RR'
		FROM         VDESCRETRABAJO
		WHERE FED_RETRABAJO<>'C' and FED_RETRABAJO<>'D' and FED_RETRABAJO<>'E' and FED_INDICED=@FED_INDICED
--		and RE_INCORPOR>0
	end
	
	-- se insertan los de estructura dinamica para que sea multiplicado por la cantidad	
	insert into bom_desctemp (fe_codigo, bst_pt, bst_hijo, fed_cant, bst_disch, ti_codigo,
	me_codigo, factconv, me_gen, bst_incorpor, FED_INDICED, MA_TIP_ENS, BST_TIPODESC, BST_NIVEL)	
	
	SELECT     FE_CODIGO, MA_CODIGO, MA_HIJO, FED_CANT, MA_DISCHARGE, CFT_TIPO, isnull(ME_COM, ME_GEN), FACTCONV, ME_GEN, RE_INCORPOR, FED_INDICED, 
			MA_TIP_ENS, @BST_TIPODESC, 'RD'
	FROM         VDESCRETRABAJO
	WHERE FED_RETRABAJO in ('D', 'E') and FED_INDICED=@FED_INDICED
	and RE_INCORPOR>0

	/* insertamos en almacen desperdicio el desperdicio que genero el retrabajo */

--		exec sp_DescRetrabajoDesp @FED_INDICED


GO
