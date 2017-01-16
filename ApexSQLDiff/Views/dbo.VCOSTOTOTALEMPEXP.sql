SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


























































CREATE VIEW dbo.VCOSTOTOTALEMPEXP
with encryption as
SELECT     dbo.FACTEXPDET.FE_CODIGO, SUM(dbo.FACTEXPDET.FED_NG_EMP * dbo.FACTEXPDET.FED_CANT) AS COSTOTOTALEMPEXP, 
                      MAX(dbo.ARANCEL.AR_FRACCION) AS AR_FRACCION
FROM         dbo.ARANCEL RIGHT OUTER JOIN
                      dbo.MAESTRO ON dbo.ARANCEL.AR_CODIGO = dbo.MAESTRO.AR_IMPFO RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.MAESTRO.MA_CODIGO = dbo.FACTEXPDET.MA_EMPAQUE
GROUP BY dbo.FACTEXPDET.FE_CODIGO

























































GO
