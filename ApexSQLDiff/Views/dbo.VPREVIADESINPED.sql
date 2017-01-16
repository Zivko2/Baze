SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE VIEW dbo.VPREVIADESINPED
with encryption as
SELECT     TOP 100 PERCENT dbo.FACTIMP.FI_FOLIO, dbo.FACTIMP.FI_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.CLIENTE.CL_RAZON
FROM         dbo.FACTIMP LEFT OUTER JOIN
                      dbo.CONFIGURATFACT ON dbo.FACTIMP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO LEFT OUTER JOIN
                      dbo.CLIENTE ON dbo.FACTIMP.PR_CODIGO = dbo.CLIENTE.CL_CODIGO LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTIMP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO
WHERE     (dbo.FACTIMP.PI_CODIGO = 0 OR
                      dbo.FACTIMP.PI_CODIGO = - 1) AND (dbo.FACTIMP.FI_CANCELADO = 'N') AND (dbo.CONFIGURATFACT.CFF_TIPO <> 'ID' AND 
                      dbo.CONFIGURATFACT.CFF_TIPO <> 'TA' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'IA' AND dbo.CONFIGURATFACT.CFF_TIPO <> 'RS')
ORDER BY dbo.FACTIMP.FI_FECHA, dbo.FACTIMP.FI_FOLIO



































































GO
