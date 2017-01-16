SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
/* cursor para todos los subensambles que estan en el nivel 2 */
CREATE PROCEDURE [dbo].[SP_CALCULABOMCOSTO2]  (@bst_pt int, @nivel int, @Entravigor datetime, @GuardaHist char(1), @spi_codigo int, @uservar varchar(50), @tco_codigovar varchar(50))   as

SET NOCOUNT ON 




declare @bst_pertenece int, @nivel2 int, @bst_ptvar varchar(50), @nivel2var varchar(50)



	DECLARE @cur_bstpertenece2 CURSOR
	SET @cur_bstpertenece2 = CURSOR SCROLL DYNAMIC FOR
		select @nivel-1
	open @cur_bstpertenece2
	
	
		FETCH NEXT FROM @cur_bstpertenece2 INTO @nivel2
	
		WHILE (@@FETCH_STATUS = 0) 
		BEGIN
	
		if @nivel2 > 0
	
		begin
			select @bst_ptvar =convert(varchar(50), @bst_pt), @nivel2var =convert(varchar(50), @nivel2)
	
			exec('TRUNCATE TABLE CalculandoCosto'+@uservar)
		
				exec('insert into CalculandoCosto'+@uservar+' (BST_PERTENECE, BST_PERINI)
				SELECT     BST_HIJO, '''+@Entravigor+'''
				FROM         TempBOM_NIVEL'+@uservar+' 
				WHERE (BST_PT = '+@bst_ptvar+') AND (BST_NIVEL = '+@nivel2var+')
				GROUP BY BST_HIJO')
	
			EXEC SP_CALCULABOMCOSTOSUBUno @GuardaHist, @bst_pt, @spi_codigo, @uservar, @tco_codigovar
	
		
			EXEC SP_CALCULABOMCOSTO2 @bst_pt, @nivel2, @Entravigor, @GuardaHist, @spi_codigo, @uservar, @tco_codigovar
	
		end
	
		FETCH NEXT FROM @cur_bstpertenece2 INTO @nivel2
	
	END
	
	CLOSE @cur_bstpertenece2
	DEALLOCATE @cur_bstpertenece2



		exec('TRUNCATE TABLE CalculandoCosto'+@uservar)


























GO
