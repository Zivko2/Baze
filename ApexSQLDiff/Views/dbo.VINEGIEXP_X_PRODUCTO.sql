SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


































CREATE VIEW dbo.VINEGIEXP_X_PRODUCTO
with encryption as
SELECT     SUM(dbo.FACTEXPDET.FED_COS_TOT * dbo.FACTEXP.FE_TIPOCAMBIO) AS COSTOTOT, dbo.INEGI.IG_CODIGO, MAESTRO_1.MA_NOMBRE
FROM         dbo.CONFIGURATIPO RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.FACTEXPDET.TI_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO LEFT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 ON dbo.MAESTRO.MA_FAMILIA = MAESTRO_1.MA_CODIGO ON 
                      dbo.FACTEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO RIGHT OUTER JOIN
                      dbo.FACTEXP RIGHT OUTER JOIN
                      dbo.INEGI ON dbo.FACTEXP.FE_FECHA >= dbo.INEGI.IG_INICIO AND dbo.FACTEXP.FE_FECHA <= dbo.INEGI.IG_FINAL ON 
                      dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
WHERE     (dbo.CONFIGURATIPO.CFT_TIPO = 'S' OR
                      dbo.CONFIGURATIPO.CFT_TIPO = 'P') AND (dbo.FACTEXP.FE_CANCELADO = 'N')
GROUP BY dbo.INEGI.IG_CODIGO, MAESTRO_1.MA_NOMBRE


































































GO
