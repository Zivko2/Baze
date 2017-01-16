SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
















































/* con la funcion se saca el primer dia del mes en cuestion*/
CREATE VIEW dbo.VRECARGO
with encryption as
SELECT dbo.PEDIMP.PI_CODIGO, SUM(ISNULL(dbo.RECARGO.REC_TASA, 0)) AS 
SUMATASA
FROM  dbo.RECARGO RIGHT OUTER JOIN
               dbo.PEDIMP ON dbo.RECARGO.REC_FECINI <= 
dbo.PEDIMP.PI_FECHAPAGO AND
               dbo.RECARGO.REC_FECINI >= CONVERT(DATETIME, DATEDIFF(dd, 
datepart(dd,dbo.PEDIMP.PI_FEC_PAG + 60)-1, dbo.PEDIMP.PI_FEC_PAG + 60)) 
--and  dbo.RECARGO.REC_MES>= month(dbo.PEDIMP.PI_FEC_PAG + 60) and
--	  dbo.RECARGO.REC_MES<= month(dbo.PEDIMP.PI_FECHAPAGO)
GROUP BY dbo.PEDIMP.PI_CODIGO
















































GO
