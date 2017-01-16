SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































/* cursor para todos los subensambles que estan en el nivel 2 */
CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTO2Todos]  (@nivel int, @GuardaHist char(1), @spi_codigo int)   as

SET NOCOUNT ON 

declare @bst_pertenece int, @Entravigor datetime, @nivel2 int

DECLARE @cur_bstpertenece2 CURSOR
SET @cur_bstpertenece2 = CURSOR SCROLL DYNAMIC FOR
	select @nivel-1

open @cur_bstpertenece2


	FETCH NEXT FROM @cur_bstpertenece2 INTO @nivel2

	WHILE (@@FETCH_STATUS = 0) 
	BEGIN

	if @nivel2 > 0

	begin
		TRUNCATE TABLE CalculandoCosto
	
		begin tran
			insert into CalculandoCosto(BST_PERTENECE, BST_PERINI)
			SELECT     BST_HIJO, MAX(BST_PERINI) as BST_PERINI
			FROM         TempBOM_NIVEL
			WHERE (BST_NIVEL = @nivel2)
			GROUP BY BST_HIJO
		commit tran

		EXEC SP_CALCULABOMCOSTOSUB @GuardaHist, @spi_codigo
	
		EXEC SP_CALCULABOMCOSTO2Todos  @nivel2, @GuardaHist, @spi_codigo

	end

	FETCH NEXT FROM @cur_bstpertenece2 INTO @nivel2

END

CLOSE @cur_bstpertenece2
DEALLOCATE @cur_bstpertenece2

	TRUNCATE TABLE CalculandoCosto


























GO
