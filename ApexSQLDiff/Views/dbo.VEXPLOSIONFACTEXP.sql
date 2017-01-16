SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











































CREATE VIEW dbo.VEXPLOSIONFACTEXP
with encryption as
SELECT     dbo.FACTEXPDET.FE_CODIGO, dbo.BOM_DESCTEMP.BST_PT, dbo.BOM_DESCTEMP.BST_HIJO, dbo.BOM_DESCTEMP.ME_CODIGO, 
                      dbo.BOM_DESCTEMP.FACTCONV, dbo.BOM_DESCTEMP.ME_GEN, SUM(dbo.BOM_DESCTEMP.BST_INCORPOR * dbo.FACTEXPDET.FED_CANT) 
                      AS CANTIDAD, dbo.BOM_DESCTEMP.TI_CODIGO AS CFT_TIPO, dbo.MAESTRO.TI_CODIGO
FROM         dbo.MAESTRO RIGHT OUTER JOIN
                      dbo.BOM_DESCTEMP ON dbo.MAESTRO.MA_CODIGO = dbo.BOM_DESCTEMP.BST_HIJO RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.BOM_DESCTEMP.FED_INDICED = dbo.FACTEXPDET.FED_INDICED
WHERE     (dbo.BOM_DESCTEMP.BST_DISCH = 'S') AND
((dbo.BOM_DESCTEMP.TI_CODIGO <> 'S' AND dbo.BOM_DESCTEMP.TI_CODIGO <> 'P' AND dbo.BOM_DESCTEMP.MA_TIP_ENS<>'C') OR
(dbo.BOM_DESCTEMP.TI_CODIGO = 'S' AND dbo.BOM_DESCTEMP.MA_TIP_ENS='C'))
GROUP BY dbo.FACTEXPDET.FE_CODIGO, dbo.BOM_DESCTEMP.BST_HIJO, dbo.BOM_DESCTEMP.ME_CODIGO, dbo.BOM_DESCTEMP.FACTCONV, 
                      dbo.BOM_DESCTEMP.ME_GEN, dbo.BOM_DESCTEMP.BST_PT, dbo.MAESTRO.TI_CODIGO, dbo.BOM_DESCTEMP.TI_CODIGO



































































GO
