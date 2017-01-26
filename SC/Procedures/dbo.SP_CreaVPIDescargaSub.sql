SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[SP_CreaVPIDescargaSub] (@tipo char(1), @fi_fecha varchar(11))   as


exec sp_droptable 'VPIDescargaSub', 'V'
--exec sp_droptable 'VPIDescargaSub1', 'V'
/*
F = FACTURAS DE ACTIVO FIJO
M= FACTURAS DE MATERIAL
D=DEFINITIVA
R=RETORNO
*/


		if (SELECT CF_DESCARGAVENCIDOS FROM CONFIGURACION)='S'
		begin
			if @tipo='F' 
				exec('CREATE VIEW dbo.VPIDescargaSub
			AS SELECT  TOP 100 PERCENT PIDescarga.PID_INDICED, round(ISNULL(PID_CONGELASUBMAQ,0),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, pid_fechavence, PI_CODIGO
			FROM         PIDescarga 
			WHERE     round(PIDescarga.PID_CONGELASUBMAQ,6) > 0 AND PI_FEC_ENT<='''+@fi_fecha+'''')
			else
			if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
				exec('CREATE VIEW dbo.VPIDescargaSub
			AS SELECT  TOP 100 PERCENT PIDescarga.PID_INDICED, round(ISNULL(PID_CONGELASUBMAQ,0),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, pid_fechavence, PI_CODIGO
			FROM         PIDescarga 
			 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
			WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') 
			AND round(PIDescarga.PID_CONGELASUBMAQ,6) > 0 AND PI_FEC_ENT<='''+@fi_fecha+'''')
			else
			if @tipo='T'  --retorno pero no usan definitivos
				exec('CREATE VIEW dbo.VPIDescargaSub
			AS SELECT  TOP 100 PERCENT PIDescarga.PID_INDICED, round(ISNULL(PID_CONGELASUBMAQ,0),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
			PID_COS_UNIDLS, MA_FAMILIAMP
			FROM         PIDescarga 
			 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
			WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') 
			AND round(PIDescarga.PID_CONGELASUBMAQ,6) > 0 AND PI_FEC_ENT<='''+@fi_fecha+'''')
			else
				exec('CREATE VIEW dbo.VPIDescargaSub
			AS SELECT  TOP 100 PERCENT PIDescarga.PID_INDICED, round(ISNULL(PID_CONGELASUBMAQ,0),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, pid_fechavence, PI_CODIGO
			FROM         PIDescarga 
			WHERE     (PI_ACTIVOFIJO = ''N'') 
			AND round(PIDescarga.PID_CONGELASUBMAQ,6) > 0 AND PI_FEC_ENT<='''+@fi_fecha+'''')
		end
		else
		begin
			if @tipo='F' 
				exec('CREATE VIEW dbo.VPIDescargaSub
			AS SELECT  TOP 100 PERCENT PIDescarga.PID_INDICED, round(ISNULL(PID_CONGELASUBMAQ,0),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, pid_fechavence, PI_CODIGO
			FROM         dbo.PIDescarga 
			WHERE     round(PIDescarga.PID_CONGELASUBMAQ,6) > 0 AND PI_FEC_ENT<='''+@fi_fecha+''' and PIDescarga.pid_fechavence>='''+@fi_fecha+'''')
			else
			if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
				exec('CREATE VIEW dbo.VPIDescargaSub
			AS SELECT  TOP 100 PERCENT PIDescarga.PID_INDICED, round(ISNULL(PID_CONGELASUBMAQ,0),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, pid_fechavence, PI_CODIGO
			FROM         PIDescarga 
			 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
			WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND  (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') 
			AND round(PIDescarga.PID_CONGELASUBMAQ,6) > 0 AND PI_FEC_ENT<='''+@fi_fecha+''' and PIDescarga.pid_fechavence>='''+@fi_fecha+'''')
			else
			if @tipo='T' 
				exec('CREATE VIEW dbo.VPIDescargaSub
			AS SELECT  TOP 100 PERCENT PIDescarga.PID_INDICED, round(ISNULL(PID_CONGELASUBMAQ,0),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, pid_fechavence, PI_CODIGO
			FROM         PIDescarga 
			 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
			WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND  (PI_ACTIVOFIJO = ''N'') 
			AND round(PIDescarga.PID_CONGELASUBMAQ,6) > 0 AND PI_FEC_ENT<='''+@fi_fecha+''' and PIDescarga.pid_fechavence>='''+@fi_fecha+'''')
			else
				exec('CREATE VIEW dbo.VPIDescargaSub
			AS SELECT  TOP 100 PERCENT PIDescarga.PID_INDICED, round(ISNULL(PID_CONGELASUBMAQ,0),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, pid_fechavence, PI_CODIGO
			FROM         dbo.PIDescarga 
			WHERE     (PI_ACTIVOFIJO = ''N'') 
			AND round(PIDescarga.PID_CONGELASUBMAQ,6) > 0 AND PI_FEC_ENT<='''+@fi_fecha+''' and PIDescarga.pid_fechavence>='''+@fi_fecha+'''')

		end



GO
