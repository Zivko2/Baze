SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO



































CREATE VIEW dbo.VCONSTEXP1ERCONST
with encryption as
SELECT FACTIMP.FI_CODIGO, MIN(FACTIMPPED.FIP_INDICEP) 
    AS FIP_INDICEP
FROM FACTIMP LEFT OUTER JOIN
    FACTIMPPED ON 
    FACTIMP.FI_CODIGO = FACTIMPPED.FI_CODIGO
GROUP BY FACTIMP.FI_CODIGO, FACTIMPPED.FIP_TIPO
HAVING (FACTIMPPED.FIP_TIPO = 'C')








































































GO
