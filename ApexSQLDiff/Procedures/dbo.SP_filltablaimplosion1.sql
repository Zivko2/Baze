SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_filltablaimplosion1](@BST_HIJO int, @bst_subensamble int, @BST_ENTRAVIGOR datetime)   as


declare @bsu_subensamble1 int, @BST_PERINI datetime, @BST_PERFIN datetime, @CFT_TIPO char(1)

			insert into tempImplosion(bst_hijo, Bsu_subensamble)

			SELECT     @BST_HIJO, bsu_subensamble
			from bom_struct
			where bst_hijo= @bst_subensamble and bst_perini<=@BST_ENTRAVIGOR
			and bst_perfin >=@BST_ENTRAVIGOR
			group by  bsu_subensamble, bst_hijo
			ORDER BY bsu_subensamble


DECLARE @CursorVar CURSOR
SET @CursorVar = CURSOR SCROLL DYNAMIC FOR

	SELECT     bsu_subensamble
	from bom_struct left outer join maestro on bom_struct.bst_hijo = maestro.ma_codigo
	where bst_hijo= @bst_subensamble and bst_perini<=@BST_ENTRAVIGOR and
	bst_perfin>=@BST_ENTRAVIGOR and
	maestro.ti_codigo in (select ti_codigo from configuratipo where cft_tipo='S' or cft_tipo='P')
	and bsu_subensamble in (select bst_hijo from bom_struct)
	group by  bsu_subensamble
	ORDER BY bsu_subensamble
 OPEN @CursorVar


	FETCH NEXT FROM @CursorVar INTO @bsu_subensamble1

  WHILE (@@fetch_status = 0) 

  BEGIN  

			exec  SP_filltablaimplosion1 @BST_HIJO, @bsu_subensamble1, @bst_perini



	FETCH NEXT FROM @CursorVar INTO @bsu_subensamble1

END

	CLOSE @CursorVar
	DEALLOCATE @CursorVar



GO
