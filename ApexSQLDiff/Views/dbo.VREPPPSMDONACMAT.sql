SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO























































CREATE VIEW dbo.[VREPPPSMDONACMAT]
with encryption as
SELECT     dbo.DECANUALPPS.DAP_CODIGO, dbo.VPEDEXP.PI_CODIGO, ISNULL(dbo.PEDIMPDET.PID_CTOT_DLS, 0) * dbo.VPEDEXP.PI_TIP_CAM AS VALOR, 
                      ISNULL(dbo.PEDIMPDET.PID_CTOT_DLS, 0) AS PID_CTOT_DLS, dbo.PEDIMPDET.PID_NOMBRE, dbo.PEDIMPDET.MA_GENERICO, 
                      dbo.PEDIMPDET.AR_IMPMX
FROM         dbo.PEDIMPDET LEFT OUTER JOIN
                      dbo.TIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.TIPO.TI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURATIPO ON dbo.PEDIMPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO RIGHT OUTER JOIN
                      dbo.DECANUALPPS INNER JOIN
                      dbo.VPEDEXP ON dbo.DECANUALPPS.DAP_INICIO <= dbo.VPEDEXP.PI_FEC_ENT AND dbo.DECANUALPPS.DAP_FINAL >= dbo.VPEDEXP.PI_FEC_ENT ON
                       dbo.PEDIMPDET.PI_CODIGO = dbo.VPEDEXP.PI_CODIGO LEFT OUTER JOIN
                      dbo.CONFIGURACLAVEPED ON dbo.VPEDEXP.CP_CODIGO = dbo.CONFIGURACLAVEPED.CP_CODIGO
WHERE     ((dbo.CONFIGURACLAVEPED.CCP_TIPO = 'CN' AND dbo.VPEDEXP.PI_ESTATUS <> 'R') OR
                      (dbo.CONFIGURACLAVEPED.CCP_TIPO = 'RE'  AND dbo.VPEDEXP.CP_RECTIFICA IN
                          (SELECT     CP_CODIGO
                            FROM          CONFIGURACLAVEPED
                            WHERE      CCP_TIPO = 'CN'))) and (dbo.TIPO.TI_CATEGM = '1' OR dbo.TIPO.TI_CATEGM = '2') AND (dbo.PEDIMPDET.PID_DEF_TIP = 'S') and (dbo.PEDIMPDET.PID_IMPRIMIR='S')









































































GO
