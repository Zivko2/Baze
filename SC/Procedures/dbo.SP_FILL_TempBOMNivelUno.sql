SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* inserta en la tabla TempBOM_NIVEL  los del nivel 1 el bom  para calculo de costos*/
CREATE PROCEDURE [dbo].[SP_FILL_TempBOMNivelUno] (@BST_PT Int, @bst_entravigor varchar(10), @uservar varchar(50)='1', @MENSAJE1 char(1)='N' output)   as

SET NOCOUNT ON 

DECLARE @BST_HIJO int, @BST_INCORPOR decimal(38,6), @BST_PTvar varchar(50), @BST_HIJOvar varchar(50), @BST_INCORPORvar varchar(50)

set @MENSAJE1='N'


select @BST_PTvar=convert(varchar(50),@BST_PT)


exec('DELETE FROM TempBOM_NIVEL'+@uservar+' WHERE BST_PT='+@BST_PTvar)


	exec('insert into TempBOM_NIVEL'+@uservar+'(BST_PT, BST_HIJO, BST_PERINI, BST_NIVEL, BST_PERTENECE, BST_INCORPOR, BST_INCORPORUSO)
	values
	('+@BST_PTvar+', '+@BST_PTvar+', '''+@bst_entravigor+''', 0, '+@BST_PTvar+', 1, 1)')

declare CUR_BOMSTRUCT cursor for

SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR)
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE (dbo.CONFIGURATIPO.CFT_TIPO='P' OR dbo.CONFIGURATIPO.CFT_TIPO='S') AND dbo.BOM_STRUCT.BST_TIP_ENS<>'P' AND dbo.BOM_STRUCT.BST_TIP_ENS<>'C'
	 AND (dbo.BOM_STRUCT.BSU_SUBENSAMBLE = @BST_PT) 
	AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>=  @BST_ENTRAVIGOR)
	AND dbo.BOM_STRUCT.BST_INCORPOR >0
GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_PERINI
ORDER BY dbo.BOM_STRUCT.BST_HIJO


 OPEN CUR_BOMSTRUCT


	FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR

  WHILE (@@fetch_status = 0) 

  BEGIN  
			select @BST_HIJOvar =convert(varchar(50), @BST_HIJO), @BST_INCORPORvar =convert(varchar(50), @BST_INCORPOR)




			exec('insert into TempBOM_NIVEL'+@uservar+'(BST_PT,  BST_HIJO, BST_PERINI, BST_NIVEL, BST_PERTENECE, BST_INCORPOR, BST_INCORPORUSO)
			values
			('+@BST_PTvar+', '+@BST_HIJOvar+', '''+@bst_entravigor+''', 1, '+@BST_PTvar+', '+@BST_INCORPORvar+', '+@BST_INCORPORvar+')')


			exec  SP_FILL_TempBOMNivelUno1 @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR, 1, @BST_INCORPOR, @uservar, @MENSAJE=@MENSAJE1 OUTPUT

			if @MENSAJE1='S'
			begin				
				--print @MENSAJE1
				break
			end
	




	FETCH NEXT FROM CUR_BOMSTRUCT INTO @BST_HIJO, @BST_INCORPOR
END

	CLOSE CUR_BOMSTRUCT
	DEALLOCATE CUR_BOMSTRUCT




























GO
