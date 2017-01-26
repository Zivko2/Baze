SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.[Facturas de Exportacion]
AS
SELECT     TOP 100 PERCENT dbo.FACTEXP.FE_FOLIO AS Factura, dbo.FACTEXP.FE_FECHA AS Fecha, dbo.FACTEXPDET.FED_NOPARTE AS NoParte, 
                      dbo.FACTEXPDET.FED_CANT AS Cantidad, dbo.FACTEXPDET.FED_GRA_ADD AS MPAnadidaGrav, 
                      dbo.FACTEXPDET.FED_NG_ADD AS MPAnadidaNoGrav, dbo.FACTEXPDET.FED_GRA_MP AS MPGrav, dbo.FACTEXPDET.FED_GRA_MO AS MOGrav, 
                      dbo.FACTEXPDET.FED_GRA_EMP AS EmpaqueGrav, dbo.FACTEXPDET.FED_NG_MP AS MPNoGrav, 
                      dbo.FACTEXPDET.FED_NG_EMP AS EmpaqueNoGrav, dbo.FACTEXPDET.FED_COS_UNI AS CostoUnit, 
                      dbo.FACTEXPDET.FED_COS_TOT AS CostoTotal
FROM         dbo.FACTEXPDET INNER JOIN
                      dbo.FACTEXP ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
WHERE     (dbo.FACTEXP.FE_FECHA > CONVERT(DATETIME, '2004-01-01 00:00:00', 102) AND dbo.FACTEXP.FE_FECHA < CONVERT(DATETIME, 
                      '2004-02-21 00:00:00', 102))
ORDER BY dbo.FACTEXP.FE_FECHA
GO
