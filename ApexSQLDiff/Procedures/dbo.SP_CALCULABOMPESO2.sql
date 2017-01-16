SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* cursor para todos los subensambles que estan en el nivel 2 */
CREATE PROCEDURE [dbo].[SP_CALCULABOMPESO2]  (@bst_pt int, @nivel int)   as

SET NOCOUNT ON 

declare @bst_pertenece int, @Entravigor datetime, @nivel2 int

DECLARE @cur_bstpeso2 CURSOR
SET @cur_bstpeso2 = CURSOR SCROLL DYNAMIC FOR

	SELECT     BST_PERTENECE, MAX(BST_PERINI), (BST_NIVEL)
	FROM         BOM_REP
	GROUP BY BST_PT, BST_PERTENECE, BST_NIVEL
	HAVING      (BST_PT = @bst_pt) AND (BST_NIVEL = @nivel-1)
open @cur_bstpeso2


	FETCH NEXT FROM @cur_bstpeso2 INTO @bst_pertenece, @Entravigor, @nivel2

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	if @nivel2 > 0
	begin

		EXEC SP_CALCULABOMPESOMP @BST_PERTENECE, @Entravigor
	
		EXEC SP_CALCULABOMPESO2 @bst_pt, @nivel2

	end
	FETCH NEXT FROM @cur_bstpeso2 INTO @bst_pertenece, @Entravigor, @nivel2

END

CLOSE @cur_bstpeso2
DEALLOCATE @cur_bstpeso2


GO
