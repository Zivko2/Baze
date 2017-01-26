SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO





































CREATE PROCEDURE [dbo].[SP_CreaVPIDescargaHijoGr] (@tipo char(1), @fe_fecha varchar(11), @fedindiced int, @di_origen varchar(20)='0')   as

declare @fed_indiced varchar(50)
exec sp_droptable 'VPIDescarga', 'V'
exec sp_droptable 'VPIDescarga1', 'V'
/*
F = FACTURAS DE ACTIVO FIJO
M= FACTURAS DE MATERIAL
D=DEFINITIVA
*/



	select @fed_indiced =convert(varchar(50),@fedindiced)

	IF (SELECT CF_USAAVISOTRASLADO FROM CONFIGURACION)='S' AND @di_origen<>'0'
	BEGIN
		IF (SELECT CF_DESCARGADEFINITIVOFECHAFACT FROM CONFIGURACION)='S'
		begin
				if (SELECT CF_DESCARGAVENCIDOS FROM CONFIGURACION)='S'
				begin
					/*if @tipo='D' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM   PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE  (PI_DEFINITIVO =''S'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'')
		
			
					else*/
					if @tipo='F' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
					if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
					if @tipo='T'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
		
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				end
				else
				begin
				/*	if @tipo='D' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM   PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE  (PI_DEFINITIVO =''S'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				
					else*/
					if @tipo='F' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
					if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
					if @tipo='T'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
		
				end
		end
		else -- CF_DESCARGADEFINITIVOFECHAFACT <> 'S'
		begin
				if (SELECT CF_DESCARGAVENCIDOS FROM CONFIGURACION)='S'
				begin
					/*if @tipo='D' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM   PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE  (PI_DEFINITIVO =''S'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'')
		
			
					else*/
					if @tipo='F' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
					if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
					if @tipo='T'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
		
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				end
				else
				begin
				/*	if @tipo='D' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM   PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE  (PI_DEFINITIVO =''S'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				
					else*/
					if @tipo='F' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
					if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
					if @tipo='T'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) 
					+ ISNULL((SELECT SUM(ATIS_CANTHIJO) FROM AVISOTRASLADOSALDO WHERE (PID_INDICED = PIDescarga.PID_INDICED) AND (DI_INDICE='+@DI_ORIGEN+')),0)
					AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.DI_DEST_ORIGEN='+@di_origen+' AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
		
				end
	
		end

	END
	ELSE /*====================================================================*/
	BEGIN

		IF (SELECT CF_DESCARGADEFINITIVOFECHAFACT FROM CONFIGURACION)='S'
		begin
				if (SELECT CF_DESCARGAVENCIDOS FROM CONFIGURACION)='S'
				begin
					/*if @tipo='D' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM   PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE  (PI_DEFINITIVO =''S'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'')
		
			
					else*/
					if @tipo='F' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
					if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
					if @tipo='T'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
		
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				end
				else
				begin
				/*	if @tipo='D' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM   PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE  (PI_DEFINITIVO =''S'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				
					else*/
					if @tipo='F' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
					if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
					if @tipo='T'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, 
					CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END -
					(convert(decimal(38,6), CASE WHEN (PI_DEFINITIVO=''S'') or (pid_fechavence=''01/01/9999'' and pi_activofijo=''N'') THEN '''+@fe_fecha+''' ELSE PI_FEC_ENT END)-
					convert(decimal(38,6),PI_FEC_ENT)) * .0001 AS PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
		
				end
		end
		else -- CF_DESCARGADEFINITIVOFECHAFACT <> 'S'
		begin
				if (SELECT CF_DESCARGAVENCIDOS FROM CONFIGURACION)='S'
				begin
					/*if @tipo='D' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM   PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE  (PI_DEFINITIVO =''S'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'')
		
			
					else*/
					if @tipo='F' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
					if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
					if @tipo='T'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
					else
		
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+'''')
				end
				else
				begin
				/*	if @tipo='D' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM   PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE  (PI_DEFINITIVO =''S'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
				
					else*/
					if @tipo='F' 
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
					if @tipo='R' AND (SELECT CF_DESCARGAH1DEF FROM CONFIGURACION)='N'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PI_DEFINITIVO =''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
					if @tipo='T'
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, dbo.PIDescarga.PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					 left outer join (select pi_tipo, pi_codigo from pedimp) pedimp1 on pedimp1.pi_codigo=PIDescarga.pi_codigo
					WHERE     pedimp1.PI_TIPO IN (''A'',''C'') AND (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
					else
						exec('CREATE VIEW dbo.VPIDescarga
					AS SELECT  TOP 100 PERCENT PID_INDICED, (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0)) AS PID_SALDOGEN, PIDescarga.MA_CODIGO, MA_GENERICO, pid_fechavence, PI_CODIGO, PID_POR_DEF, PA_ORIGEN, PI_FEC_ENT,
					PID_COS_UNIDLS, MA_FAMILIAMP
					FROM         dbo.PIDescarga left outer join (select ma_codigo, MA_FAMILIAMP from maestro) maestro1 on maestro1.ma_codigo=PIDescarga.ma_codigo
					WHERE     (PI_ACTIVOFIJO = ''N'') AND (PID_SALDOGEN-ISNULL(PID_CONGELASUBMAQ,0))>0
					and dbo.PIDescarga.ma_generico in
						 (SELECT MA_GENERICO FROM MAESTRO WHERE MA_CODIGO IN 
							(SELECT  BST_HIJO
							FROM         BOM_DESCTEMP
							WHERE FED_INDICED = 0'+@fed_indiced+'			
							GROUP BY BST_HIJO) 
						AND ISNULL(ma_generico,0)<>0 
						GROUP BY MA_GENERICO)
					AND PIDescarga.PID_SALDOGEN > 0 AND PI_FEC_ENT<='''+@fe_fecha+''' and PIDescarga.pid_fechavence>='''+@fe_fecha+'''')
		
				end
	
		end
	END

GO
