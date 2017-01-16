SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

























CREATE VIEW dbo.vwTmp4grids
with encryption as
SELECT     dbo.VPEDIMP.PI_FOLIO, dbo.KARDESPED.KAP_CANTDESC AS KAP_CANTDESC
FROM         dbo.VPEDIMP RIGHT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.VPEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO RIGHT OUTER JOIN
                      dbo.KARDESPED ON dbo.PEDIMPDET.PID_INDICED = dbo.KARDESPED.KAP_INDICED_PED
WHERE     (dbo.KARDESPED.KAP_FACTRANS = 238) AND (dbo.KARDESPED.MA_HIJO = 5688722)


































































GO
