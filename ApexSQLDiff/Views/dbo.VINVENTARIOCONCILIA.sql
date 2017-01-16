SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

































CREATE VIEW dbo.VINVENTARIOCONCILIA
with encryption as
SELECT     dbo.VPEDIMP.[PATENTE-FOLIO] AS NoPedimento, dbo.PIDescarga.PI_CODIGO, dbo.PIDescarga.PID_INDICED, 
                      dbo.VPEDIMP.PI_FEC_ENT AS FechaPedimento, dbo.PIDescarga.PID_SALDOGEN, dbo.PIDescarga.MA_CODIGO, dbo.PIDescarga.MA_GENERICO, 
                      dbo.PEDIMPDET.PID_NOPARTE, dbo.PIDescarga.pid_fechavence
FROM         dbo.PIDescarga INNER JOIN
                      dbo.VPEDIMP ON dbo.PIDescarga.PI_CODIGO = dbo.VPEDIMP.PI_CODIGO INNER JOIN
                      dbo.PEDIMPDET ON dbo.PIDescarga.PID_INDICED = dbo.PEDIMPDET.PID_INDICED INNER JOIN
                      dbo.CLAVEPED ON dbo.VPEDIMP.CP_CODIGO = dbo.CLAVEPED.CP_CODIGO
WHERE     (dbo.PIDescarga.PID_SALDOGEN > 0) AND (dbo.VPEDIMP.PI_ESTATUS<> 'R') AND (dbo.PIDescarga.PI_ACTIVOFIJO <> 'S') AND 
                      (dbo.CLAVEPED.CP_DESCARGABLE = 'S')








































GO
