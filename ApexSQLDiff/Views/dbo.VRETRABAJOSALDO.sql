SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








































CREATE VIEW dbo.VRETRABAJOSALDO
with encryption as
SELECT     dbo.VPEDIMP.[PATENTE-FOLIO], dbo.VPEDIMP.PI_CODIGO, dbo.VPEDIMP.PI_FEC_ENT, dbo.VPEDIMP.PI_FEC_PAG, dbo.PEDIMPDET.TI_CODIGO, 
                      SUM(PIDESCARGA.PID_SALDOGEN) AS PID_SALDOGEN, dbo.PEDIMPDET.MA_CODIGO, dbo.CLAVEPED.CP_CLAVE, 
                      dbo.PEDIMPDET.PID_NOPARTE, MAX(dbo.PEDIMPDET.PID_NOMBRE) AS PID_NOMBRE, dbo.PEDIMPDET.ME_GENERICO, 
                      MAX(dbo.PEDIMPDET.PID_NAME) AS PID_NAME
FROM         dbo.CLAVEPED RIGHT OUTER JOIN
                      dbo.VPEDIMP ON dbo.CLAVEPED.CP_CODIGO = dbo.VPEDIMP.CP_CODIGO LEFT OUTER JOIN
                      dbo.MAESTRO RIGHT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.MAESTRO.MA_CODIGO = dbo.PEDIMPDET.MA_CODIGO ON dbo.VPEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO
LEFT OUTER JOIN PIDESCARGA ON dbo.PEDIMPDET.PID_INDICED=PIDESCARGA.PID_INDICED
WHERE     (dbo.MAESTRO.MA_TIP_ENS <> 'E') AND (dbo.MAESTRO.MA_TIP_ENS <> 'C')
GROUP BY dbo.VPEDIMP.[PATENTE-FOLIO], dbo.VPEDIMP.PI_CODIGO, dbo.VPEDIMP.PI_FEC_ENT, dbo.VPEDIMP.PI_FEC_PAG, dbo.PEDIMPDET.TI_CODIGO, 
                      dbo.PEDIMPDET.MA_CODIGO, dbo.CLAVEPED.CP_CLAVE, dbo.PEDIMPDET.PID_NOPARTE, dbo.PEDIMPDET.ME_GENERICO
HAVING      (dbo.PEDIMPDET.TI_CODIGO IN
                          (SELECT     TI_CODIGO
                            FROM          CONFIGURATIPO
                            WHERE      CFT_TIPO = 'P' OR
                                                   CFT_TIPO = 'S')) AND (dbo.PEDIMPDET.MA_CODIGO IN
                          (SELECT     MA_CODIGO
                            FROM          FACTEXPDET)) AND (SUM(PIDESCARGA.PID_SALDOGEN) > 0)




















































GO
