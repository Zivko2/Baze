SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















































CREATE PROCEDURE [dbo].[SP_ActualizaBom_costoAct]   as


		UPDATE dbo.BOM_COSTO
	SET     dbo.BOM_COSTO.BST_GRAV_MP= dbo.VMAESTROCOST.MA_GRAV_MP, dbo.BOM_COSTO.BST_GRAV_ADD= dbo.VMAESTROCOST.MA_GRAV_ADD, 
	                      dbo.BOM_COSTO.BST_GRAV_EMP= dbo.VMAESTROCOST.MA_GRAV_EMP, dbo.BOM_COSTO.BST_GRAV_GI= dbo.VMAESTROCOST.MA_GRAV_GI, 
	                      dbo.BOM_COSTO.BST_GRAV_GI_MX= dbo.VMAESTROCOST.MA_GRAV_GI_MX, dbo.BOM_COSTO.BST_GRAV_MO= dbo.VMAESTROCOST.MA_GRAV_MO, 
	                      dbo.BOM_COSTO.BST_NG_MP= dbo.VMAESTROCOST.MA_NG_MP, dbo.BOM_COSTO.BST_NG_ADD= dbo.VMAESTROCOST.MA_NG_ADD, 
	                      dbo.BOM_COSTO.BST_NG_EMP= dbo.VMAESTROCOST.MA_NG_EMP, dbo.BOM_COSTO.BST_COSTO= dbo.VMAESTROCOST.MA_COSTO, 
	                      dbo.BOM_COSTO.BST_NG_USA= dbo.VMAESTROCOST.MA_NG_USA
	FROM         dbo.BOM_COSTO INNER JOIN
	                      dbo.BOM_STRUCT ON dbo.BOM_COSTO.BST_CODIGO = dbo.BOM_STRUCT.BST_CODIGO INNER JOIN
	                      dbo.VMAESTROCOST ON dbo.BOM_STRUCT.BST_HIJO = dbo.VMAESTROCOST.MA_CODIGO INNER JOIN
	                      dbo.MAESTRO ON dbo.VMAESTROCOST.MA_CODIGO = dbo.MAESTRO.MA_CODIGO AND dbo.BOM_STRUCT.ME_CODIGO = dbo.MAESTRO.ME_COM
	WHERE dbo.BOM_STRUCT.BST_PERINI<=GETDATE() AND dbo.BOM_STRUCT.BST_PERFIN>=GETDATE()

	
	UPDATE dbo.BOM_COSTO
	SET     dbo.BOM_COSTO.BST_GRAV_MP= ROUND(dbo.VMAESTROCOST.MA_GRAV_MP/dbo.EQUIVALE.EQ_CANT,6), dbo.BOM_COSTO.BST_GRAV_ADD= ROUND(dbo.VMAESTROCOST.MA_GRAV_ADD/dbo.EQUIVALE.EQ_CANT,6), 
	                      dbo.BOM_COSTO.BST_GRAV_EMP= ROUND(dbo.VMAESTROCOST.MA_GRAV_EMP/dbo.EQUIVALE.EQ_CANT,6), dbo.BOM_COSTO.BST_GRAV_GI= ROUND(dbo.VMAESTROCOST.MA_GRAV_GI/dbo.EQUIVALE.EQ_CANT,6), 
	                      dbo.BOM_COSTO.BST_GRAV_GI_MX= ROUND(dbo.VMAESTROCOST.MA_GRAV_GI_MX/dbo.EQUIVALE.EQ_CANT,6), dbo.BOM_COSTO.BST_GRAV_MO= ROUND(dbo.VMAESTROCOST.MA_GRAV_MO/dbo.EQUIVALE.EQ_CANT,6), 
	                      dbo.BOM_COSTO.BST_NG_MP= ROUND(dbo.VMAESTROCOST.MA_NG_MP/dbo.EQUIVALE.EQ_CANT,6), dbo.BOM_COSTO.BST_NG_ADD= ROUND(dbo.VMAESTROCOST.MA_NG_ADD/dbo.EQUIVALE.EQ_CANT,6), 
	                      dbo.BOM_COSTO.BST_NG_EMP= ROUND(dbo.VMAESTROCOST.MA_NG_EMP/dbo.EQUIVALE.EQ_CANT,6), dbo.BOM_COSTO.BST_COSTO= ROUND(dbo.VMAESTROCOST.MA_COSTO/dbo.EQUIVALE.EQ_CANT,6), 
	                      dbo.BOM_COSTO.BST_NG_USA= ROUND(dbo.VMAESTROCOST.MA_NG_USA/dbo.EQUIVALE.EQ_CANT,6)
	FROM         dbo.BOM_COSTO INNER JOIN
	                      dbo.BOM_STRUCT ON dbo.BOM_COSTO.BST_CODIGO = dbo.BOM_STRUCT.BST_CODIGO INNER JOIN
	                      dbo.VMAESTROCOST ON dbo.BOM_STRUCT.BST_HIJO = dbo.VMAESTROCOST.MA_CODIGO INNER JOIN
	                      dbo.MAESTRO ON dbo.VMAESTROCOST.MA_CODIGO = dbo.MAESTRO.MA_CODIGO INNER JOIN
	                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.BOM_STRUCT.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
	WHERE (equivale.eq_cant >0 and  equivale.eq_cant  is not null) AND dbo.BOM_STRUCT.BST_PERINI<=GETDATE() AND dbo.BOM_STRUCT.BST_PERFIN>=GETDATE()



	INSERT INTO BOM_COSTO(BST_GRAV_MP,BST_GRAV_ADD, BST_GRAV_EMP, BST_GRAV_GI,
		BST_GRAV_GI_MX, BST_GRAV_MO, BST_NG_MP, BST_NG_ADD, BST_NG_EMP, BST_COSTO, BST_NG_USA, BST_CODIGO, TCO_CODIGO)

	SELECT     ROUND(dbo.VMAESTROCOST.MA_GRAV_MP/dbo.EQUIVALE.EQ_CANT,6),  ROUND(dbo.VMAESTROCOST.MA_GRAV_ADD/dbo.EQUIVALE.EQ_CANT,6), 
	                      ROUND(dbo.VMAESTROCOST.MA_GRAV_EMP/dbo.EQUIVALE.EQ_CANT,6), ROUND(dbo.VMAESTROCOST.MA_GRAV_GI/dbo.EQUIVALE.EQ_CANT,6), 
	                      ROUND(dbo.VMAESTROCOST.MA_GRAV_GI_MX/dbo.EQUIVALE.EQ_CANT,6), ROUND(dbo.VMAESTROCOST.MA_GRAV_MO/dbo.EQUIVALE.EQ_CANT,6), 
	                      ROUND(dbo.VMAESTROCOST.MA_NG_MP/dbo.EQUIVALE.EQ_CANT,6), ROUND(dbo.VMAESTROCOST.MA_NG_ADD/dbo.EQUIVALE.EQ_CANT,6), 
	                      ROUND(dbo.VMAESTROCOST.MA_NG_EMP/dbo.EQUIVALE.EQ_CANT,6), ROUND(dbo.VMAESTROCOST.MA_COSTO/dbo.EQUIVALE.EQ_CANT,6), 
	                      ROUND(dbo.VMAESTROCOST.MA_NG_USA/dbo.EQUIVALE.EQ_CANT,6), dbo.BOM_STRUCT.BST_CODIGO, dbo.VMAESTROCOST.TCO_CODIGO
	FROM         dbo.BOM_STRUCT INNER JOIN
	                      dbo.VMAESTROCOST ON dbo.BOM_STRUCT.BST_HIJO = dbo.VMAESTROCOST.MA_CODIGO INNER JOIN
	                      dbo.MAESTRO ON dbo.VMAESTROCOST.MA_CODIGO = dbo.MAESTRO.MA_CODIGO INNER JOIN
	                      dbo.EQUIVALE ON dbo.MAESTRO.ME_COM = dbo.EQUIVALE.ME_CODIGO1 AND dbo.BOM_STRUCT.ME_CODIGO = dbo.EQUIVALE.ME_CODIGO2
	WHERE (equivale.eq_cant >0 and  equivale.eq_cant  is not null) AND dbo.BOM_STRUCT.BST_PERINI<=GETDATE() AND dbo.BOM_STRUCT.BST_PERFIN>=GETDATE()
	AND dbo.BOM_STRUCT.BST_CODIGO NOT IN (SELECT BST_CODIGO FROM BOM_COSTO)


	/*update bom_costo
	set bom_costo.bst_grav_mp = VMAESTROCOST.ma_grav_mp, bom_costo.bst_grav_add = VMAESTROCOST.ma_grav_add, 
	bom_costo.bst_grav_emp = VMAESTROCOST.ma_grav_emp, bom_costo.bst_ng_mp = VMAESTROCOST.ma_ng_mp, 
	bom_costo.bst_ng_add = VMAESTROCOST.ma_ng_add, bom_costo.bst_ng_emp = VMAESTROCOST.ma_ng_emp,
	bom_costo.bst_grav_gi = VMAESTROCOST.ma_grav_gi, bom_costo.bst_grav_gi_mx = VMAESTROCOST.ma_grav_gi_mx, 
	bom_costo.bst_grav_mo = VMAESTROCOST.ma_grav_mo, bom_costo.bst_costo = VMAESTROCOST.ma_costo,
	bom_costo.bst_ng_usa = VMAESTROCOST.ma_ng_usa
	FROM BOM_STRUCT INNER JOIN
              BOM_COSTO ON BOM_STRUCT.BST_CODIGO = BOM_COSTO.BST_CODIGO INNER JOIN
              VMAESTROCOST ON BOM_STRUCT.BST_HIJO = VMAESTROCOST.MA_CODIGO
	where   BOM_STRUCT.bst_perini<=getdate() and BOM_STRUCT.bst_perfin>=getdate() AND 
	(bom_costo.bst_grav_mp <> VMAESTROCOST.ma_grav_mp or bom_costo.bst_grav_add <> VMAESTROCOST.ma_grav_add or 
	bom_costo.bst_grav_emp <> VMAESTROCOST.ma_grav_emp or bom_costo.bst_ng_mp <> VMAESTROCOST.ma_ng_mp or 
	bom_costo.bst_ng_add <> VMAESTROCOST.ma_ng_add or bom_costo.bst_ng_emp <> VMAESTROCOST.ma_ng_emp or
	bom_costo.bst_grav_gi <> VMAESTROCOST.ma_grav_gi or bom_costo.bst_grav_gi_mx <> VMAESTROCOST.ma_grav_gi_mx or 
	bom_costo.bst_grav_mo <> VMAESTROCOST.ma_grav_mo or bom_costo.bst_costo <> VMAESTROCOST.ma_costo or
	bom_costo.bst_ng_usa <> VMAESTROCOST.ma_ng_usa)

	-- los que no existen

	insert into bom_costo (bst_codigo, bst_ng_mp, bst_ng_add, bst_ng_emp, bst_grav_mp, bst_grav_add,
	 bst_grav_emp, bst_grav_gi, bst_grav_gi_mx, bst_grav_mo, bst_costo, tco_codigo, 
	bst_ng_usa)

	SELECT BOM_STRUCT.BST_CODIGO, VMAESTROCOST.MA_NG_MP, VMAESTROCOST.MA_NG_ADD, 	
	VMAESTROCOST.MA_NG_EMP, VMAESTROCOST.MA_GRAV_MP, VMAESTROCOST.MA_GRAV_ADD, 
	VMAESTROCOST.MA_GRAV_EMP, VMAESTROCOST.MA_GRAV_GI, VMAESTROCOST.MA_GRAV_GI_MX, 
	VMAESTROCOST.MA_GRAV_MO, VMAESTROCOST.MA_COSTO, VMAESTROCOST.TCO_CODIGO, 
	VMAESTROCOST.MA_NG_USA 
	FROM BOM_STRUCT INNER JOIN
                  VMAESTROCOST ON BOM_STRUCT.BST_HIJO = VMAESTROCOST.MA_CODIGO
	WHERE BST_CODIGO NOT IN (SELECT BST_CODIGO FROM BOM_COSTO)
	AND MA_COSTO is not null*/




























GO
