SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO








































CREATE VIEW dbo.VPEDIMPDESCPOSIBLE
with encryption as
SELECT     TOP 100 PERCENT dbo.PEDIMPDET.PID_INDICED, PIDESCARGA.PID_SALDOGEN, dbo.PEDIMPDET.MA_CODIGO, dbo.VPEDIMP.PI_FEC_ENT, 
                      dbo.VPEDIMP.[PATENTE-FOLIO], dbo.VPEDIMP.PI_CODIGO, dbo.PEDIMPDET.PID_COS_UNI
FROM         dbo.VPEDIMP LEFT OUTER JOIN
                      dbo.CLAVEPED ON dbo.VPEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO LEFT OUTER JOIN
                      dbo.PEDIMPDET ON dbo.VPEDIMP.PI_CODIGO = dbo.PEDIMPDET.PI_CODIGO  LEFT OUTER JOIN
		PIDESCARGA ON dbo.PEDIMPDET.PID_INDICED=PIDESCARGA.PID_INDICED
WHERE     (PIDESCARGA.PID_SALDOGEN > 0) AND (dbo.CLAVEPED.CP_DESCARGABLE = 'S') AND (dbo.PEDIMPDET.PID_DESCARGABLE = 'S') AND 
                      (dbo.VPEDIMP.PI_ESTATUS <> 'R') AND (dbo.VPEDIMP.PI_ACTIVO_DESCARGA = 'S') AND (dbo.VPEDIMP.PI_MOVIMIENTO = 'E')
ORDER BY dbo.VPEDIMP.PI_FEC_ENT, dbo.VPEDIMP.PI_CODIGO
























































GO
