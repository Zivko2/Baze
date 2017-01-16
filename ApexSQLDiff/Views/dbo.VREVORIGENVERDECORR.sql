SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VREVORIGENVERDECORR
with encryption as
SELECT     dbo.REVORIGENREP.RV_CODIGO, dbo.FACTIMP.FI_CODIGO, SUM(dbo.REVORIGENCONTRIB.RVC_MONTO) AS RVC_MONTO
FROM         dbo.REVORIGENREP INNER JOIN
                      dbo.FACTIMP ON dbo.REVORIGENREP.RV_INICIO <= dbo.FACTIMP.FI_FECHA AND 
                      dbo.REVORIGENREP.RV_FINAL >= dbo.FACTIMP.FI_FECHA LEFT OUTER JOIN
                      dbo.REVORIGENCONTRIB ON dbo.FACTIMP.FI_CODIGO = dbo.REVORIGENCONTRIB.FI_CODIGO LEFT OUTER JOIN
                      dbo.REVORIGEN ON dbo.FACTIMP.FI_CODIGO = dbo.REVORIGEN.FI_CODIGO
WHERE     (dbo.REVORIGEN.RVF_DESPACHO = 'V')
GROUP BY dbo.REVORIGENREP.RV_CODIGO, dbo.FACTIMP.FI_CODIGO

































































GO
