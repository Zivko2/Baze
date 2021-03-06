SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

/* inserta en la tabla TempBOM_NIVEL  los del nivel 1 el bom  para calculo de costos*/
CREATE PROCEDURE [dbo].[SP_FILL_TempBOMNivel] (@BST_PT Int, @bst_entravigor varchar(10), @MENSAJE1 char(1)='N' output)   as

SET NOCOUNT ON 

DECLARE @BST_HIJO int, @BST_INCORPOR decimal(38,6)

set @MENSAJE1='N'



DELETE FROM TempBOM_NIVEL WHERE BST_PT=@BST_PT


	insert into TempBOM_NIVEL(BST_PT, BST_HIJO, BST_PERINI, BST_NIVEL, BST_PERTENECE, BST_INCORPOR, BST_INCORPORUSO)
	values
	(@BST_PT, @BST_PT, @bst_entravigor, 0, @BST_PT, 1, 1)

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


			insert into TempBOM_NIVEL(BST_PT,  BST_HIJO, BST_PERINI, BST_NIVEL, BST_PERTENECE, BST_INCORPOR, BST_INCORPORUSO)
			values
			(@BST_PT, @BST_HIJO, @bst_entravigor, 1, @BST_PT, @BST_INCORPOR, @BST_INCORPOR)


			exec  SP_FILL_TempBOMNivel1 @BST_PT, @BST_HIJO, @BST_ENTRAVIGOR, 1, @BST_INCORPOR, @MENSAJE=@MENSAJE1 OUTPUT

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
