SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* corre el stored que actualiza los costos del bom_costo en base a la modificacion del maestrocost*/
CREATE PROCEDURE [dbo].[SP_ACTUALIZABOMCOSTOCAL] (@BST_PT int, @Entravigor datetime)   as

SET NOCOUNT ON 
declare @bst_codigo int


	declare @ma_grav_mp decimal(38,6), @ma_grav_add decimal(38,6),@ma_grav_emp decimal(38,6), 
	@ma_grav_gi decimal(38,6), @ma_grav_gi_mx decimal(38,6), @ma_grav_mo decimal(38,6), 
	@ma_ng_mp decimal(38,6), @ma_ng_add decimal(38,6), @ma_ng_emp decimal(38,6), @ma_ng_va decimal(38,6), 
	@ma_costo decimal(38,6),  @ma_inv_gen char(1), @tco_codigo int,
	@ma_grava_va char (1), @CFT_TIPO varchar(1), @MA_NG_USA decimal(38,6), @subensamble int,
	@ma_codigo int


		exec sp_droptable 'BSTCODIGO'
		
		CREATE TABLE [dbo].[BSTCODIGO] (
			[BST_CODIGO] [int] NULL 
		) ON [PRIMARY]


		-- se llena la tabla BSTCODIGO	
		INSERT INTO BSTCODIGO( BST_CODIGO )
		SELECT     BST_CODIGO
		FROM         BOM_STRUCT
		WHERE      (BSU_SUBENSAMBLE = @BST_PT) AND (@Entravigor between BST_PERINI AND BST_PERFIN) 
		GROUP BY BST_CODIGO


		INSERT INTO BSTCODIGO( BST_CODIGO )
		SELECT     BST_CODIGO
		FROM         BOM_STRUCT
		WHERE      (BST_HIJO = @BST_PT) AND (@Entravigor between BST_PERINI AND BST_PERFIN) 
			 AND BST_CODIGO NOT IN (SELECT BST_CODIGO FROM BSTCODIGO)
		GROUP BY BST_CODIGO


/* se acutualiza los costos */
		-- actualiza los que existen
			update bom_costo
			set bom_costo.bst_costo = VMAESTROCOST.ma_costo
			FROM BOM_STRUCT INNER JOIN MAESTRO ON
			      BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO INNER JOIN
	                      BOM_COSTO ON BOM_STRUCT.BST_CODIGO = BOM_COSTO.BST_CODIGO INNER JOIN
	                      VMAESTROCOST ON BOM_STRUCT.BST_HIJO = VMAESTROCOST.MA_CODIGO
			where BOM_COSTO.bst_codigo in (select bst_codigo from BSTCODIGO) and MAESTRO.TI_CODIGO IN
			(select ti_codigo from configuratipo where cft_tipo<>'P' and cft_tipo<>'S') and
			bom_costo.bst_costo <> VMAESTROCOST.ma_costo


			update bom_costo
			set bom_costo.bst_grav_mp = VMAESTROCOST.ma_grav_mp, bom_costo.bst_grav_add = VMAESTROCOST.ma_grav_add, 
			bom_costo.bst_grav_emp = VMAESTROCOST.ma_grav_emp, bom_costo.bst_ng_mp = VMAESTROCOST.ma_ng_mp, 
			bom_costo.bst_ng_add = VMAESTROCOST.ma_ng_add, bom_costo.bst_ng_emp = VMAESTROCOST.ma_ng_emp,
			bom_costo.bst_grav_gi = VMAESTROCOST.ma_grav_gi, bom_costo.bst_grav_gi_mx = VMAESTROCOST.ma_grav_gi_mx, 
			bom_costo.bst_grav_mo = VMAESTROCOST.ma_grav_mo, bom_costo.bst_costo = VMAESTROCOST.ma_costo,
			bom_costo.bst_ng_usa = VMAESTROCOST.ma_ng_usa
			FROM BOM_STRUCT INNER JOIN MAESTR ON BOM_STRUCT.BST_HIJO=MAESTRO.MA_CODIGO INNER JOIN
	                      BOM_COSTO ON BOM_STRUCT.BST_CODIGO = BOM_COSTO.BST_CODIGO INNER JOIN
	                      VMAESTROCOST ON BOM_STRUCT.BST_HIJO = VMAESTROCOST.MA_CODIGO
			where BOM_COSTO.bst_codigo in (select bst_codigo from BSTCODIGO) and MAESTRO.TI_CODIGO IN
			(select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and
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
			AND MA_COSTO is not null

			


--		exec sp_actualizaBomCosto @bst_codigo




		exec sp_droptable 'BSTCODIGO'





GO
