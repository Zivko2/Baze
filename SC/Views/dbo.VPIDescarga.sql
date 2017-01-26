SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE (PI_ACTIVOFIJO = 'N') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='08/31/2014' and PIDescarga.pid_fechavence>='08/31/2014'
GO
