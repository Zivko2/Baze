SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO















CREATE VIEW dbo.VINVENTARIOKARSUM
with encryption as
SELECT     dbo.FACTEXP.FE_FECHA, dbo.KARDESPED.KAP_INDICED_PED, SUM(ISNULL(dbo.KARDESPED.KAP_CANTDESC, 0)) AS KAP_CANTDESC, 
                      dbo.KARDESPED.MA_HIJO
FROM         dbo.KARDESPED LEFT OUTER JOIN
                      dbo.FACTEXP ON dbo.KARDESPED.KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO
GROUP BY dbo.FACTEXP.FE_FECHA, dbo.KARDESPED.KAP_INDICED_PED, dbo.KARDESPED.MA_HIJO


































































GO
