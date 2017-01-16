SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO






















CREATE VIEW dbo.VDECANUALDIRCAT1
with encryption as
SELECT     SUM(ISNULL(dbo.VPEDIMP.PI_TIP_CAM, 1) * dbo.PEDIMPDET.PID_CTOT_DLS) AS valor, SUM(dbo.PEDIMPDET.PID_CTOT_DLS) AS PID_CTOT_DLS, 
                      dbo.DECANUALNVA.DAN_CODIGO, dbo.VPEDIMP.PI_CODIGO, dbo.PEDIMPDET.AR_IMPMX, dbo.PEDIMPDET.MA_GENERICO, 
                      dbo.PEDIMPDET.PID_NOMBRE, 'T'  AS TIPO, dbo.TIPO.TI_CATEGM
FROM         dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.TIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.TIPO.TI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO RIGHT OUTER JOIN
                      dbo.DECANUALNVA INNER JOIN
                      dbo.VPEDIMP ON dbo.DECANUALNVA.DAN_INICIO <= dbo.VPEDIMP.PI_FEC_ENT AND dbo.DECANUALNVA.DAN_FINAL >= dbo.VPEDIMP.PI_FEC_ENT ON
                       dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDIMP.PI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.VPEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
WHERE     (dbo.PEDIMPDET.PID_IMPRIMIR='S') and (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'IT' AND dbo.VPEDIMP.PI_ESTATUS <> 'R')  
AND (dbo.TIPO.TI_CATEGM = '1')  
GROUP BY  dbo.DECANUALNVA.DAN_CODIGO, dbo.VPEDIMP.PI_CODIGO, dbo.PEDIMPDET.AR_IMPMX, dbo.PEDIMPDET.MA_GENERICO, 
                      dbo.PEDIMPDET.PID_NOMBRE, dbo.TIPO.TI_CATEGM
UNION
SELECT     SUM(ISNULL(dbo.VPEDIMP.PI_TIP_CAM, 1) * dbo.PEDIMPDET.PID_CTOT_DLS) AS valor, SUM(dbo.PEDIMPDET.PID_CTOT_DLS) AS PID_CTOT_DLS, 
                      dbo.DECANUALNVA.DAN_CODIGO, dbo.VPEDIMP.PI_CODIGO, dbo.PEDIMPDET.AR_IMPMX, dbo.PEDIMPDET.MA_GENERICO, 
                      dbo.PEDIMPDET.PID_NOMBRE, 'T'  AS TIPO, dbo.TIPO.TI_CATEGM
FROM         dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.TIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.TIPO.TI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO RIGHT OUTER JOIN
                      dbo.DECANUALNVA INNER JOIN
                      dbo.VPEDIMP ON dbo.DECANUALNVA.DAN_INICIO <= dbo.VPEDIMP.PI_FEC_ENT AND dbo.DECANUALNVA.DAN_FINAL >= dbo.VPEDIMP.PI_FEC_ENT ON
                       dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDIMP.PI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.VPEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
WHERE     (dbo.PEDIMPDET.PID_IMPRIMIR='S') and dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE' AND dbo.VPEDIMP.CP_RECTIFICA IN (SELECT CP_CODIGO FROM CONFIGURACLAVEPED
                            WHERE      CCP_TIPO = 'IT') AND (dbo.TIPO.TI_CATEGM = '1' )  
GROUP BY  dbo.DECANUALNVA.DAN_CODIGO, dbo.VPEDIMP.PI_CODIGO, dbo.PEDIMPDET.AR_IMPMX, dbo.PEDIMPDET.MA_GENERICO, 
                      dbo.PEDIMPDET.PID_NOMBRE,  dbo.TIPO.TI_CATEGM





















GO
