SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






































CREATE VIEW dbo.VREPANUALTOTALPROD
with encryption as
SELECT     dbo.DECANUALNVA.DAN_CODIGO, dbo.FACTEXPDET.MA_GENERICO, MAX(dbo.FACTEXPDET.FED_NOMBRE) AS FED_NOMBRE, 
                      dbo.FACTEXPDET.AR_EXPMX AS AR_IMPMX, dbo.ARANCEL.ME_CODIGO, SUM(dbo.FACTEXPDET.FED_CANT * dbo.FACTEXPDET.EQ_EXPMX) 
                      AS FED_CANT, SUM(dbo.FACTEXPDET.FED_COS_TOT * dbo.FACTEXP.FE_TIPOCAMBIO * dbo.FACTEXPDET.EQ_EXPMX) AS VALOR, 
                      dbo.FACTEXPDET.SE_CODIGO, dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.FE_CODIGO
FROM         dbo.FACTEXPDET LEFT OUTER JOIN
                      dbo.ARANCEL ON dbo.FACTEXPDET.AR_EXPMX = dbo.ARANCEL.AR_CODIGO RIGHT OUTER JOIN
                      dbo.FACTEXP INNER JOIN
                      dbo.DECANUALNVA ON dbo.FACTEXP.FE_FECHA >= dbo.DECANUALNVA.DAN_INICIO AND 
                      dbo.FACTEXP.FE_FECHA <= dbo.DECANUALNVA.DAN_FINAL ON dbo.FACTEXPDET.FE_CODIGO = dbo.FACTEXP.FE_CODIGO
	left outer join dbo.MAESTRO on dbo.MAESTRO.MA_CODIGO = dbo.FACTEXPDET.MA_GENERICO
WHERE     (dbo.FACTEXP.TQ_CODIGO NOT IN
                          (SELECT     TQ_CODIGO
                            FROM          TEMBARQUE
                            WHERE      TQ_NOMBRE = 'DESPERDICIO' OR
                                                   TQ_NOMBRE = 'RETORNO' OR
                                                   TQ_NOMBRE = 'DESPERDICIO')) AND (dbo.FACTEXPDET.FED_CANT > 0) AND (dbo.FACTEXP.FE_CANCELADO<>'S')
GROUP BY dbo.FACTEXPDET.MA_GENERICO, dbo.FACTEXPDET.TI_CODIGO, dbo.FACTEXPDET.AR_EXPMX, dbo.FACTEXPDET.SE_CODIGO, 
                      dbo.DECANUALNVA.DAN_CODIGO, dbo.ARANCEL.ME_CODIGO, dbo.FACTEXPDET.SE_CODIGO, dbo.FACTEXPDET.EQ_EXPMX, 
                      dbo.FACTEXPDET.MA_CODIGO, dbo.FACTEXPDET.FE_CODIGO
HAVING      (dbo.FACTEXPDET.TI_CODIGO IN
                          (SELECT     TI_CODIGO
                            FROM          CONFIGURATIPO
                            WHERE      CFT_TIPO IN ('P', 'S'))) AND (dbo.FACTEXPDET.SE_CODIGO IS NOT NULL) AND (dbo.FACTEXPDET.SE_CODIGO <> 0)










































GO
