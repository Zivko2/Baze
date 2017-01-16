SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.VPEDIMPTIEMPO
with encryption as
SELECT     TOP 100 PERCENT dbo.PEDIMPDET.PID_INDICED, dbo.PEDIMPDET.PID_NOPARTE, dbo.PIDescarga.PI_FEC_ENT, dbo.PIDescarga.PID_FECHAVENCE, 
                      ROUND((CONVERT(decimal(38,6), dbo.PIDescarga.PID_FECHAVENCE) - CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT)) / 30.416, 0) AS PIT_TIEMPO, 
                      ROUND((CONVERT(decimal(38,6), GETDATE()) - CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT)) / 30.416, 0) AS PIT_TIEMPOPAS, ROUND((CONVERT(decimal(38,6), 
                      dbo.PIDescarga.PID_FECHAVENCE) - CONVERT(decimal(38,6), dbo.PEDIMP.PI_FEC_ENT)) / 30.416, 0) - ROUND((CONVERT(decimal(38,6), GETDATE()) - CONVERT(decimal(38,6), 
                      dbo.PEDIMP.PI_FEC_ENT)) / 30.416, 0) AS PIT_TIEMPORESTA, dbo.PEDIMPDET.PI_CODIGO
FROM         dbo.PIDescarga INNER JOIN
                      dbo.PEDIMPDET ON dbo.PIDescarga.PID_INDICED = dbo.PEDIMPDET.PID_INDICED INNER JOIN
                      dbo.PEDIMP ON dbo.PIDescarga.PI_CODIGO = dbo.PEDIMP.PI_CODIGO
WHERE dbo.PIDescarga.PID_SALDOGEN>0 --AND dbo.PEDIMPDET.PID_IMPRIMIR='S'
ORDER BY dbo.PEDIMPDET.PID_INDICED





GO
