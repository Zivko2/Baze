SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



























CREATE VIEW dbo.VPEDIMPCONTRIBNORMAL
with encryption as
SELECT     dbo.CONTRIBUCION.CON_ABREVIA, dbo.TPAGO.PG_DESC, dbo.VPEDIMPCONTRIBUCION.PIT_CONTRIBTOTMN, 
                      dbo.VPEDIMPCONTRIBUCION.PI_CODIGO
FROM         dbo.VPEDIMPCONTRIBUCION INNER JOIN
                      dbo.CONTRIBUCION ON dbo.VPEDIMPCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO INNER JOIN
                      dbo.TPAGO ON dbo.VPEDIMPCONTRIBUCION.PG_CODIGO = dbo.TPAGO.PG_CODIGO





































































GO
