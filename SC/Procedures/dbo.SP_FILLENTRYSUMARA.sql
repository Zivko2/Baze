SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[SP_FILLENTRYSUMARA] (@ET_CODIGO INT)   as

declare @consecutivo int, @LINE INT

	delete from entrysumara where et_codigo=@et_codigo

	TRUNCATE TABLE TempEntrySumAra

	select @consecutivo=max(eta_codigo)+1 from entrysumara

	dbcc checkident (TempEntrySumAra, reseed, @consecutivo)	WITH NO_INFOMSGS



	INSERT INTO TempEntrySumAra(ET_CODIGO, FE_CODIGO, AR_CODIGO, ETA_TIPOIMPUESTO, ETA_RATE, MA_NAFTA, ETA_ADV_CDVCASE, ETA_CHGS, 
	                      ETA_ADV_CDVRATE, ETA_RELATIONSHIP, ETA_CANT, ETA_CANTAR, ETA_GRAV_VA, ETA_GRAV_MAT, ETA_NG_MAT, ETA_NG_EMP, ETA_NG_VA, 
	                      ETA_COS_TOT, ETA_IRC, ETA_VISA, ETA_DLLS_IRC, ETA_DLLS_VISA, ETA_DLLS_RATE,  
	                      ME_CODIGO, PA_CODIGO, AR_ORIG, ETA_NAME, AR_NG_EMP, ETA_RETRABAJO, CFT_TIPO, ETA_DLLS_MPF, ETA_MPF, ETA_WOMPF, ETA_WMPF, ETD_LINE)
	
	SELECT     ET_CODIGO, FE_CODIGO, AR_CODIGO, ETA_TIPOIMPUESTO, ETD_RATE, CASE WHEN AR_FRACCION LIKE '980%' THEN 'N' ELSE ETD_NAFTA END, isnull(ETA_ADV_CDVCASE,0), ETA_CHGS, isnull(ETA_ADV_CDVRATE,0), 
	                      ETA_RELATIONSHIP, SUM(ETA_CANT), SUM(ETA_CANTAR), SUM(ETA_GRAV_VA), SUM(ETA_GRAV_MAT), SUM(ETA_NG_MAT), SUM(ETA_NG_EMP), 
	                      SUM(ETA_NG_VA), SUM(ETA_COS_TOT), isnull(ETA_IRC,0), isnull(ETA_VISA,0), SUM(isnull(ETA_DLLS_IRC,0)), SUM(isnull(ETA_DLLS_VISA,0)), SUM(isnull(ETA_DLLS_RATE,0)), 
		         ME_CODIGO, PA_CODIGO, AR_ORIG, ETD_NAME, AR_NG_EMP, ETD_RETRABAJO, CFT_TIPO, 0, 0, 0, 0, ''
	FROM         VENTRYSUMARA
	GROUP BY ET_CODIGO, FE_CODIGO, AR_CODIGO, ETA_TIPOIMPUESTO, ETD_RATE, ETD_NAFTA, ETA_ADV_CDVCASE, ETA_CHGS, ETA_ADV_CDVRATE, 
	                      ETA_RELATIONSHIP, ETA_IRC, ETA_VISA, ME_CODIGO, PA_CODIGO, AR_ORIG, AR_NG_EMP, 
	                      ETD_RETRABAJO, CFT_TIPO, AR_FRACCION, AR_FRACCIONORIG, AR_FRACCIONEMP, ETD_NAME
	HAVING      (ET_CODIGO = @ET_CODIGO)
	ORDER BY AR_FRACCION, AR_FRACCIONORIG, AR_FRACCIONEMP

	UPDATE TempEntrySumAra
	SET ETA_MPF= (SELECT CF_MPFIM_TLC FROM CONFIGURACION)
	WHERE MA_NAFTA='S' AND ET_CODIGO=@ET_CODIGO
	
	UPDATE TempEntrySumAra
	SET ETA_MPF= (SELECT CF_MPFIM_NTLC FROM CONFIGURACION)
	WHERE (MA_NAFTA='N' OR MA_NAFTA IS NULL) AND ET_CODIGO=@ET_CODIGO
	
	
	UPDATE TempEntrySumAra
	SET ETA_DLLS_MPF = isnull((ETA_MPF/100) * ROUND(ETA_GRAV_MAT + ETA_GRAV_VA,6),0)
	WHERE ET_CODIGO=@ET_CODIGO
	
	UPDATE TempEntrySumAra
	SET ETA_WMPF=round((ETA_GRAV_MAT + ETA_GRAV_VA),0)
	WHERE ET_CODIGO=@ET_CODIGO AND ETA_DLLS_MPF>0
	
	UPDATE TempEntrySumAra
	SET ETA_WOMPF=round((ETA_GRAV_MAT + ETA_GRAV_VA),0)
	WHERE ET_CODIGO=@ET_CODIGO AND ETA_DLLS_MPF=0
	

	INSERT INTO ENTRYSUMARA (ETA_CODIGO, ET_CODIGO, FE_CODIGO, AR_CODIGO, ETA_TIPOIMPUESTO, ETD_LINE, ETA_RATE, MA_NAFTA, ETA_ADV_CDVCASE, ETA_CHGS, 
	                      ETA_ADV_CDVRATE, ETA_RELATIONSHIP, ETA_CANT, ETA_CANTAR, ETA_GRAV_VA, ETA_GRAV_MAT, ETA_NG_MAT, ETA_NG_EMP, ETA_NG_VA, 
	                      ETA_COS_TOT, ETA_IRC, ETA_VISA, ETA_DLLS_IRC, ETA_DLLS_VISA, ETA_WMPF, ETA_WOMPF, ETA_MPF, ETA_DLLS_MPF, ETA_DLLS_RATE, 
	                      SPI_CODIGO, ME_CODIGO, PA_CODIGO, ETA_PESO, AR_ORIG, ETA_NAME, AR_NG_EMP, ETA_RETRABAJO, CFT_TIPO)
	
	SELECT     ETA_CODIGO, ET_CODIGO, FE_CODIGO, AR_CODIGO, ETA_TIPOIMPUESTO, ETD_LINE, ETA_RATE, MA_NAFTA, ETA_ADV_CDVCASE, ETA_CHGS, 
	                      ETA_ADV_CDVRATE, ETA_RELATIONSHIP, ETA_CANT, ETA_CANTAR, ETA_GRAV_VA, ETA_GRAV_MAT, ETA_NG_MAT, ETA_NG_EMP, ETA_NG_VA, 
	                      ETA_COS_TOT, ETA_IRC, ETA_VISA, ETA_DLLS_IRC, ETA_DLLS_VISA, ETA_WMPF, ETA_WOMPF, ETA_MPF, ETA_DLLS_MPF, ETA_DLLS_RATE, 
	                      replace(replace(isnull(MA_NAFTA,'N'),'S', 1),'N', 11), ME_CODIGO, PA_CODIGO, ETA_PESO, AR_ORIG, ETA_NAME, AR_NG_EMP, ETA_RETRABAJO, CFT_TIPO
	FROM         TempEntrySumAra
	WHERE ET_CODIGO=@ET_CODIGO
	ORDER BY ETA_CODIGO
	
	UPDATE dbo.FACTEXPDET
	SET     dbo.FACTEXPDET.ETA_CODIGO= dbo.ENTRYSUMARA.ETA_CODIGO
	FROM         dbo.FACTEXP INNER JOIN
	                      dbo.FACTEXPDET ON dbo.FACTEXP.FE_CODIGO = dbo.FACTEXPDET.FE_CODIGO INNER JOIN
	                      dbo.ENTRYSUMARA ON dbo.FACTEXP.ET_CODIGO = dbo.ENTRYSUMARA.ET_CODIGO AND 
	                      dbo.FACTEXP.FE_CODIGO = dbo.ENTRYSUMARA.FE_CODIGO AND dbo.FACTEXPDET.AR_IMPFO = dbo.ENTRYSUMARA.AR_CODIGO AND 
	                      dbo.FACTEXPDET.FED_RATEIMPFO = dbo.ENTRYSUMARA.ETA_RATE AND dbo.FACTEXPDET.FED_NAFTA = dbo.ENTRYSUMARA.MA_NAFTA AND 
	                      dbo.FACTEXPDET.AR_NG_EMP = dbo.ENTRYSUMARA.AR_NG_EMP AND dbo.FACTEXPDET.AR_ORIG = dbo.ENTRYSUMARA.AR_ORIG
	WHERE     (dbo.FACTEXP.ET_CODIGO = @ET_CODIGO)


	
	
	UPDATE ENTRYSUMARA
	SET ETA_PESO =(SELECT     SUM(dbo.FACTEXPDET.FED_PES_BRU) AS FED_PES_BRU
			FROM         dbo.FACTEXPDET INNER JOIN
			                      dbo.ENTRYSUMARA ENTRYSUMARA_1 ON dbo.FACTEXPDET.ETA_CODIGO = ENTRYSUMARA_1.ETA_CODIGO
			WHERE     ENTRYSUMARA_1.ETA_CODIGO = ENTRYSUMARA.ETA_CODIGO)
	WHERE ENTRYSUMARA.ET_CODIGO=@ET_CODIGO


	SET @LINE=0

	UPDATE ENTRYSUMARA
	SET ETD_LINE= @LINE, @LINE=CASE WHEN @LINE=0 THEN 1 ELSE @LINE+1 END
	WHERE ET_CODIGO=@ET_CODIGO



	UPDATE TempEntrySumAra
	SET ETA_WOMPF=round((ETA_GRAV_MAT + ETA_GRAV_VA),0)
	WHERE ET_CODIGO=@ET_CODIGO AND ETA_DLLS_MPF=0



	UPDATE ENTRYSUM
	SET ET_DLLS_MPF=ISNULL((SELECT SUM(ETA_DLLS_MPF) FROM ENTRYSUMARA WHERE ENTRYSUMARA.ET_CODIGO=ENTRYSUM.ET_CODIGO),0),
	ET_DLLS_RATE=ISNULL((SELECT SUM(ETA_DLLS_RATE) FROM ENTRYSUMARA WHERE ENTRYSUMARA.ET_CODIGO=ENTRYSUM.ET_CODIGO),0),
	ET_DLLS_IRC=ISNULL((SELECT SUM(ETA_DLLS_IRC) FROM ENTRYSUMARA WHERE ENTRYSUMARA.ET_CODIGO=ENTRYSUM.ET_CODIGO),0),
	ET_DLLS_VISA=ISNULL((SELECT SUM(ETA_DLLS_VISA)  FROM ENTRYSUMARA WHERE ENTRYSUMARA.ET_CODIGO=ENTRYSUM.ET_CODIGO),0)
	WHERE ET_CODIGO=@ET_CODIGO

GO
