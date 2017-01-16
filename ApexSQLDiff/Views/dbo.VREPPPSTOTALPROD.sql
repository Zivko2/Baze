SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
































































CREATE VIEW dbo.VREPPPSTOTALPROD
with encryption as
SELECT     dbo.DECANUALPPS.DAP_CODIGO, dbo.FACTEXPDET.MA_GENERICO, MAX(dbo.FACTEXPDET.FED_NOMBRE) AS FED_NOMBRE, 
                      MAESTRO_1.AR_IMPMX, dbo.ARANCEL.ME_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT * MAESTRO_1.EQ_IMPMX) AS FED_CANT, 
                      SUM(dbo.FACTEXPDET.FED_COS_TOT * dbo.FACTEXP.FE_TIPOCAMBIO * MAESTRO_1.EQ_IMPMX) AS VALOR, dbo.FACTEXPDET.SE_CODIGO
FROM         dbo.MAESTRO MAESTRO_1 RIGHT OUTER JOIN
                      dbo.FACTEXPDET ON MAESTRO_1.MA_CODIGO = dbo.FACTEXPDET.MA_CODIGO LEFT OUTER JOIN
                      dbo.ARANCEL ON MAESTRO_1.AR_IMPMX = dbo.ARANCEL.AR_CODIGO RIGHT OUTER JOIN
                      dbo.FACTEXP INNER JOIN
                      dbo.DECANUALPPS ON dbo.FACTEXP.FE_FECHA >= dbo.DECANUALPPS.DAP_INICIO AND 
                      dbo.FACTEXP.FE_FECHA <= dbo.DECANUALPPS.DAP_FINAL ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
GROUP BY dbo.FACTEXPDET.MA_GENERICO, dbo.FACTEXPDET.TI_CODIGO, MAESTRO_1.AR_IMPMX, dbo.FACTEXPDET.SE_CODIGO, 
                      dbo.DECANUALPPS.DAP_CODIGO, dbo.ARANCEL.ME_CODIGO, dbo.FACTEXPDET.SE_CODIGO, MAESTRO_1.EQ_IMPMX
HAVING      (dbo.FACTEXPDET.TI_CODIGO IN
                          (SELECT     TI_CODIGO
                            FROM          CONFIGURATIPO
                            WHERE      CFT_TIPO IN ('P', 'S'))) AND (dbo.FACTEXPDET.SE_CODIGO IS NOT NULL) AND (dbo.FACTEXPDET.SE_CODIGO <> 0)
































































GO
