SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW dbo.VPEDIMPCONTRIBUCION1
with encryption as
SELECT PI_CODIGO, CON_CODIGO, 
    PIB_CONTRIBPOR AS PIT_CONTRIBPOR, 
     SUM(ROUND(PIB_CONTRIBTOTMN, 0))  AS PIT_CONTRIBTOTMN, 
    PG_CODIGO, TTA_CODIGO
FROM PEDIMPDETBCONTRIBUCION
GROUP BY PI_CODIGO, CON_CODIGO, PIB_CONTRIBPOR, 
    PG_CODIGO, TTA_CODIGO
HAVING SUM(ROUND(PIB_CONTRIBTOTMN, 0))>0
UNION
SELECT PI_CODIGO, CON_CODIGO, PIT_CONTRIBPOR, 
     SUM(ROUND(PIT_CONTRIBTOTMN, 0))  AS PIT_CONTRIBTOTMN, 
    PG_CODIGO, TTA_CODIGO
FROM PEDIMPCONTRIBUCION
WHERE PIT_TIPO='N'
GROUP BY PI_CODIGO, CON_CODIGO, PIT_CONTRIBPOR, 
    PG_CODIGO, TTA_CODIGO
HAVING SUM(ROUND(PIT_CONTRIBTOTMN, 0))>0


GO
