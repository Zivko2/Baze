SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO













































CREATE VIEW dbo.VRECARGOBase
with encryption as
SELECT     dbo.PEDIMP.PI_CODIGO, SUM(ISNULL(dbo.RECARGO.REC_TASA, 0)) AS SUMATASA, dbo.RECARGO.REC_MES, dbo.RECARGO.REC_FECINI
FROM         dbo.RECARGO RIGHT OUTER JOIN
                      dbo.PEDIMP ON dbo.RECARGO.REC_FECINI <= dbo.PEDIMP.PI_FECHAPAGO AND dbo.RECARGO.REC_FECINI >= CONVERT(DATETIME, DATEDIFF(dd, 
                      DATEPART(dd, dbo.PEDIMP.PI_FEC_PAG + 60) - 1, dbo.PEDIMP.PI_FEC_PAG + 60)) 
--AND dbo.RECARGO.REC_MES >= MONTH(dbo.PEDIMP.PI_FEC_PAG + 60) AND dbo.RECARGO.REC_MES <= MONTH(dbo.PEDIMP.PI_FECHAPAGO)
GROUP BY dbo.PEDIMP.PI_CODIGO, dbo.RECARGO.REC_MES, dbo.RECARGO.REC_FECINI, CONVERT(DATETIME, DATEDIFF(dd, DATEPART(dd, 
                      dbo.PEDIMP.PI_FEC_PAG + 60) - 1, dbo.PEDIMP.PI_FEC_PAG + 60))














































GO
