SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































































CREATE VIEW dbo.VSUMPEDIMPDETBCONT
with encryption as
SELECT     0 AS PIB_CONTRIBTOTMNOTROS, SUM(PIB_CONTRIBTOTMN) AS PIB_CONTRIBTOTMNEFEC, PI_CODIGO,  SUM(PIB_CONTRIBTOTMN) as TOTAL
FROM         dbo.PEDIMPDETBCONTRIBUCION
WHERE     PG_CODIGO in (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
GROUP BY PG_CODIGO, PI_CODIGO
UNION
SELECT     SUM(PIB_CONTRIBTOTMN), 0, PI_CODIGO, SUM(PIB_CONTRIBTOTMN)
FROM         dbo.PEDIMPDETBCONTRIBUCION
WHERE     PG_CODIGO not in (SELECT PG_CODIGO FROM TPAGO WHERE PG_CLAVEM3='0')
GROUP BY PG_CODIGO, PI_CODIGO
































































GO
