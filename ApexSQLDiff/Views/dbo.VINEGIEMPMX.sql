SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.VINEGIEMPMX
with encryption as
SELECT     SUM(dbo.PEDIMPDET.PID_COS_UNIGEN * dbo.KARDESPED.KAP_CANTDESC * dbo.PEDIMP.PI_TIP_CAM) AS COSTOTOTALEMPMX, 
                      dbo.INEGI.IG_CODIGO
FROM         dbo.CONFIGURACLAVEPED RIGHT OUTER JOIN
                      dbo.PEDIMP ON dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.PEDIMP.CP_CODIGO RIGHT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO RIGHT OUTER JOIN
                      dbo.KARDESPED ON dbo.PEDIMPDET.PID_INDICED = dbo.KARDESPED.KAP_INDICED_PED LEFT OUTER JOIN
                      dbo.FACTEXP ON dbo.KARDESPED.KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO RIGHT OUTER JOIN
                      dbo.INEGI ON dbo.FACTEXP.FE_FECHA >= dbo.INEGI.IG_INICIO AND dbo.FACTEXP.FE_FECHA <= dbo.INEGI.IG_FINAL
WHERE     (dbo.CONFIGURATIPO.CFT_TIPO IN ('E')) AND (dbo.CONFIGURACLAVEPED.CCP_TIPO IN ('OC'))
GROUP BY dbo.INEGI.IG_CODIGO




















































GO
