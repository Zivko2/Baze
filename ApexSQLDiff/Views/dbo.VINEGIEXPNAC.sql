SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO







































CREATE VIEW dbo.VINEGIEXPNAC
with encryption as
SELECT     SUM(dbo.FACTEXPDET.FED_COS_TOT * dbo.FACTEXP.FE_TIPOCAMBIO) AS COSTOTOTALEXPNAC, dbo.INEGI.IG_CODIGO
FROM         dbo.CONFIGURATFACT RIGHT OUTER JOIN
                      dbo.FACTEXP ON dbo.CONFIGURATFACT.TF_CODIGO = dbo.FACTEXP.TF_CODIGO RIGHT OUTER JOIN
                      dbo.INEGI ON dbo.FACTEXP.FE_FECHA >= dbo.INEGI.IG_INICIO AND dbo.FACTEXP.FE_FECHA <= dbo.INEGI.IG_FINAL LEFT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO
WHERE     (dbo.FACTEXP.FE_CANCELADO = 'N') AND (dbo.CONFIGURATFACT.CFF_TIPO IN ('MN'))
GROUP BY dbo.INEGI.IG_CODIGO





























































GO
