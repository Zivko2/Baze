SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.[revision de bom]
AS
SELECT     TOP 100 PERCENT dbo.BOM_STRUCT.BSU_NOPARTE, dbo.BOM_STRUCT.BST_NOPARTE, dbo.BOM_STRUCT.BST_PERINI, 
                      dbo.BOM_STRUCT.BST_PERFIN, dbo.[ultima fecha desc].fecha, dbo.BOM_STRUCT.BST_INCORPOR
FROM         dbo.BOM_STRUCT INNER JOIN
                      dbo.[ultima importacion] ON dbo.BOM_STRUCT.BST_NOPARTE = dbo.[ultima importacion].PID_NOPARTE INNER JOIN
                      dbo.[ultima fecha desc] ON dbo.[ultima importacion].MA_CODIGO = dbo.[ultima fecha desc].MA_HIJO LEFT OUTER JOIN
                      dbo.mapt53 ON dbo.BOM_STRUCT.BST_NOPARTE = dbo.mapt53.Col002
WHERE     (dbo.mapt53.Col002 IS NULL)
ORDER BY dbo.BOM_STRUCT.BST_NOPARTE, dbo.BOM_STRUCT.BSU_NOPARTE, dbo.BOM_STRUCT.BST_PERFIN
GO
