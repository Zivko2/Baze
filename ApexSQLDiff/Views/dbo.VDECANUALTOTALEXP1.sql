SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE VIEW dbo.VDECANUALTOTALEXP1
with encryption as
SELECT     dbo.DECANUALNVA.DAN_CODIGO, SUM(dbo.PEDIMPDET.PID_COS_UNI * dbo.PEDIMPDET.PID_CANT ) AS VALOR, 
                      dbo.PEDIMP.PI_CODIGO
FROM         dbo.PEDIMP INNER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO INNER JOIN
                      dbo.DECANUALNVA ON dbo.PEDIMP.PI_FEC_ENT >= dbo.DECANUALNVA.DAN_INICIO AND 
                      dbo.PEDIMP.PI_FEC_ENT <= dbo.DECANUALNVA.DAN_FINAL
WHERE     (dbo.PEDIMP.PI_MOVIMIENTO = 'S') AND (dbo.PEDIMP.PI_ESTATUS <> 'O') and (dbo.PEDIMPDET.PID_IMPRIMIR='S')
GROUP BY dbo.DECANUALNVA.DAN_TOTALEXP, dbo.DECANUALNVA.DAN_CODIGO, dbo.PEDIMPDET.PID_COS_UNI * dbo.PEDIMPDET.PID_CANT, 
                      dbo.PEDIMP.PI_TIP_CAM, dbo.PEDIMP.PI_CODIGO





















GO
