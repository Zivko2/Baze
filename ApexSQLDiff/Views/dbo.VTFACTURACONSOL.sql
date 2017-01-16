SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO































CREATE VIEW dbo.VTFACTURACONSOL
with encryption as
SELECT     dbo.TFACTURA.TF_CODIGO
FROM         dbo.RELTFACTCLAPED INNER JOIN
                      dbo.CLAVEPED ON dbo.RELTFACTCLAPED.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO INNER JOIN
                      dbo.TFACTURA ON dbo.RELTFACTCLAPED.TF_CODIGO = dbo.TFACTURA.TF_CODIGO
GROUP BY dbo.TFACTURA.TF_CODIGO, dbo.CLAVEPED.CP_CONSOLIDADO
HAVING      (dbo.CLAVEPED.CP_CONSOLIDADO = 'S')


































































GO
