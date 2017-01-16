SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.vPIDescargaAll
with encryption as
SELECT     PID_INDICED, PID_SALDOGEN, MA_CODIGO, MA_GENERICO, PI_FEC_ENT, pid_fechavence, PI_CODIGO, 
(select MA_FAMILIAMP from maestro where ma_codigo=dbo.PIDescarga.ma_codigo) as MA_FAMILIAMP
FROM         dbo.PIDescarga
WHERE     PID_SALDOGEN>0

GO
