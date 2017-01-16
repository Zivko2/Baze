SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





























CREATE VIEW dbo.VSINPERMISOBOMALL
with encryption as
SELECT     dbo.BOM_REP.BST_HIJO, dbo.BOM_REP.BST_PT
FROM         dbo.BOM_REP LEFT OUTER JOIN
                      dbo.VPERMISOMATERIALES ON dbo.BOM_REP.BST_HIJO = dbo.VPERMISOMATERIALES.MA_CODIGO
WHERE     (dbo.VPERMISOMATERIALES.MA_CODIGO IS NULL) AND (dbo.BOM_REP.TI_CODIGO <> 'S')
GROUP BY dbo.BOM_REP.BST_HIJO, dbo.BOM_REP.BST_PT





























GO
