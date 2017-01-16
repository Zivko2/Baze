SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_temp_fillatablabom7]   as

SET NOCOUNT ON 

	insert into bom (ma_subensamble, bm_percambio)
	SELECT     BSU_SUBENSAMBLE, 'N'
	FROM         BOM_STRUCT
	GROUP BY BSU_SUBENSAMBLE


	exec sp_temp_bom_costo

	/*UPDATE dbo.BOM_STRUCT
	SET     dbo.BOM_STRUCT.BST_PESO_KG= round(dbo.MAESTRO.MA_PESO_KG,6)
	FROM         dbo.BOM_STRUCT INNER JOIN
             dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO AND dbo.BOM_STRUCT.ME_CODIGO = dbo.MAESTRO.ME_COM
	WHERE  dbo.MAESTRO.MA_PESO_KG>0*/



























GO
