SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_filltablabomexplosion] (@BST_PT Int)   as

SET NOCOUNT ON 
declare @BST_HIJO int, @BST_PERINI datetime, @BST_PERFIN datetime, @CFT_TIPO char(1)


if not exists (select * from dbo.sysobjects where name='tempBOMexp')
create table [dbo].[tempBOMexp]
( Bsu_subensamble int,
bst_hijo int,
BST_PERINI datetime,
BST_PERFIN datetime)


DELETE FROM tempBOMexp WHERE bsu_subensamble = @BST_PT



	insert into tempBOMexp(bst_perini, bst_perfin, bst_hijo, Bsu_subensamble)
	SELECT     TOP 100 PERCENT dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.BST_HIJO, @BST_PT
	FROM         dbo.BOM_STRUCT INNER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO INNER JOIN
	                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	WHERE     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) --AND (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR dbo.CONFIGURATIPO.CFT_TIPO = 'P')
	GROUP BY dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.BST_HIJO
	ORDER BY dbo.BOM_STRUCT.BST_HIJO




	declare CUR_TABLABOMEXP cursor for

		SELECT     TOP 100 PERCENT dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.BST_HIJO
		FROM         dbo.BOM_STRUCT INNER JOIN dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO INNER JOIN
		                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) AND (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
		                      dbo.CONFIGURATIPO.CFT_TIPO = 'P')
		GROUP BY dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.BST_HIJO
		ORDER BY dbo.BOM_STRUCT.BST_HIJO
	
	
	 OPEN CUR_TABLABOMEXP
	
	
		FETCH NEXT FROM CUR_TABLABOMEXP INTO @bst_perini, @bst_perfin, @bst_hijo
	
	  WHILE (@@fetch_status = 0) 
	
	  BEGIN  
	
				exec  SP_filltablabomexplosion1 @BST_PT, @BST_HIJO


	
	
	
		FETCH NEXT FROM CUR_TABLABOMEXP INTO @bst_perini, @bst_perfin, @bst_hijo
	
	END
	
		CLOSE CUR_TABLABOMEXP
		DEALLOCATE CUR_TABLABOMEXP



























GO
