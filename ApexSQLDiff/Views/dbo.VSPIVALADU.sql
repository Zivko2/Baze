SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE VIEW dbo.VSPIVALADU
with encryption as
SELECT     SUM(dbo.PEDIMPDET.PID_VAL_ADU) AS PID_VAL_ADU, dbo.PEDIMPDET.PI_CODIGO, dbo.PEDIMPDET.PIB_INDICEB, 
                      dbo.CONFIGURATIPO.CFT_TIPO
FROM         dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
WHERE     (dbo.PEDIMPDET.PID_DEF_TIP <> 'P') and (dbo.PEDIMPDET.PID_IMPRIMIR = 'S') 
GROUP BY dbo.PEDIMPDET.PI_CODIGO, dbo.PEDIMPDET.PIB_INDICEB, dbo.CONFIGURATIPO.CFT_TIPO

























































GO
