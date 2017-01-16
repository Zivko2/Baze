SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.[ultima fecha desc]
AS
SELECT     MAX(dbo.FACTEXP.FE_FECHA) AS fecha, dbo.[ultima descarga].MA_HIJO
FROM         dbo.[ultima descarga] INNER JOIN
                      dbo.FACTEXP ON dbo.[ultima descarga].KAP_FACTRANS = dbo.FACTEXP.FE_CODIGO
GROUP BY dbo.[ultima descarga].MA_HIJO
GO
