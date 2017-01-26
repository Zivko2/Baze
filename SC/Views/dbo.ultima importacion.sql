SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.[ultima importacion]
AS
SELECT     MAX(dbo.PEDIMP.PI_FEC_ENT) AS Fecha, dbo.PEDIMPDET.MA_CODIGO, dbo.PEDIMPDET.PID_NOPARTE, MAX(dbo.PEDIMPDET.PID_NOMBRE) 
                      AS Nombre
FROM         dbo.PEDIMP INNER JOIN
                      dbo.PEDIMPDET ON dbo.PEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO INNER JOIN
                      dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED
WHERE     (dbo.PEDIMP.PI_MOVIMIENTO = 'E') AND (dbo.PEDIMP.PI_RECTESTATUS <> 'r') AND (dbo.PEDIMP.PI_ESTATUS <> 'r')
GROUP BY dbo.PEDIMPDET.PID_NOPARTE, dbo.PEDIMPDET.MA_CODIGO
HAVING      (SUM(dbo.PIDescarga.PID_SALDOGEN) = 0)
GO
