SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE VIEW dbo.VBOM_COSTO
with encryption as
SELECT     dbo.BOM_STRUCT.BSU_SUBENSAMBLE, SUM(VMAESTROCOST.MA_COSTO) AS BC_COS_UNI, dbo.MAESTRO.BST_TIPOCOSTO, 
                      dbo.BOM_STRUCT.BST_PERINI, dbo.BOM_STRUCT.BST_PERFIN
FROM         dbo.BOM_STRUCT LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.BOM_STRUCT.BST_HIJO = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
	VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
GROUP BY dbo.BOM_STRUCT.BSU_SUBENSAMBLE, dbo.MAESTRO.BST_TIPOCOSTO, dbo.BOM_STRUCT.BST_PERINI, 
                      dbo.BOM_STRUCT.BST_PERFIN
HAVING      (dbo.BOM_STRUCT.BST_PERINI <= convert(datetime, convert(varchar(11), getdate(),101))) AND (dbo.BOM_STRUCT.BST_PERFIN >= convert(datetime, convert(varchar(11), getdate(),101)))


GO
