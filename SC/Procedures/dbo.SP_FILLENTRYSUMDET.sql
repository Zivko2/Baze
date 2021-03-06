SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [SP_FILLENTRYSUMDET] (@ET_CODIGO INT)   as


		DELETE FROM ENTRYSUMDET WHERE ET_CODIGO =@ET_CODIGO
	
	INSERT INTO ENTRYSUMDET(ET_CODIGO, FE_CODIGO, FED_INDICED, MA_CODIGO, ETD_CANT, ETD_GRAV_VA, ETD_GRAV_MAT, ETD_NG_MAT, ETD_NG_EMP, 
	                      AR_CODIGO, TI_CODIGO, EQ_IMPFO, PA_CODIGO, ETD_RATE, ETD_NAFTA, AR_ORIG, ETD_NAME, AR_NG_EMP, 
	                      ETD_RETRABAJO, ETD_COS_TOT)
	SELECT FACTEXP.ET_CODIGO, VFACTEXPDETliga.FE_CODIGO, VFACTEXPDETliga.FED_INDICED, VFACTEXPDETliga.MA_CODIGO,
	VFACTEXPDETliga.FED_CANT, 'ETD_GRAV_VA'=CASE WHEN (SELECT CF_PEDEXPVAUSA FROM CONFIGURACION)='S' THEN
	FED_CANT*(FED_GRA_GI_MX+FED_GRA_GI+FED_GRA_MO) ELSE FED_CANT*(FED_GRA_GI_MX+FED_GRA_MO) END,
	FED_CANT * ((FED_GRA_MP + FED_GRA_ADD + FED_GRA_EMP + FED_NG_MP + FED_NG_ADD) - FED_NG_USA) AS ETD_GRAV_MAT,
	'ETD_NG_MAT'=CASE WHEN (SELECT CF_PEDEXPVAUSA FROM CONFIGURACION)='S' THEN
	FED_CANT * FED_NG_USA else FED_CANT * (FED_NG_USA + FED_GRA_GI) END,
	FED_CANT * FED_NG_EMP AS ETD_NG_EMP, VFACTEXPDETliga.AR_IMPFO, VFACTEXPDETliga.TI_CODIGO,
	VFACTEXPDETliga.EQ_IMPFO, VFACTEXPDETliga.PA_CODIGO, VFACTEXPDETliga.FED_RATEIMPFO, VFACTEXPDETliga.FED_NAFTA,
	VFACTEXPDETliga.AR_ORIG, VFACTEXPDETliga.FED_NAME, VFACTEXPDETliga.AR_NG_EMP, CASE WHEN
	VFACTEXPDETliga.FED_RETRABAJO='R' THEN 'S' ELSE 'N' END, 0
	FROM         VFACTEXPDETliga INNER JOIN
	                      FACTEXP ON VFACTEXPDETliga.FE_CODIGO = FACTEXP.FE_CODIGO INNER JOIN
	                      CONFIGURATEMBARQUE ON FACTEXP.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO INNER JOIN
	                      CONFIGURATIPO ON VFACTEXPDETliga.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
	WHERE     (CONFIGURATIPO.CFT_TIPO = 'P' OR
	                      CONFIGURATIPO.CFT_TIPO = 'S') AND (CONFIGURATEMBARQUE.CFQ_TIPO <> 'T' AND CONFIGURATEMBARQUE.CFQ_TIPO <> 'D')
	AND (FACTEXP.ET_CODIGO = @ET_CODIGO)
	ORDER BY FACTEXP.ET_CODIGO
	
	
	INSERT INTO ENTRYSUMDET(ET_CODIGO, FE_CODIGO, FED_INDICED, MA_CODIGO, ETD_CANT, ETD_GRAV_MAT, ETD_NG_MAT, ETD_NG_EMP, 
	                      AR_CODIGO, TI_CODIGO, EQ_IMPFO, PA_CODIGO, ETD_RATE, ETD_NAFTA, AR_ORIG, ETD_NAME, AR_NG_EMP, 
	                      ETD_RETRABAJO, ETD_COS_TOT)
	
	SELECT FACTEXP.ET_CODIGO, VFACTEXPDETliga.FE_CODIGO, VFACTEXPDETliga.FED_INDICED, VFACTEXPDETliga.MA_CODIGO,
	VFACTEXPDETliga.FED_CANT, 'ETD_GRAV_MAT'=CASE WHEN FED_NAFTA ='N' and CONFIGURATIPO.CFT_TIPO<>'E' THEN FED_CANT * FED_COS_UNI  ELSE 0 END,
	'ETD_NG_MAT'=CASE WHEN FED_NAFTA ='S' and CONFIGURATIPO.CFT_TIPO<>'E' THEN FED_CANT * FED_COS_UNI ELSE 0 END,
	'ETD_NG_EMP'=CASE WHEN CONFIGURATIPO.CFT_TIPO='E' THEN FED_CANT * FED_COS_UNI ELSE 0 END, VFACTEXPDETliga.AR_IMPFO, VFACTEXPDETliga.TI_CODIGO,
	VFACTEXPDETliga.EQ_IMPFO, VFACTEXPDETliga.PA_CODIGO, VFACTEXPDETliga.FED_RATEIMPFO, VFACTEXPDETliga.FED_NAFTA,
	VFACTEXPDETliga.AR_ORIG, VFACTEXPDETliga.FED_NAME, VFACTEXPDETliga.AR_NG_EMP, CASE WHEN
	VFACTEXPDETliga.FED_RETRABAJO='R' THEN 'S' ELSE 'N' END, 0
	FROM         VFACTEXPDETliga INNER JOIN
	                      FACTEXP ON VFACTEXPDETliga.FE_CODIGO = FACTEXP.FE_CODIGO INNER JOIN
	                      CONFIGURATEMBARQUE ON FACTEXP.TQ_CODIGO = CONFIGURATEMBARQUE.TQ_CODIGO INNER JOIN
	                      CONFIGURATIPO ON VFACTEXPDETliga.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
	WHERE     ((CONFIGURATIPO.CFT_TIPO <> 'P' AND
	                      CONFIGURATIPO.CFT_TIPO <> 'S') OR (CONFIGURATEMBARQUE.CFQ_TIPO = 'T' OR CONFIGURATEMBARQUE.CFQ_TIPO = 'D'))
	AND (FACTEXP.ET_CODIGO = @ET_CODIGO)
	ORDER BY FACTEXP.ET_CODIGO
	
	
	
	UPDATE ENTRYSUMDET
	SET ETD_COS_TOT  =  ETD_GRAV_VA+ETD_GRAV_MAT+ ETD_NG_MAT+ETD_NG_EMP
	WHERE ET_CODIGO=@ET_CODIGO

	--exec SP_FILLENTRYSUMARA @ET_CODIGO



GO
