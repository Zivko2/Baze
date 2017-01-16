SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


































CREATE VIEW dbo.VINEGIEXP_X_PAIS
with encryption as
SELECT     dbo.DIR_CLIENTE.PA_CODIGO, SUM(dbo.FACTEXPDET.FED_COS_TOT * dbo.FACTEXP.FE_TIPOCAMBIO) AS COSTOTOT, dbo.INEGI.IG_CODIGO
FROM         dbo.CONFIGURATIPO RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON dbo.CONFIGURATIPO.TI_CODIGO = dbo.FACTEXPDET.TI_CODIGO RIGHT OUTER JOIN
                      dbo.DIR_CLIENTE RIGHT OUTER JOIN
                      dbo.FACTEXP ON dbo.DIR_CLIENTE.DI_INDICE = dbo.FACTEXP.DI_DESTINI RIGHT OUTER JOIN
                      dbo.INEGI ON dbo.FACTEXP.FE_FECHA >= dbo.INEGI.IG_INICIO AND dbo.FACTEXP.FE_FECHA <= dbo.INEGI.IG_FINAL ON 
                      dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
WHERE     (dbo.DIR_CLIENTE.PA_CODIGO NOT IN
                          (SELECT     CF_PAIS_MX
                            FROM          CONFIGURACION)) AND (dbo.FACTEXP.FE_CANCELADO = 'N')
AND dbo.CONFIGURATIPO.CFT_TIPO NOT IN ('C', 'H', 'Q', 'X')
GROUP BY dbo.DIR_CLIENTE.PA_CODIGO, dbo.INEGI.IG_CODIGO






































GO
