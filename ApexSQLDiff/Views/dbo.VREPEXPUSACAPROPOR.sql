SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



















































CREATE VIEW dbo.VREPEXPUSACAPROPOR
with encryption as
SELECT     SUM(ISNULL(dbo.VREPEXPNACIONAL.KAP_CANTDESC, 0) + dbo.VREPEXPUSACA.KAP_CANTDESC) AS sumanacional, 
                      dbo.VREPEXPUSACA.RUC_CODIGO, SUM(dbo.VREPEXPUSACA.KAP_CANTDESC * 100) AS sumatransferencia
FROM         dbo.VREPEXPUSACA RIGHT OUTER JOIN
                      dbo.REPEXPUSACA ON dbo.VREPEXPUSACA.RUC_CODIGO = dbo.REPEXPUSACA.RUC_CODIGO LEFT OUTER JOIN
                      dbo.VREPEXPNACIONAL ON dbo.REPEXPUSACA.RUC_CODIGO = dbo.VREPEXPNACIONAL.RUC_CODIGO
GROUP BY dbo.VREPEXPUSACA.RUC_CODIGO



































































GO
