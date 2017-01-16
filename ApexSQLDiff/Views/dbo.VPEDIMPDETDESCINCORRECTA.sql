SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO













































CREATE VIEW dbo.VPEDIMPDETDESCINCORRECTA
with encryption as
SELECT     TOP 100 PERCENT SUM(ROUND(dbo.KARDESPED.KAP_CANTDESC,6)) AS KAP_CANTDESC, ROUND(dbo.PEDIMPDET.PID_CAN_GEN,6) 
                      AS PID_CAN_GEN, dbo.VPEDIMP.PI_FOLIO, dbo.PEDIMPDET.PID_INDICED
FROM         dbo.PEDIMPDET INNER JOIN
                      dbo.KARDESPED ON dbo.PEDIMPDET.PID_INDICED = dbo.KARDESPED.KAP_INDICED_PED INNER JOIN
                      dbo.VPEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDIMP.PI_CODIGO
GROUP BY ROUND(dbo.PEDIMPDET.PID_CAN_GEN,6), dbo.VPEDIMP.PI_FOLIO, dbo.PEDIMPDET.PID_INDICED
HAVING      (SUM(ROUND(dbo.KARDESPED.KAP_CANTDESC,6)) > ROUND(dbo.PEDIMPDET.PID_CAN_GEN,6))
ORDER BY dbo.VPEDIMP.PI_FOLIO, dbo.PEDIMPDET.PID_INDICED

























































GO
