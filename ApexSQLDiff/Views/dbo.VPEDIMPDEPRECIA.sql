SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































CREATE VIEW dbo.VPEDIMPDEPRECIA
with encryption as
SELECT     dbo.PEDIMPDET.PID_INDICED, dbo.VPEDIMP.PI_FEC_ENT, dbo.PEDIMPDET.PID_COS_UNIGEN / dbo.ANEXO24.ANX_VID_YEAR AS CuotaDepreciacion,
                       round(convert(decimal(38,6),GETDATE() - dbo.VPEDIMP.PI_FEC_ENT),6) / 365 AS TiempoenPaisenyears, 
                      dbo.PIDescarga.PID_SALDOGEN * dbo.PEDIMPDET.PID_COS_UNIGEN AS valororig, 
ROUND((dbo.PIDescarga.PID_SALDOGEN * dbo.PEDIMPDET.PID_COS_UNIGEN) - 
((dbo.PIDescarga.PID_SALDOGEN * dbo.PEDIMPDET.PID_COS_UNIGEN) / (dbo.ANEXO24.ANX_VID_YEAR * 365))* round(convert(decimal(38,6),GETDATE() - dbo.VPEDIMP.PI_FEC_ENT),6),6) AS ValorActual
FROM         dbo.ANEXO24 INNER JOIN
                      dbo.PEDIMPDET ON dbo.ANEXO24.MA_CODIGO = dbo.PEDIMPDET.MA_CODIGO INNER JOIN
                      dbo.VPEDIMP ON dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDIMP.PI_CODIGO INNER JOIN
                      dbo.PIDescarga ON dbo.PEDIMPDET.PID_INDICED = dbo.PIDescarga.PID_INDICED
WHERE     (dbo.ANEXO24.ANX_VID_YEAR > 0)


































GO
