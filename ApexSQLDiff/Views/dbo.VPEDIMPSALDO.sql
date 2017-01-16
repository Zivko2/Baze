SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW dbo.VPEDIMPSALDO
with encryption as
SELECT     dbo.PEDIMPDET.PID_INDICED, ROUND(dbo.PIDescarga.PID_SALDOGEN, 6) AS PID_SALDOGEN, 
                      ROUND(dbo.PEDIMPDET.PID_CAN_GEN - ISNULL
                          ((SELECT     SUM(KAP_CANTDESC)
                              FROM         dbo.KARDESPED
                              WHERE     KAP_INDICED_PED = PEDIMPDET.PID_INDICED), 0), 6) AS KAP_SALDOGEN
FROM         dbo.PIDescarga INNER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED AND ROUND(dbo.PIDescarga.PID_SALDOGEN, 6) 
                      <> ROUND(dbo.PEDIMPDET.PID_CAN_GEN - ISNULL
                          ((SELECT     SUM(KAP_CANTDESC)
                              FROM         dbo.KARDESPED
                              WHERE     KAP_INDICED_PED = PEDIMPDET.PID_INDICED), 0), 6)

GO
