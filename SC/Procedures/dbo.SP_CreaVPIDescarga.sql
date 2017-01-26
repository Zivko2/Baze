SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[SP_CreaVPIDescarga] (@tipo char(1), @fe_fecha varchar(11), @di_origen varchar(20)='0')    as


exec sp_droptable 'VPIDescarga', 'V'
--exec sp_droptable 'VPIDescarga1', 'V'
/*
F = FACTURAS DE ACTIVO FIJO
M= FACTURAS DE MATERIAL
D=DEFINITIVA
R=RETORNO
C=Cuenta Aduanera
*/

	IF (SELECT CF_USAAVISOTRASLADO FROM CONFIGURACION)='S' AND @di_origen<>'0'
	BEGIN
		IF (SELECT CF_DESCARGADEFINITIVOFECHAFACT FROM CONFIGURACION)='S'
		begin
	
			if (SELECT CF_DESCARGAVENCIDOS FROM CONFIGURACION)='S'
			begin

				if @tipo='C' 
					exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				 FROM (SELECT ma_codigo, MA_FAMILIAMP FROM maestro) maestro1 RIGHT OUTER JOIN
				      (SELECT PI_CODIGO, CP_CODIGO FROM PEDIMP) pedimp1 LEFT OUTER JOIN CONFIGURACLAVEPED ON pedimp1.CP_CODIGO = CONFIGURACLAVEPED.CP_CODIGO RIGHT OUTER JOIN
				      PIDescarga ON pedimp1.PI_CODIGO = PIDescarga.PI_CODIGO ON maestro1.ma_codigo = PIDescarga.MA_CODIGO
				WHERE     CONFIGURACLAVEPED.CCP_TIPO=''IC'' AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='F' 
					exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE     round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
					exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='T'  --retorno pero no usan definitivos
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE     (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
			end
			else
			begin

				if @tipo='C' 
				exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				 FROM (SELECT ma_codigo, MA_FAMILIAMP FROM maestro) maestro1 RIGHT OUTER JOIN
				      (SELECT PI_CODIGO, CP_CODIGO FROM PEDIMP) pedimp1 LEFT OUTER JOIN CONFIGURACLAVEPED ON pedimp1.CP_CODIGO = CONFIGURACLAVEPED.CP_CODIGO RIGHT OUTER JOIN
				      PIDescarga ON pedimp1.PI_CODIGO = PIDescarga.PI_CODIGO ON maestro1.ma_codigo = PIDescarga.MA_CODIGO
				WHERE     CONFIGURACLAVEPED.CCP_TIPO=''IC'' AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='F' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE     round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='T' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND AND (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE     (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
	
			end
		end
		else
		begin
	
			if (SELECT CF_DESCARGAVENCIDOS FROM CONFIGURACION)='S'
			begin
				if @tipo='C' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				 FROM (SELECT ma_codigo, MA_FAMILIAMP FROM maestro) maestro1 RIGHT OUTER JOIN
				      (SELECT PI_CODIGO, CP_CODIGO FROM PEDIMP) pedimp1 LEFT OUTER JOIN CONFIGURACLAVEPED ON pedimp1.CP_CODIGO = CONFIGURACLAVEPED.CP_CODIGO RIGHT OUTER JOIN
				      PIDescarga ON pedimp1.PI_CODIGO = PIDescarga.PI_CODIGO ON maestro1.ma_codigo = PIDescarga.MA_CODIGO
				WHERE     CONFIGURACLAVEPED.CCP_TIPO=''IC'' AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='F' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='T'  --retorno pero no usan definitivos
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
			end
			else
			begin

				 
				if @tipo='C' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM (SELECT ma_codigo, MA_FAMILIAMP FROM maestro) maestro1 RIGHT OUTER JOIN
				      (SELECT PI_CODIGO, CP_CODIGO FROM PEDIMP) pedimp1 LEFT OUTER JOIN CONFIGURACLAVEPED ON pedimp1.CP_CODIGO = CONFIGURACLAVEPED.CP_CODIGO RIGHT OUTER JOIN
				      PIDescarga ON pedimp1.PI_CODIGO = PIDescarga.PI_CODIGO ON maestro1.ma_codigo = PIDescarga.MA_CODIGO
				WHERE     CONFIGURACLAVEPED.CCP_TIPO=''IC'' AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else

				if @tipo='F' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
				AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='T' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
	
			end
		end

	END
	ELSE  /*==============================================================================================================================*/
	BEGIN
		IF (SELECT CF_DESCARGADEFINITIVOFECHAFACT FROM CONFIGURACION)='S'
		begin
	
			if (SELECT CF_DESCARGAVENCIDOS FROM CONFIGURACION)='S'
			begin

				if @tipo='C' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM (SELECT ma_codigo, MA_FAMILIAMP FROM maestro) maestro1 RIGHT OUTER JOIN
				      (SELECT PI_CODIGO, CP_CODIGO FROM PEDIMP) pedimp1 LEFT OUTER JOIN CONFIGURACLAVEPED ON pedimp1.CP_CODIGO = CONFIGURACLAVEPED.CP_CODIGO RIGHT OUTER JOIN
				      PIDescarga ON pedimp1.PI_CODIGO = PIDescarga.PI_CODIGO ON maestro1.ma_codigo = PIDescarga.MA_CODIGO
				WHERE     CONFIGURACLAVEPED.CCP_TIPO=''IC'' AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='F' 
				--Yolanda Avila
				--2010-05-05
				--La linea del where tenia un 'AND' que no debe llevar
				/*
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				*/
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')


				else
				if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='T'  --retorno pero no usan definitivos
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				--Yolanda Avila
				--2010-05-05
				--La linea del where tenia un 'AND' que no debe llevar
				/*
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE AND (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				*/
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')

			end
			else
			begin

				if @tipo='C' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM (SELECT ma_codigo, MA_FAMILIAMP FROM maestro) maestro1 RIGHT OUTER JOIN
				      (SELECT PI_CODIGO, CP_CODIGO FROM PEDIMP) pedimp1 LEFT OUTER JOIN CONFIGURACLAVEPED ON pedimp1.CP_CODIGO = CONFIGURACLAVEPED.CP_CODIGO RIGHT OUTER JOIN
				      PIDescarga ON pedimp1.PI_CODIGO = PIDescarga.PI_CODIGO ON maestro1.ma_codigo = PIDescarga.MA_CODIGO
				WHERE     CONFIGURACLAVEPED.CCP_TIPO=''IC'' AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='F' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='T' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, 
				CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
				(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
				convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
	
			end
		end
		else
		begin
	
			if (SELECT CF_DESCARGAVENCIDOS FROM CONFIGURACION)='S'
			begin
				if @tipo='C' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM (SELECT ma_codigo, MA_FAMILIAMP FROM maestro) maestro1 RIGHT OUTER JOIN
				      (SELECT PI_CODIGO, CP_CODIGO FROM PEDIMP) pedimp1 LEFT OUTER JOIN CONFIGURACLAVEPED ON pedimp1.CP_CODIGO = CONFIGURACLAVEPED.CP_CODIGO RIGHT OUTER JOIN
				      PIDescarga ON pedimp1.PI_CODIGO = PIDescarga.PI_CODIGO ON maestro1.ma_codigo = PIDescarga.MA_CODIGO
				WHERE     CONFIGURACLAVEPED.CCP_TIPO=''IC'' AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='F' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
				if @tipo='T'  --retorno pero no usan definitivos
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				else
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
			end
			else
			begin

				if @tipo='C' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM (SELECT ma_codigo, MA_FAMILIAMP FROM maestro) maestro1 RIGHT OUTER JOIN
				      (SELECT PI_CODIGO, CP_CODIGO FROM PEDIMP) pedimp1 LEFT OUTER JOIN CONFIGURACLAVEPED ON pedimp1.CP_CODIGO = CONFIGURACLAVEPED.CP_CODIGO RIGHT OUTER JOIN
				      PIDescarga ON pedimp1.PI_CODIGO = PIDescarga.PI_CODIGO ON maestro1.ma_codigo = PIDescarga.MA_CODIGO
				WHERE     CONFIGURACLAVEPED.CCP_TIPO=''IC'' AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else

				if @tipo='F' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
				if @tipo='T' 
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PiDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
				WHERE  pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				else
					exec('CREATE VIEW dbo.VPIDescarga
				AS SELECT  TOP 100 PERCENT PID_INDICED, round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PIDescarga.PI_CODIGO, PI_FEC_ENT,
				MA_FAMILIAMP, PID_IDDESCARGA, PID_COS_UNIDLS
				FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
				WHERE (PI_ACTIVOFIJO = ''N'') AND round((PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)),6)>0
				AND round(PIDescarga.PID_SALDOGEN,6) > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
	
			end
		end
	END

GO
