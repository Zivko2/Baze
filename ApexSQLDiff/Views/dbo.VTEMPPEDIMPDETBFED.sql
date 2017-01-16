SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























































CREATE VIEW dbo.VTEMPPEDIMPDETBFED
with encryption as
SELECT     PIB_INDICEB, PI_CODIGO, SUM(PIB_VALORMCIANOORIG) AS PIB_VALORMCIANOORIG, SUM(PIB_ADVMNIMPUSA) AS PIB_ADVMNIMPUSA, 
                      SUM(PIB_ADVMNIMPMEX) AS PIB_ADVMNIMPMEX, SUM(PIB_EXCENCION) AS PIB_EXCENCION, SUM(PIB_IMPORTECONTRSINRECARGOS) 
                      AS PIB_IMPORTECONTRSINRECARGOS, SUM(PIB_IMPORTECONTR) AS PIB_IMPORTECONTR, SUM(PIB_IMPORTECONTRUSD) 
                      AS PIB_IMPORTECONTRUSD, SUM(PIB_IMPORTERECARGOS) AS PIB_IMPORTERECARGOS
FROM         dbo.TempPedImpDetBFed
GROUP BY PIB_INDICEB, PI_CODIGO























































GO
