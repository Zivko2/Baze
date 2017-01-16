SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































/* inserta en la tabla TempBOM_NIVEL los del nivel diferentes del 1 el bom  para calculo de costos */
CREATE PROCEDURE [dbo].[SP_FILL_TempBOMNivelUno1] (@BST_PT INT, @BST_HIJO INT, @BST_ENTRAVIGOR DATETIME, @nivel int, @BST_INCORPOR decimal(38,6), @uservar varchar(50), @mensaje char(1) output)   as

SET NOCOUNT ON 
declare @BST_HIJO1 int, @nivelr INT, @BST_INCORPOR1 decimal(38,6), @BST_INCORPOR2 decimal(38,6), @BST_HIJOvar varchar(50), @BST_HIJO1var varchar(50), @BST_INCORPOR1var varchar(50), @BST_INCORPOR2var varchar(50)

	SET @nivelr=@nivel+1



			select @BST_HIJOvar =convert(varchar(50), @BST_HIJO)

DECLARE @CursorVar CURSOR

SET @CursorVar = CURSOR SCROLL DYNAMIC FOR

SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR)
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE (dbo.CONFIGURATIPO.CFT_TIPO='P' OR dbo.CONFIGURATIPO.CFT_TIPO='S') AND dbo.BOM_STRUCT.BST_TIP_ENS<>'P' AND dbo.BOM_STRUCT.BST_TIP_ENS<>'C'
	AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_HIJO)
	AND (dbo.BOM_STRUCT.BST_HIJO IS NOT NULL) AND dbo.BOM_STRUCT.BST_PERINI<=@BST_ENTRAVIGOR AND dbo.BOM_STRUCT.BST_PERFIN>=@BST_ENTRAVIGOR
	AND dbo.BOM_STRUCT.BST_INCORPOR >0
GROUP BY dbo.BOM_STRUCT.BST_HIJO

ORDER BY dbo.BOM_STRUCT.BST_HIJO

 OPEN @CursorVar
  FETCH NEXT FROM @CursorVar INTO @BST_HIJO1, @BST_INCORPOR1

  WHILE (@@fetch_status = 0) 
  BEGIN  

	SET @BST_INCORPOR2 =@BST_INCORPOR*@BST_INCORPOR1

		IF  @BST_HIJO1<> @BST_HIJO
		begin
			select @BST_HIJO1var =convert(varchar(50), @BST_HIJO1), @BST_INCORPOR1var =convert(varchar(50), @BST_INCORPOR1), @BST_INCORPOR2var =convert(varchar(50), @BST_INCORPOR2)


			exec('insert into TempBOM_NIVEL'+@uservar+'(BST_PT, BST_PERINI, BST_NIVEL, BST_PERTENECE, BST_HIJO, BST_INCORPOR, BST_INCORPORUSO)
			values
			('+@BST_PT+', '''+@bst_entravigor+''', '+@nivelr+', '+@BST_HIJOvar+', '+@BST_HIJO1var+', '+@BST_INCORPOR2var+', '+@BST_INCORPOR1var+')')

		end
			if @@NESTLEVEL <32
			exec  SP_FILL_TempBOMNivelUno1 @BST_PT, @BST_HIJO1, @BST_ENTRAVIGOR, @nivelr, @BST_INCORPOR1, @uservar, @mensaje=@mensaje output
			else
			begin
				set @mensaje='S'
				break
			end





  FETCH NEXT FROM @CursorVar INTO @BST_HIJO1, @BST_INCORPOR1
END
	CLOSE @CursorVar
	DEALLOCATE @CursorVar




























GO
