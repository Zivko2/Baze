SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.VINEGIIMP
with encryption as
SELECT     SUM(dbo.PEDIMPDET.PID_COS_UNIGEN * dbo.PEDIMPDET.PID_CAN_GEN * dbo.VPEDIMP.PI_TIP_CAM) AS COSTOTOTALMP, 
                      dbo.INEGI.IG_CODIGO
FROM         dbo.CONFIGURACLAVEPED RIGHT OUTER JOIN
                      dbo.CONFIGURATIPO RIGHT OUTER JOIN
                      dbo.INEGI INNER JOIN
                      dbo.VPEDIMP ON dbo.INEGI.IG_INICIO <= dbo.VPEDIMP.PI_FEC_ENT AND dbo.INEGI.IG_FINAL >= dbo.VPEDIMP.PI_FEC_ENT INNER JOIN
                      dbo.PEDIMPDET ON dbo.VPEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.PEDIMPDET.TI_CODIGO ON 
                      dbo.CONFIGURACLAVEPED.CP_CODIGO = dbo.VPEDIMP.CP_CODIGO
WHERE     (dbo.CONFIGURATIPO.CFT_TIPO IN ('R', 'L', 'M', 'O', 'T'))
GROUP BY dbo.INEGI.IG_CODIGO


GO
