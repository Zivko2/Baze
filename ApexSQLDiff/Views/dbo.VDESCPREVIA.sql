SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






























































CREATE VIEW dbo.VDESCPREVIA
with encryption as
SELECT    TOP 100 PERCENT CANT=CASE WHEN dbo.BOM_DESCTEMP.BST_TIPOCOSTO='Z' and dbo.BOM_DESCTEMP.TI_CODIGO='E' THEN dbo.BOM_DESCTEMP.BST_INCORPOR * isnull(dbo.BOM_DESCTEMP.FACTCONV,1)
	else dbo.FACTEXPDET.FED_CANT * dbo.BOM_DESCTEMP.BST_INCORPOR * isnull(dbo.BOM_DESCTEMP.FACTCONV,1) end, dbo.BOM_DESCTEMP.BST_HIJO, 
          dbo.BOM_DESCTEMP.MA_TIP_ENS, dbo.BOM_DESCTEMP.BST_PERINI, dbo.BOM_DESCTEMP.BST_TIPOCOSTO, dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO,
	dbo.BOM_DESCTEMP.BST_PT
FROM         dbo.CONFIGURATFACT RIGHT OUTER JOIN
                      dbo.FACTEXP ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON MAESTRO_1.MA_CODIGO = dbo.FACTEXPDET.MA_CODIGO RIGHT OUTER JOIN
                      dbo.BOM_DESCTEMP LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_2 ON dbo.BOM_DESCTEMP.BST_HIJO = MAESTRO_2.MA_CODIGO ON 
                      dbo.FACTEXPDET.FED_INDICED = dbo.BOM_DESCTEMP.FED_INDICED ON dbo.FACTEXP.FE_CODIGO = dbo.BOM_DESCTEMP.FE_CODIGO
WHERE     (dbo.BOM_DESCTEMP.BST_DISCH = 'S') AND (dbo.BOM_DESCTEMP.BST_INCORPOR) > 0 AND dbo.FACTEXPDET.FED_CANT > 0
AND FE_PREVIADESC='N' AND (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.CONFIGURATFACT.CFF_TRAT = 'D') AND 
		                      (dbo.CONFIGURATFACT.CFF_TIPODESCARGA = 'A') 
ORDER BY dbo.FACTEXP.FE_FECHA, dbo.FACTEXP.FE_CODIGO






































































GO
