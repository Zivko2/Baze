SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO













































CREATE VIEW dbo.VPEDIMPDETBIGI
with encryption as
SELECT     dbo.PEDIMPDETBCONTRIBUCION.PIB_INDICEB, dbo.PEDIMPDETBCONTRIBUCION.PI_CODIGO, dbo.CONTRIBUCION.CON_ABREVIA, 
                      dbo.PEDIMPDETBCONTRIBUCION.PG_CODIGO, dbo.PEDIMPDETBCONTRIBUCION.PIB_CONTRIBTOTMN
FROM         dbo.PEDIMPDETBCONTRIBUCION INNER JOIN
                      dbo.CONTRIBUCION ON dbo.PEDIMPDETBCONTRIBUCION.CON_CODIGO = dbo.CONTRIBUCION.CON_CODIGO
WHERE     (dbo.CONTRIBUCION.CON_ABREVIA = 'IGI/IGE')






















































GO
