SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* en este procedimiento se saca cuales son todos los padres posibles del subensamble 
el @BST_HIJO nunca cambia el que va cambiando es el @BSU_SUBENSAMBLE
*/
CREATE PROCEDURE [dbo].[SP_filltablaimplosionsub1](@BSU_SUBENSAMBLE Int, @BST_HIJO int, @BST_ENTRAVIGOR datetime)   as


declare @BST_padre int, @BST_PERINI datetime, @BST_PERFIN datetime, @CFT_TIPO char(1)

			insert into tempImplosionSub(bst_perini, bst_perfin, bst_hijo, Bsu_subensamble)

			SELECT     bst_perini, bst_perfin, @BST_HIJO, bsu_subensamble
			from bom_struct
			where bst_hijo= @BSU_SUBENSAMBLE and bst_perini>=@BST_ENTRAVIGOR
			group by  bst_perini, bst_perfin, bsu_subensamble, bst_hijo
			ORDER BY dbo.BOM_STRUCT.bsu_subensamble


DECLARE @CursorVar CURSOR
SET @CursorVar = CURSOR SCROLL DYNAMIC FOR

	SELECT     bst_perini, bst_perfin, bsu_subensamble
	from bom_struct left outer join maestro on bom_struct.bst_hijo = maestro.ma_codigo
	where bst_hijo= @BSU_SUBENSAMBLE and bst_perini>=@BST_ENTRAVIGOR and
	maestro.ti_codigo in (select ti_codigo from configuratipo where cft_tipo='S' or cft_tipo='P')
	group by  bst_perini, bst_perfin, bsu_subensamble
	ORDER BY dbo.BOM_STRUCT.bsu_subensamble
 OPEN @CursorVar


	FETCH NEXT FROM @CursorVar INTO @bst_perini, @bst_perfin, @bst_padre

  WHILE (@@fetch_status = 0) 

  BEGIN  



			exec  SP_filltablaimplosionsub1 @BST_padre, @BST_HIJO, @bst_perini



	FETCH NEXT FROM @CursorVar INTO @bst_perini, @bst_perfin, @bst_padre

END

	CLOSE @CursorVar
	DEALLOCATE @CursorVar


GO
