SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VCONCILIAGEN
with encryption as
SELECT     TOP 100 PERCENT MA_GENERICO, ABS(SUM(PID_SALDOGEN) - END_SALDOGEN) AS CANTIDAD
FROM         dbo.TEMP_INVENTARIOS
WHERE     (PI_FOLIO IS NOT NULL) AND (TIPO = 'N')
GROUP BY END_SALDOGEN, MA_GENERICO
HAVING      (ABS(SUM(PID_SALDOGEN) - END_SALDOGEN) > 0)
ORDER BY MA_GENERICO






































GO
