SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































































CREATE VIEW dbo.VREPPPSTOTALNAC
with encryption as
SELECT     dbo.DECANUALPPS.DAP_CODIGO, dbo.FACTEXPDET.MA_GENERICO, MAX(dbo.FACTEXPDET.FED_NOMBRE) AS FED_NOMBRE, 
                      dbo.FACTEXPDET.SE_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT*MAESTRO_1.EQ_IMPMX) AS FED_CANT, SUM(dbo.FACTEXPDET.FED_COS_TOT * dbo.FACTEXP.FE_TIPOCAMBIO*MAESTRO_1.EQ_IMPMX) 
                      AS VALOR
FROM         dbo.MAESTRO RIGHT OUTER JOIN
                      dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON MAESTRO_1.MA_CODIGO = dbo.FACTEXPDET.MA_CODIGO ON 
                      dbo.MAESTRO.MA_CODIGO = dbo.FACTEXPDET.MA_GENERICO RIGHT OUTER JOIN
                      dbo.DECANUALPPS INNER JOIN
                      dbo.FACTEXP ON dbo.DECANUALPPS.DAP_INICIO <= dbo.FACTEXP.FE_FECHA AND 
                      dbo.DECANUALPPS.DAP_FINAL >= dbo.FACTEXP.FE_FECHA LEFT OUTER JOIN
                      dbo.CONFIGURATFACT ON dbo.FACTEXP.TF_CODIGO = dbo.CONFIGURATFACT.TF_CODIGO ON 
                      dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
WHERE     (dbo.CONFIGURATFACT.CFF_TIPO = 'MN') AND (dbo.FACTEXPDET.SE_CODIGO IS NOT NULL AND dbo.FACTEXPDET.SE_CODIGO <> 0)
GROUP BY dbo.FACTEXPDET.MA_GENERICO, dbo.FACTEXPDET.TI_CODIGO, dbo.FACTEXPDET.SE_CODIGO, dbo.DECANUALPPS.DAP_CODIGO
HAVING      (dbo.FACTEXPDET.TI_CODIGO IN
                          (SELECT     TI_CODIGO
                            FROM          CONFIGURATIPO
                            WHERE      CFT_TIPO IN ('P', 'S')))

































































GO
