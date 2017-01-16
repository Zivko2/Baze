SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




































CREATE VIEW dbo.VPREVIAFESINDESTFIN
with encryption as
SELECT     dbo.FACTEXP.FE_FOLIO, dbo.FACTEXP.FE_FECHA, dbo.TFACTURA.TF_NOMBRE, dbo.TENVIO.TN_DESCRIP, dbo.VPEDEXP.[PATENTE-FOLIO], 
                      dbo.VPEDEXP.PI_FEC_PAG, dbo.CLAVEPED.CP_CLAVE
FROM         dbo.CLAVEPED RIGHT OUTER JOIN
                      dbo.VPEDEXP ON dbo.CLAVEPED.CP_CODIGO = dbo.VPEDEXP.CP_CODIGO RIGHT OUTER JOIN
                      dbo.FACTEXP LEFT OUTER JOIN
                      dbo.TFACTURA ON dbo.FACTEXP.TF_CODIGO = dbo.TFACTURA.TF_CODIGO ON 
                      dbo.VPEDEXP.PI_CODIGO = dbo.FACTEXP.PI_CODIGO LEFT OUTER JOIN
                      dbo.TENVIO ON dbo.FACTEXP.TN_CODIGO = dbo.TENVIO.TN_CODIGO
WHERE     (dbo.FACTEXP.DI_DESTFIN IS NULL) AND dbo.FACTEXP.FE_CODIGO IN (SELECT FE_CODIGO FROM FACTEXPDET WHERE TI_CODIGO IN 
(SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO='P' OR CFT_TIPO='S'))






























































GO
