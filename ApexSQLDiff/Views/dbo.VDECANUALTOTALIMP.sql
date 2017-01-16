SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE VIEW dbo.VDECANUALTOTALIMP
with encryption as
SELECT     SUM(dbo.PEDIMPDET.PID_CTOT_DLS * dbo.PEDIMP.PI_TIP_CAM) AS VALOR, dbo.DECANUALNVA.DAN_CODIGO, dbo.PEDIMP.PI_CODIGO
FROM         dbo.PEDIMP INNER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO INNER JOIN
                      dbo.DECANUALNVA ON dbo.PEDIMP.PI_FEC_ENT >= dbo.DECANUALNVA.DAN_INICIO AND 
                      dbo.PEDIMP.PI_FEC_ENT <= dbo.DECANUALNVA.DAN_FINAL
WHERE     (dbo.PEDIMP.PI_MOVIMIENTO ='E') AND (dbo.PEDIMP.PI_ESTATUS <> 'R') AND (dbo.PEDIMPDET.TI_CODIGO NOT IN
                          (SELECT     TI_CODIGO
                            FROM          dbo.CONFIGURATIPO
                            WHERE      CFT_TIPO IN ('C', 'H', 'Q', 'X'))) and (dbo.PEDIMPDET.PID_IMPRIMIR='S')
GROUP BY dbo.DECANUALNVA.DAN_TOTALEXP, dbo.DECANUALNVA.DAN_CODIGO, dbo.PEDIMP.PI_CODIGO





















GO
