SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VPEDIMPDESCTOT
with encryption as
SELECT     dbo.KARDESPED.KAP_INDICED_PED, dbo.KARDESPED.KAP_CANTDESC
FROM         dbo.KARDESPED LEFT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.KARDESPED.KAP_INDICED_PED = dbo.PEDIMPDET.PID_INDICED LEFT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.KARDESPED.KAP_INDICED_FACT = dbo.FACTEXPDET.FED_INDICED
WHERE     (dbo.FACTEXPDET.PID_INDICED = - 1) AND (dbo.KARDESPED.KAP_ESTATUS <> 'T')
GROUP BY dbo.KARDESPED.KAP_INDICED_PED, dbo.KARDESPED.KAP_CANTDESC
HAVING      (dbo.KARDESPED.KAP_INDICED_PED IS NOT NULL)

























































GO
