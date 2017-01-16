SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VDESCEMPAQUEPESTANA
with encryption as
SELECT     dbo.FACTEXPEMPAQUE.MA_EMP1 AS MA_HIJO, SUM(dbo.FACTEXPEMPAQUE.FEE_TOT_EMP1) AS Cantidad, MAESTRO_1.ME_COM, MAESTRO_1.EQ_GEN, 
                      MAESTRO_1.MA_DISCHARGE, MAESTRO_2.ME_COM AS ME_GEN, dbo.FACTEXPEMPAQUE.FE_CODIGO, MAESTRO_2.MA_GENERA_EMP
FROM         dbo.MAESTRO MAESTRO_1 LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_2 ON MAESTRO_1.MA_GENERICO = MAESTRO_2.MA_CODIGO RIGHT OUTER JOIN
                      dbo.FACTEXPEMPAQUE ON MAESTRO_2.MA_CODIGO = dbo.FACTEXPEMPAQUE.MA_EMP1
GROUP BY dbo.FACTEXPEMPAQUE.MA_EMP1, MAESTRO_1.ME_COM, MAESTRO_1.EQ_GEN, MAESTRO_1.MA_DISCHARGE, MAESTRO_2.ME_COM, 
                      MAESTRO_1.ME_COM, dbo.FACTEXPEMPAQUE.FE_CODIGO, MAESTRO_2.MA_GENERA_EMP
HAVING      (MAESTRO_1.MA_DISCHARGE = 'S') 

UNION

SELECT     dbo.FACTEXPEMPAQUE.MA_EMP2 AS MA_HIJO, SUM(dbo.FACTEXPEMPAQUE.FEE_TOT_EMP2) AS Cantidad, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, 
                      dbo.MAESTRO.MA_DISCHARGE, MAESTRO_1.ME_COM AS ME_GEN, dbo.FACTEXPEMPAQUE.FE_CODIGO, MAESTRO.MA_GENERA_EMP
FROM         dbo.FACTEXPEMPAQUE LEFT OUTER JOIN
                      dbo.MAESTRO ON dbo.FACTEXPEMPAQUE.MA_EMP2 = dbo.MAESTRO.MA_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_GENERICO = MAESTRO_1.MA_CODIGO
GROUP BY dbo.FACTEXPEMPAQUE.MA_EMP2, dbo.MAESTRO.ME_COM, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.MA_DISCHARGE, MAESTRO_1.ME_COM, 
                      dbo.FACTEXPEMPAQUE.FE_CODIGO, MAESTRO.MA_GENERA_EMP
HAVING      (dbo.MAESTRO.MA_DISCHARGE = 'S') 

































































GO
