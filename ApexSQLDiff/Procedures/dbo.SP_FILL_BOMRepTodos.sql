SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























/* inserta en la tabla BOM_REP  todos los bom's a todos los niveles, esto sirve solo para revision o calculo, para el reporte no sirve por el orden*/
CREATE PROCEDURE [dbo].[SP_FILL_BOMRepTodos] (@bst_entravigor varchar(10), @nivel int=1)   as

SET NOCOUNT ON 
DECLARE @EXISTE int


EXEC Sp_CreaTablaBOM_REP


--declare @bst_entravigor varchar(10)
--set @bst_entravigor='06/10/2005'



			INSERT INTO BOM_REP (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO,  ME_CODIGO, FACTCONV, 
				BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, PA_CODIGO, 
				BST_CODIGO, BST_NIVEL, BST_PERTENECE, BST_PT, BST_ENTRAVIGOR)


			SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
			                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
			                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
			                      dbo.BOM_STRUCT.BST_TIP_ENS,
				        dbo.MAESTRO.PA_ORIGEN, max(dbo.BOM_STRUCT.BST_CODIGO), @NIVEL, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, @BST_ENTRAVIGOR
			FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
			                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
			                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO 
			WHERE (dbo.CONFIGURATIPO.CFT_TIPO='P' or dbo.CONFIGURATIPO.CFT_TIPO='S') and dbo.BOM_STRUCT.BST_TIP_ENS<>'P'
			GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
			                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
			                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
			                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.MAESTRO.PA_ORIGEN
			HAVING dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <=  @BST_ENTRAVIGOR and dbo.BOM_STRUCT.BST_PERFIN>=  @BST_ENTRAVIGOR)
			AND dbo.BOM_STRUCT.BST_INCORPOR >0
			ORDER BY dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.BOM_STRUCT.BST_HIJO

inicio:
	INSERT INTO BOM_REP (BST_CODIGO, BST_PT, BST_PERTENECE,  BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO,  ME_CODIGO, FACTCONV, 
		BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, PA_CODIGO, 
		 BST_NIVEL)

	SELECT     BOM_STRUCT.BST_CODIGO, BOM_REP.BST_PT, BOM_STRUCT.BSU_SUBENSAMBLE, BOM_REP.BST_ENTRAVIGOR, 
	                      BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_INCORPOR*BOM_REP.BST_INCORPOR, BOM_STRUCT.BST_DISCH, MAESTRO.TI_CODIGO, BOM_STRUCT.ME_CODIGO, 
	                      BOM_STRUCT.FACTCONV, BOM_STRUCT.BST_PERINI, BOM_STRUCT.BST_PERFIN, BOM_STRUCT.ME_GEN, BOM_STRUCT.BST_TRANS, 
	                      MAESTRO.BST_TIPOCOSTO, BOM_REP.MA_TIP_ENS, BOM_REP.PA_CODIGO, @NIVEL+1
	FROM         BOM_REP INNER JOIN
	                      BOM_STRUCT ON BOM_REP.BST_HIJO = BOM_STRUCT.BSU_SUBENSAMBLE INNER JOIN MAESTRO ON
			      BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO
	WHERE     (BOM_REP.BST_NIVEL = @NIVEL) 


	SET @nivel=@nivel+1

	IF (SELECT     COUNT(BOM_STRUCT.BST_CODIGO)
	FROM         BOM_REP INNER JOIN
	                      BOM_STRUCT ON BOM_REP.BST_HIJO = BOM_STRUCT.BSU_SUBENSAMBLE
	WHERE     (BOM_REP.BST_NIVEL = @NIVEL)) >0
	set @existe=1
	else
	set @existe=0


	while (@existe>0)
	begin

		goto inicio


	end



	
	-- insercion de materias primas	
	INSERT INTO BOM_REP (BST_CODIGO, BST_PT, BST_PERTENECE,  BST_ENTRAVIGOR, BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO,  ME_CODIGO, FACTCONV, 
		BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, PA_CODIGO, 
		 BST_NIVEL)

	SELECT     BOM_STRUCT.BST_CODIGO, BOM_REP.BST_PT, BOM_STRUCT.BSU_SUBENSAMBLE, BOM_REP.BST_ENTRAVIGOR, 
	                      BOM_STRUCT.BST_HIJO, BOM_STRUCT.BST_INCORPOR, BOM_STRUCT.BST_DISCH, MAESTRO.TI_CODIGO, BOM_STRUCT.ME_CODIGO, 
	                      BOM_STRUCT.FACTCONV, BOM_STRUCT.BST_PERINI, BOM_STRUCT.BST_PERFIN, BOM_STRUCT.ME_GEN, BOM_STRUCT.BST_TRANS, 
	                      MAESTRO.BST_TIPOCOSTO, BOM_REP.MA_TIP_ENS, BOM_REP.PA_CODIGO, BOM_REP.BST_NIVEL+1
	FROM         BOM_REP INNER JOIN
	                      BOM_STRUCT ON BOM_REP.BST_HIJO = BOM_STRUCT.BSU_SUBENSAMBLE LEFT OUTER JOIN
	                       MAESTRO ON BOM_STRUCT.BST_HIJO = MAESTRO.MA_CODIGO LEFT OUTER JOIN 
				CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO 
	WHERE (dbo.CONFIGURATIPO.CFT_TIPO<>'P' AND dbo.CONFIGURATIPO.CFT_TIPO<>'S')


	-- insercion de materias primas de productos que no contienen subensambles
	INSERT INTO BOM_REP (BST_HIJO, BST_INCORPOR, BST_DISCH, TI_CODIGO,  ME_CODIGO, FACTCONV, 
		BST_PERINI, BST_PERFIN, ME_GEN, BST_TRANS, BST_TIPOCOSTO, MA_TIP_ENS, PA_CODIGO, 
		BST_CODIGO, BST_NIVEL, BST_PERTENECE, BST_PT, BST_ENTRAVIGOR, bst_tipo, SPI_CODIGO, SPI_PT)


	SELECT     dbo.BOM_STRUCT.BST_HIJO, SUM(dbo.BOM_STRUCT.BST_INCORPOR) AS BST_INCORPOR, dbo.BOM_STRUCT.BST_DISCH, 
	                      dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, 
	                      dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, 
	                      dbo.BOM_STRUCT.BST_TIP_ENS,
		        dbo.MAESTRO.PA_ORIGEN, max(dbo.BOM_STRUCT.BST_CODIGO), 1, BSU_SUBENSAMBLE, BSU_SUBENSAMBLE, @BST_ENTRAVIGOR, 'C', 
		     22, 22
	FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
	                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	WHERE (dbo.CONFIGURATIPO.CFT_TIPO<>'P' and dbo.CONFIGURATIPO.CFT_TIPO<>'S') and dbo.BOM_STRUCT.BST_TIP_ENS='C'
	AND  BSU_SUBENSAMBLE NOT IN (SELECT BSU_SUBENSAMBLE  from bom_struct left outer join maestro on bom_struct.bst_hijo=maestro.ma_codigo
				    WHERE TI_CODIGO=16 AND (BST_TIP_ENS='F' or BST_TIP_ENS='A'))
	GROUP BY dbo.BOM_STRUCT.BST_HIJO, dbo.BOM_STRUCT.BST_DISCH, dbo.CONFIGURATIPO.CFT_TIPO, dbo.BOM_STRUCT.ME_CODIGO, 
	                      dbo.BOM_STRUCT.FACTCONV, dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN, dbo.BOM_STRUCT.ME_GEN, 
	                      dbo.BOM_STRUCT.BST_TRANS, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_TIP_ENS, dbo.BOM_STRUCT.BSU_SUBENSAMBLE, 
	                      dbo.BOM_STRUCT.BST_INCORPOR, dbo.MAESTRO.PA_ORIGEN
	HAVING      dbo.BOM_STRUCT.BST_HIJO IS NOT NULL AND (dbo.BOM_STRUCT.BST_PERINI <=  @bst_entravigor and dbo.BOM_STRUCT.BST_PERFIN>=  @bst_entravigor)
	AND dbo.BOM_STRUCT.BST_INCORPOR >0
	ORDER BY dbo.BOM_STRUCT.BST_HIJO

























GO
