SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























































CREATE VIEW dbo.VREPPPSIMPTEMPACTFIJ
with encryption as
SELECT     dbo.DECANUALPPS.DAP_CODIGO, dbo.VPEDIMP.PI_CODIGO, dbo.VPEDIMP.PI_TIP_CAM * dbo.PEDIMPDET.PID_CTOT_DLS AS valor, 
                      dbo.PEDIMPDET.PID_CTOT_DLS, dbo.PEDIMPDET.PID_NOMBRE, dbo.PEDIMPDET.MA_GENERICO, dbo.PEDIMPDET.AR_IMPMX
FROM         dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.TIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.TIPO.TI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO RIGHT OUTER JOIN
                      dbo.DECANUALPPS INNER JOIN
                      dbo.VPEDIMP ON dbo.DECANUALPPS.DAP_INICIO <= dbo.VPEDIMP.PI_FEC_ENT AND dbo.DECANUALPPS.DAP_FINAL >= dbo.VPEDIMP.PI_FEC_ENT ON
                       dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDIMP.PI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.VPEDIMP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
WHERE     ((dbo.CONFIGURACLAVEPED.CCP_TIPO = 'IM' AND dbo.VPEDIMP.PI_ESTATUS <> 'R') OR
                      (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE'  AND dbo.VPEDIMP.CP_RECTIFICA IN
                          (SELECT     CP_CODIGO
                            FROM          CONFIGURACLAVEPED
                            WHERE      CCP_TIPO = 'IM'))) and (dbo.TIPO.TI_CATEGM = '3' OR dbo.TIPO.TI_CATEGM = '4') AND (dbo.PEDIMPDET.PID_DEF_TIP = 'S')
and (dbo.PEDIMPDET.PID_IMPRIMIR='S')
































































GO
