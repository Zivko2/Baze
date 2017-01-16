SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


/* cursor para todos los subensambles que estan en el nivel 1 */
CREATE PROCEDURE [dbo].[SP_CALCULABOMPESO1]  (@bst_pt int, @Nivel int)   as

SET NOCOUNT ON 

declare @bst_pertenece int, @Entravigor Datetime

declare cur_bstpeso1 cursor for
	SELECT     BST_PERTENECE, max(BST_PERINI)
	FROM         dbo.BOM_REP
	GROUP BY BST_PT, BST_PERTENECE, BST_NIVEL
	HAVING      (BST_PT = @bst_pt) AND (BST_NIVEL = @nivel)

open cur_bstpeso1


	FETCH NEXT FROM cur_bstpeso1 INTO @bst_pertenece, @Entravigor

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN


	EXEC SP_CALCULABOMPESOMP @BST_PERTENECE, @Entravigor


	FETCH NEXT FROM cur_bstpeso1 INTO @bst_pertenece, @Entravigor

END

CLOSE cur_bstpeso1
DEALLOCATE cur_bstpeso1






GO
