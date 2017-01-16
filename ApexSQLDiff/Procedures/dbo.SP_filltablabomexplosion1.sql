SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_filltablabomexplosion1] (@BST_PT Int, @BST_HIJO Int)   as

SET NOCOUNT ON 
declare @BST_HIJO1 int, @BST_PERINI1 datetime, @BST_PERFIN1 datetime, @CFT_TIPO1 char(1),
@fechaini datetime


select @fechaini=min(bst_perini) from bom_struct where bsu_subensamble=@BST_PT



			insert into tempBOMexp(bst_perini, bst_perfin, bst_hijo, Bsu_subensamble)
			SELECT     TOP 100 PERCENT dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.BST_HIJO, @BST_PT
			FROM         dbo.BOM_STRUCT INNER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO INNER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
			WHERE     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_HIJO) --AND (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR dbo.CONFIGURATIPO.CFT_TIPO = 'P')
			AND dbo.BOM_STRUCT.BST_PERINI>=@fechaini
			GROUP BY dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.BST_HIJO
			ORDER BY dbo.BOM_STRUCT.BST_HIJO


	DECLARE @CursorVar CURSOR
	SET @CursorVar = CURSOR SCROLL DYNAMIC FOR
		SELECT     TOP 100 PERCENT dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.BST_HIJO
		FROM         dbo.BOM_STRUCT INNER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO INNER JOIN
		                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_HIJO) AND (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR dbo.CONFIGURATIPO.CFT_TIPO = 'P')
		AND dbo.BOM_STRUCT.BST_PERINI>=@fechaini
		GROUP BY dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.BST_HIJO
		ORDER BY dbo.BOM_STRUCT.BST_HIJO
		
	
	 OPEN @CursorVar
	  FETCH NEXT FROM @CursorVar INTO @bst_perini1, @bst_perfin1, @bst_hijo1
	
	  WHILE (@@fetch_status = 0) 
	
	  BEGIN  


	
				
 					exec  SP_filltablabomexplosion1 @BST_PT, @bst_hijo1

	
	
	
	
	 	 FETCH NEXT FROM @CursorVar INTO @bst_perini1, @bst_perfin1, @bst_hijo1
	
	END
	
		CLOSE @CursorVar 
		DEALLOCATE @CursorVar



























GO
