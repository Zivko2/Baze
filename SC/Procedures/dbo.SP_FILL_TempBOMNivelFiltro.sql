SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































/* inserta en la tabla TempBOM_NIVEL  para calculo de costos, la diferencia con el procedimiento SP_FILL_TempBOMNivelTodos 
es que este procedimiento solo explosiona los que esten incluidos en la tabla #calculabom*/
CREATE PROCEDURE [dbo].[SP_FILL_TempBOMNivelFiltro] (@BST_ENTRAVIGOR DATETIME, @nivel INT=1)   as

--SET NOCOUNT ON 

DECLARE @existe INT


--	delete from TempBOM_NIVEL
	exec Sp_CreaTablaTempBOM_NIVEL

	delete from bom_struct where bsu_subensamble = bst_hijo



	insert into TempBOM_NIVEL(BST_PT,  BST_NIVEL, BST_PERTENECE, BST_HIJO, BST_PERINI, BST_INCORPOR, BST_INCORPORUSO)
	SELECT     dbo.BOM_STRUCT.BSU_SUBENSAMBLE, @nivel, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.BOM_STRUCT.BSU_SUBENSAMBLE,@BST_ENTRAVIGOR, 1, 1
	FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	WHERE (dbo.CONFIGURATIPO.CFT_TIPO='P' OR dbo.CONFIGURATIPO.CFT_TIPO='S') 
		AND dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
		AND dbo.BOM_STRUCT.BST_INCORPOR >0 and dbo.BOM_STRUCT.BSU_SUBENSAMBLE in (select MA_CODIGO from #calculabom)
	GROUP BY dbo.BOM_STRUCT.BSU_SUBENSAMBLE
	ORDER BY dbo.BOM_STRUCT.BSU_SUBENSAMBLE

	SET @nivel=@nivel+1

	insert into TempBOM_NIVEL(BST_PT,  BST_NIVEL, BST_PERTENECE, BST_HIJO, BST_PERINI, BST_INCORPOR, BST_INCORPORUSO)
	SELECT TempBOM_NIVEL.BST_PT, @nivel, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, BOM_STRUCT.BST_HIJO, @BST_ENTRAVIGOR, SUM(dbo.BOM_STRUCT.BST_INCORPOR)*SUM(TempBOM_NIVEL.BST_INCORPOR), SUM(TempBOM_NIVEL.BST_INCORPOR) 
	FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	      INNER JOIN TempBOM_NIVEL ON TempBOM_NIVEL.BST_PERTENECE=BOM_STRUCT.BSU_SUBENSAMBLE
	WHERE (CONFIGURATIPO.CFT_TIPO='P' OR CONFIGURATIPO.CFT_TIPO='S') AND BOM_STRUCT.BST_TIP_ENS<>'P' AND BOM_STRUCT.BST_TIP_ENS<>'C'
		AND BOM_STRUCT.BST_HIJO IS NOT NULL AND (BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and BOM_STRUCT.BST_PERFIN>=  @BST_ENTRAVIGOR)
		AND BOM_STRUCT.BST_INCORPOR >0
		AND TempBOM_NIVEL.BST_NIVEL=@nivel-1
	GROUP BY BOM_STRUCT.BST_HIJO, TempBOM_NIVEL.BST_PT, dbo.BOM_STRUCT.BSU_SUBENSAMBLE
	ORDER BY BOM_STRUCT.BST_HIJO


	SET @nivel=@nivel+1




	exec sp_droptable  'TempBOM_STRUCT'

	SELECT     BSU_SUBENSAMBLE, BST_HIJO, @BST_ENTRAVIGOR as BST_PERINI, SUM(BST_INCORPOR) AS BST_INCORPOR
	INTO dbo.TempBOM_STRUCT
	FROM         BOM_STRUCT LEFT OUTER JOIN
	                      MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
	WHERE    CFT_TIPO IN ('P', 'S') AND BOM_STRUCT.BST_INCORPOR >0
		AND BOM_STRUCT.BST_TIP_ENS<>'P' AND BOM_STRUCT.BST_TIP_ENS<>'C' and BOM_STRUCT.BST_HIJO IS NOT NULL 
		AND (BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and BOM_STRUCT.BST_PERFIN>= @BST_ENTRAVIGOR)
	GROUP BY BSU_SUBENSAMBLE, BST_HIJO


inicio:

	--print @nivel
		insert into TempBOM_NIVEL(BST_PT,  BST_NIVEL, BST_PERTENECE, BST_HIJO, BST_PERINI, BST_INCORPOR, BST_INCORPORUSO)
		SELECT TempBOM_NIVEL.BST_PT, @nivel, TempBOM_STRUCT.BSU_SUBENSAMBLE, TempBOM_STRUCT.BST_HIJO, @BST_ENTRAVIGOR, SUM(TempBOM_STRUCT.BST_INCORPOR), SUM(TempBOM_STRUCT.BST_INCORPOR)
		FROM  TempBOM_STRUCT INNER JOIN TempBOM_NIVEL 
		      ON TempBOM_NIVEL.BST_HIJO=TempBOM_STRUCT.BSU_SUBENSAMBLE
		WHERE TempBOM_NIVEL.BST_NIVEL=@nivel-1
		GROUP BY TempBOM_STRUCT.BST_HIJO, TempBOM_NIVEL.BST_PT, TempBOM_STRUCT.BSU_SUBENSAMBLE
		ORDER BY TempBOM_STRUCT.BST_HIJO


		SET @nivel=@nivel+1

		if (SELECT COUNT(TempBOM_STRUCT.BST_HIJO)
		FROM  TempBOM_STRUCT 
		      INNER JOIN TempBOM_NIVEL ON TempBOM_NIVEL.BST_HIJO=TempBOM_STRUCT.BSU_SUBENSAMBLE
		WHERE TempBOM_NIVEL.BST_NIVEL=@nivel-1)>0

		set @existe=1
		else
		set @existe=0


	while (@existe>0)
	begin

		goto inicio


	end

	exec sp_droptable  'TempBOM_STRUCT'


























GO
