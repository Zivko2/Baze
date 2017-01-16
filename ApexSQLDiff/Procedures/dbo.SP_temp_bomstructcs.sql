SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_temp_bomstructcs]   as

SET NOCOUNT ON 

	UPDATE dbo.BOM_STRUCT
	SET     dbo.BOM_STRUCT.BST_TIP_ENS= dbo.MAESTRO.MA_TIP_ENS
	FROM         dbo.BOM_STRUCT INNER JOIN
	                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO
	WHERE dbo.BOM_STRUCT.BST_TIP_ENS IS NULL
	
	UPDATE dbo.BOM_STRUCT
	SET     dbo.BOM_STRUCT.ME_GEN= MAESTRO_1.ME_COM
	FROM         dbo.BOM_STRUCT INNER JOIN
	                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO INNER JOIN
	                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
	WHERE dbo.BOM_STRUCT.ME_GEN IS NULL


	update factexpdet
	set cs_codigo=8
	where cs_codigo is null
	
	update factimpdet
	set cs_codigo=8
	where cs_codigo is null
	
	UPDATE dbo.BOM_STRUCT
	SET     dbo.BOM_STRUCT.BST_TIP_ENS='C'
	FROM         dbo.BOM_STRUCT INNER JOIN
	                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	WHERE     (dbo.BOM_STRUCT.BST_TIP_ENS IS NULL) AND (dbo.MAESTRO.MA_CODIGO IS NULL) AND (dbo.CONFIGURATIPO.CFT_TIPO <> 'S' AND 
	                      dbo.CONFIGURATIPO.CFT_TIPO <> 'P')
	
	UPDATE dbo.BOM_STRUCT
	SET     dbo.BOM_STRUCT.BST_TIP_ENS='F'
	FROM         dbo.BOM_STRUCT INNER JOIN
	                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	                      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	WHERE     (dbo.BOM_STRUCT.BST_TIP_ENS IS NULL) AND (dbo.MAESTRO.MA_CODIGO IS NULL) AND (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR 
	                      dbo.CONFIGURATIPO.CFT_TIPO = 'P')


	UPDATE dbo.FACTEXPDET
	SET     dbo.FACTEXPDET.FED_TIP_ENS= dbo.MAESTRO.MA_TIP_ENS
	FROM         dbo.FACTEXPDET INNER JOIN
	                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO
	WHERE     (dbo.FACTEXPDET.FED_TIP_ENS IS NULL)
	
	UPDATE dbo.FACTEXPDET
	SET     dbo.FACTEXPDET.ME_GENERICO= dbo.MAESTRO.ME_COM
	FROM         dbo.FACTEXPDET INNER JOIN
	                      dbo.MAESTRO ON dbo.FACTEXPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO
	WHERE     (dbo.FACTEXPDET.ME_GENERICO IS NULL)
	
	
	UPDATE dbo.FACTIMPDET
	SET     dbo.FACTIMPDET.ME_GEN= dbo.MAESTRO.ME_COM
	FROM         dbo.FACTIMPDET INNER JOIN
	                      dbo.MAESTRO ON dbo.FACTIMPDET.MA_GENERICO = dbo.MAESTRO.MA_CODIGO
	WHERE     (dbo.FACTIMPDET.ME_GEN IS NULL)



























GO
