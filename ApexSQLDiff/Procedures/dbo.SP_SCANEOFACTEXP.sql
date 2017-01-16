SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO











CREATE PROCEDURE [dbo].[SP_SCANEOFACTEXP] @Codigo varchar(50), @User varchar(50)   as

SET NOCOUNT ON 
exec('DECLARE @NOPARTE VARCHAR(50),@CANTIDAD decimal(38,6),@COSTO decimal(38,6),@PESO decimal(38,6),@CONSECUTIVO INTEGER,
@MA_GRAV_MP decimal(38,6), @MA_GRAV_MO decimal(38,6), @MA_GRAV_EMP decimal(38,6), @MA_GRAV_ADD decimal(38,6), @MA_GRAV_GI decimal(38,6), 
@MA_GRAV_GI_MX decimal(38,6), @MA_NG_MP decimal(38,6), @MA_NG_EMP decimal(38,6), @MA_NG_ADD decimal(38,6), @MA_NG_USA decimal(38,6), 
@FED_indiced INT, @cf_pesos_exp CHAR(1), @TipoEntrada char,@TipoEmbarque int, @CL_DESTINI INT, @cfq_tipo char(1),
@ConCosto smallint, @fe_fecha datetime, @FE_DESTINO char(1)


	ALTER TABLE FACTEXPDET DISABLE TRIGGER Update_FactExpDet

	select @cf_pesos_exp = cf_pesos_exp from configuracion 

DELETE FROM TempScaneo'+@User+' WHERE NOPARTE=''-1''


	set @ConCosto=0

SET @TipoEntrada =''I''
SELECT @TipoEmbarque =TQ_CODIGO, @CL_DESTINI=CL_DESTINI, @fe_fecha=FE_FECHA, @FE_DESTINO=FE_DESTINO FROM FACTEXP WHERE FE_CODIGO='+@Codigo+'


select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo=@TipoEmbarque


	-- actualiza costos en cero
	if @cfq_tipo=''D''
	begin
		UPDATE TempScaneo'+@User+' 
		SET     TempScaneo'+@User+'.COSTO= ISNULL(MAESTROCOST.MA_COSTO, 0)
		FROM         TempScaneo'+@User+'  INNER JOIN
		                      MAESTRO ON TempScaneo'+@User+'.NOPARTE = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
		                      MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
		WHERE (TempScaneo'+@User+'.COSTO=0 OR TempScaneo'+@User+'.COSTO IS NULL)
		AND MAESTROCOST.TCO_CODIGO IN (SELECT TCO_DESPERDICIO FROM CONFIGURACION)
		AND MAESTROCOST.MA_PERINI <=@fe_fecha AND MAESTROCOST.MA_PERFIN >=@fe_fecha
		AND MAESTROCOST.SPI_CODIGO=22 AND ISNULL(MAESTROCOST.MA_COSTO, 0)>0


		-- si no encuentra tipo de costo de desperdicio asigna el de manufactura o compra
		UPDATE TempScaneo'+@User+' 
		SET     TempScaneo'+@User+'.COSTO= ISNULL(VMAESTROCOST.MA_COSTO, 0)
		FROM         TempScaneo'+@User+'  INNER JOIN
		                      MAESTRO ON TempScaneo'+@User+'.NOPARTE = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
		                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO
		WHERE VMAESTROCOST.SPI_CODIGO=22 AND (TempScaneo'+@User+'.COSTO=0 OR TempScaneo'+@User+'.COSTO IS NULL)
	end
	else
	begin
		if @cfq_tipo=''T'' AND (select CF_TCOCOMPRAIMP from configuracion)=''S''
		UPDATE TempScaneo'+@User+' 
		SET     TempScaneo'+@User+'.COSTO= ISNULL(MAESTROCOST.MA_COSTO, 0)
		FROM         TempScaneo'+@User+'  INNER JOIN
		                      MAESTRO ON TempScaneo'+@User+'.NOPARTE = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
		                      MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
		WHERE (TempScaneo'+@User+'.COSTO=0 OR TempScaneo'+@User+'.COSTO IS NULL)
		AND MAESTROCOST.TCO_CODIGO IN (SELECT TCO_COMPRA FROM CONFIGURACION)
		AND MAESTROCOST.MA_PERINI <=@fe_fecha AND MAESTROCOST.MA_PERFIN >=@fe_fecha
		AND MAESTROCOST.SPI_CODIGO=22 AND ISNULL(MAESTROCOST.MA_COSTO, 0)>0
		AND MAESTRO.MA_TIP_ENS=''A''


		UPDATE TempScaneo'+@User+' 
		SET     TempScaneo'+@User+'.COSTO= ISNULL(VMAESTROCOST.MA_COSTO, 0)
		FROM         TempScaneo'+@User+'  INNER JOIN MAESTRO ON TempScaneo'+@User+'.NOPARTE = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
		                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO
		WHERE VMAESTROCOST.SPI_CODIGO=22 AND (TempScaneo'+@User+'.COSTO=0 OR TempScaneo'+@User+'.COSTO IS NULL)

	end



	UPDATE TempScaneo'+@User+' 
	SET     TempScaneo'+@User+'.COSTO= 0
	WHERE TempScaneo'+@User+'.COSTO IS NULL 



IF @cf_pesos_exp=''K''
BEGIN
	UPDATE TempScaneo'+@User+' 
	SET  TempScaneo'+@User+'.PESO = isnull(MAESTRO.MA_PESO_KG,0)
	FROM         MAESTRO INNER JOIN
	                      TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
	WHERE MAESTRO.MA_INV_GEN=@TipoEntrada AND
	               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
	                AND MA_EST_MAT = ''A'' AND MA_NOPARTE=TempScaneo'+@User+'.NOPARTE AND (PESO IS NULL OR PESO =0.0)
END
ELSE
BEGIN
	UPDATE TempScaneo'+@User+' 
	SET  TempScaneo'+@User+'.PESO = isnull(MAESTRO.MA_PESO_LB,0)
	FROM         MAESTRO INNER JOIN
	                      TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
	WHERE MAESTRO.MA_INV_GEN=@TipoEntrada AND
	               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
	                AND MA_EST_MAT = ''A'' AND MA_NOPARTE=TempScaneo'+@User+'.NOPARTE AND (PESO IS NULL OR PESO =0.0)
END

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=20
if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS

delete from TempScaneo'+@User+'  where NOPARTE=''''

if exists(SELECT TempScaneo'+@User+'.NOPARTE
	FROM         MAESTRO RIGHT OUTER JOIN
	                      TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
	WHERE     (MAESTRO.MA_NOPARTE IS NULL))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     ''No se puede importar No. Parte : '' +TempScaneo'+@User+'.NOPARTE +'' porque no existe en el cat. maestro'', 20
	FROM         MAESTRO RIGHT OUTER JOIN
	                      TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
	WHERE     (MAESTRO.MA_NOPARTE IS NULL) 


	IF EXISTS(SELECT     TempScaneo'+@User+'.*
	FROM         MAESTRO RIGHT OUTER JOIN
	                      TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
	WHERE     (MAESTRO.MA_EST_MAT <>''A'')) 
	BEGIN

		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     ''NO SE PUEDE IMPORTAR NO. PARTE : '' +TempScaneo'+@User+'.NOPARTE +'' POR QUE ESTA OBSOLETO EN EL CAT. MAESTRO'', 33
		FROM         MAESTRO RIGHT OUTER JOIN
		                      TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
		WHERE     (MAESTRO.MA_EST_MAT <>''A'') 

		DELETE TempScaneo'+@User+' 
		FROM         MAESTRO RIGHT OUTER JOIN
		                      TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
		WHERE     (MAESTRO.MA_EST_MAT <>''A'') 

	END


	if exists (SELECT     TempScaneo'+@User+'.NOPARTE
		FROM         MAESTRO INNER JOIN
		                      TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
		WHERE     (NOT (MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo
                            FROM          reltembtipo
                           WHERE      tq_codigo = @TipoEmbarque))))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     ''No se puede importar No. Parte : '' +TempScaneo'+@User+'.NOPARTE+'' por la relacion tipo embarque-tipo material'', 20
		FROM         MAESTRO INNER JOIN
		                      TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
		WHERE     (NOT (MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo FROM reltembtipo WHERE tq_codigo = @TipoEmbarque))) and
	''No se puede importar No. Parte : '' +TempScaneo'+@User+'.NOPARTE +'' por la relacion tipo embarque-tipo material'' 
	not in (SELECT IML_MENSAJE FROM IMPORTLOG WHERE IML_MENSAJE IS NOT NULL)


	if exists(SELECT     MAESTRO.MA_NOPARTE
	FROM         MAESTRO
	GROUP BY MA_NOPARTE
	HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
	                          (SELECT NOPARTE FROM TempScaneo'+@User+' )))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     ''No se puede importar No. Parte : '' + MA_NOPARTE + '' porque esta repetido en el Cat. Maestro'', 20
	FROM         MAESTRO
	GROUP BY MA_NOPARTE
	HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
	                          (SELECT NOPARTE FROM TempScaneo'+@User+' ))



	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     ''NO SE PUEDE IMPORTAR EL ARCHIVO PORQUE EL NO. PARTE : '' + NOPARTE + '' VIENE CON LA CANTIDAD NULA'', 20
	FROM         TempScaneo'+@User+' 
	WHERE CANTIDAD IS NULL OR CANTIDAD=0

	if (select cf_sicexexp from configuracion)=''S''
	begin
		if (select cf_permisoaviso from configuracion)=''S''
		begin
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     ''EL NO. PARTE: ''+MAESTRO.MA_NOPARTE+'' NO CUENTA CON PERMISO SICEX'', 20
			FROM         MAESTRO INNER JOIN
			             TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
			WHERE     MAESTRO.MA_INV_GEN = ''I'' AND MAESTRO.MA_CODIGO NOT IN
			(SELECT     MAESTROCATEG.MA_CODIGO
			FROM         MAESTROCATEG INNER JOIN
			                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO LEFT OUTER JOIN
			                      IDENTIFICA INNER JOIN
			                      PERMISO ON IDENTIFICA.IDE_CODIGO = PERMISO.IDE_CODIGO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO
			WHERE     (PERMISO.PE_APROBADO = ''S'') AND (IDENTIFICA.IDE_CLAVE IN (''MQ'', ''PX'')))
			GROUP BY MAESTRO.MA_NOPARTE
		end
		else
		if (select cf_permisoaviso from configuracion)=''X''
		begin
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     ''NO SE PUEDE IMPORTAR NO. PARTE : '' + MAESTRO.MA_NOPARTE+'' PORQUE NO CUENTA CON PERMISO SICEX'', 20
			FROM         MAESTRO INNER JOIN
			             TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
			WHERE     MAESTRO.MA_INV_GEN = ''I'' AND MAESTRO.MA_CODIGO NOT IN
			(SELECT     MAESTROCATEG.MA_CODIGO
			FROM         MAESTROCATEG INNER JOIN
			                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO LEFT OUTER JOIN
			                      IDENTIFICA INNER JOIN
			                      PERMISO ON IDENTIFICA.IDE_CODIGO = PERMISO.IDE_CODIGO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO
			WHERE     (PERMISO.PE_APROBADO = ''S'') AND (IDENTIFICA.IDE_CLAVE IN (''MQ'', ''PX'')))
			GROUP BY MAESTRO.MA_NOPARTE


			DELETE FROM TempScaneo'+@User+' 
			WHERE TempScaneo'+@User+'.NOPARTE IN
				(SELECT     MAESTRO.MA_NOPARTE
				FROM         MAESTRO INNER JOIN
				             TempScaneo'+@User+'  ON MAESTRO.MA_NOPARTE = TempScaneo'+@User+'.NOPARTE
				WHERE     MAESTRO.MA_INV_GEN = ''I'' AND MAESTRO.MA_CODIGO NOT IN
					(SELECT     MAESTROCATEG.MA_CODIGO
					FROM         MAESTROCATEG INNER JOIN
					                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO LEFT OUTER JOIN
					                      IDENTIFICA INNER JOIN
					                      PERMISO ON IDENTIFICA.IDE_CODIGO = PERMISO.IDE_CODIGO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO
					WHERE     (PERMISO.PE_APROBADO = ''S'') AND (IDENTIFICA.IDE_CLAVE IN (''MQ'', ''PX'')))
			GROUP BY MAESTRO.MA_NOPARTE)
		end

	end


	select @consecutivo=cv_codigo from consecutivo
	where cv_tipo = ''FED''


	IF @cf_pesos_exp=''K''
	BEGIN


		INSERT INTO FACTEXPDET (FED_INDICED,FE_CODIGO,FED_NOPARTE,FED_COS_UNI,FED_COS_UNI_CO,
	                                                             FED_CANT,FED_PES_UNI,FED_NOMBRE,FED_NAME,MA_CODIGO,TI_CODIGO,FED_POR_DEF,
	                                                             FED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX,FED_DISCHARGE,FED_TIP_ENS,AR_IMPFO,
	 				        EQ_IMPFO,EQ_GEN,FED_DEF_TIP,FED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
					        ME_GENERICO, ME_AREXPMX, FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, 
	 				FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
					FED_NG_USA, FED_COS_TOT, FED_PES_NET, FED_PES_NETLB, FED_PES_BRU, FED_PES_BRULB, FED_PES_UNILB,
					FED_CANTEMP, MA_EMPAQUE, fed_SALDO,TCO_CODIGO, FED_NAFTA, CL_CODIGO,FED_PARTTYPE, SE_CODIGO)	
	          SELECT @consecutivo+ORDEN, '+@Codigo+', TempScaneo'+@User+'.NOPARTE, TempScaneo'+@User+'.COSTO,   TempScaneo'+@User+'.COSTO,  
	                TempScaneo'+@User+'.CANTIDAD, isnull(TempScaneo'+@User+'.PESO,0), ''MA_NOMBRE''=CASE when @cfq_tipo=''D''  then (case when MAESTRO.MA_NOMBREDESP<>'''' then MAESTRO.MA_NOMBREDESP else ''DESPERDICIO DE ''+MAESTRO.MA_NOMBRE end) else MAESTRO.MA_NOMBRE end, 
			''MA_NAME''=CASE when @cfq_tipo=''D''  then (case when MAESTRO.MA_NAMEDESP<>'''' then MAESTRO.MA_NAMEDESP else ''SCRAP OF ''+MAESTRO.MA_NAME end) else MAESTRO.MA_NAME end, 
			MAESTRO.MA_CODIGO, isnull(MAESTRO.TI_CODIGO,0), dbo.GetAdvalorem(MAESTRO.AR_IMPMX, MAESTRO.PA_ORIGEN, isnull(MAESTRO.MA_DEF_TIP,''G''), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.SPI_CODIGO,0)), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.PA_ORIGEN,0), 
			isnull(MAESTRO.MA_GENERICO,0), isnull(MAESTRO.AR_IMPMX,0), isnull(MAESTRO.MA_DISCHARGE, ''S''), ''MA_TIP_ENS''=CASE WHEN @cfq_tipo=''T'' THEN ''C''  ELSE (case when MAESTRO.MA_TIP_ENS=''A'' then ''F'' else MAESTRO.MA_TIP_ENS end) END,
 			''AR_IMPFO''=CASE when @cfq_tipo=''D'' then isnull(MAESTRO.AR_DESP,0) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and isnull(MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.AR_IMPFO,0) else isnull(MAESTRO.AR_IMPFOUSA,0) end) else isnull(MAESTRO.AR_IMPFO,0) end) end,
  	                ''EQ_IMPFO''=CASE when @cfq_tipo=''D'' then isnull(MAESTRO.EQ_DESP,1) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and isnull(MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.EQ_IMPFO,1) else isnull(MAESTRO.EQ_IMPFOUSA,1) end) else isnull(MAESTRO.EQ_IMPFO,1) end) end, 
			isnull(MAESTRO.EQ_GEN,1), isnull(MAESTRO.MA_DEF_TIP,''G''), -1, isnull(MAESTRO.ME_COM,19), 
			''AR_EXPMX''=CASE when @cfq_tipo=''D'' and @FE_DESTINO=''N'' then isnull(MAESTRO.AR_DESPMX,0) else  isnull(MAESTRO.AR_EXPMX,0) end, ''EQ_EXPMX''=CASE when @cfq_tipo=''D'' and @FE_DESTINO=''N'' then isnull(MAESTRO.EQ_DESPMX,1) else isnull(MAESTRO.EQ_EXPMX,1) end, isnull((SELECT ME_COM FROM VMAESTRO_GENERICO WHERE MA_CODIGO=MAESTRO.MA_GENERICO),19), 
			isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = MAESTRO.AR_EXPMX),0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		round(isnull(TempScaneo'+@User+'.COSTO*TempScaneo'+@User+'.CANTIDAD,0),6),
		round(isnull(TempScaneo'+@User+'.CANTIDAD* TempScaneo'+@User+'.PESO,0),6), 
		round(isnull(TempScaneo'+@User+'.CANTIDAD* TempScaneo'+@User+'.PESO * 2.20462442018378,0),6),
		round(isnull(TempScaneo'+@User+'.CANTIDAD* TempScaneo'+@User+'.PESO,0),6), 
		round(isnull(TempScaneo'+@User+'.CANTIDAD* TempScaneo'+@User+'.PESO * 2.20462442018378,0),6),
		round(isnull(TempScaneo'+@User+'.PESO*2.20462442018378,0),6), 
		''CANTEMP''=CASE WHEN MAESTRO.MA_CANTEMP>0 THEN CEILING(TempScaneo'+@User+'.CANTIDAD/MAESTRO.MA_CANTEMP) ELSE 0 END, 
		IsNull(MAESTRO.MA_EMPAQUE,0),TempScaneo'+@User+'.CANTIDAD, 
		''tco_codigo''=case when @cfq_tipo=''D'' and (select count(ma_codigo) from maestrocost where ma_codigo=MAESTRO.ma_codigo and tco_codigo in (select tco_desperdicio from configuracion))>0 
				then (select tco_desperdicio from configuracion) else (case when @cfq_tipo=''T'' AND (select CF_TCOCOMPRAIMP from configuracion)=''S'' then (select tco_compra from configuracion) else isnull(VMAESTROCOST.TCO_CODIGO,0) end) end, 

		''N'',
		isnull(@CL_DESTINI,0),
		''FED_PARTTYPE''=CASE WHEN @cfq_tipo=''D'' THEN ''S'' 	WHEN (@cfq_tipo<>''D'' AND (MAESTRO.TI_CODIGO=14 OR MAESTRO.TI_CODIGO=16))
		THEN ''A''  WHEN (@cfq_tipo<>''D'' AND MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16) THEN ''U'' END,
		isnull(MAESTRO.SE_CODIGO,0)
		FROM         TempScaneo'+@User+'  LEFT OUTER JOIN
		                      MAESTRO ON TempScaneo'+@User+'.NOPARTE = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
		                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
				      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE     (NOT (TempScaneo'+@User+'.NOPARTE NOT IN
		                          (SELECT     MA_NOPARTE
		                            FROM          MAESTRO
		                            WHERE      MA_INV_GEN = @TipoEntrada AND TI_CODIGO IN
		                                                       (SELECT     TI_CODIGO
		                                                         FROM          RELTEMBTIPO
		                                                         WHERE      TQ_CODIGO = @TipoEmbarque) AND MA_NOPARTE = NOPARTE))) AND 
	
				TempScaneo'+@User+'.NOPARTE NOT IN (SELECT     MAESTRO.MA_NOPARTE
								FROM         MAESTRO
								GROUP BY MA_NOPARTE
								HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
						                          (SELECT NOPARTE FROM TempScaneo'+@User+' )))
	             ORDER BY ORDEN
	END
	ELSE
	BEGIN
		INSERT INTO FACTEXPDET (FED_INDICED,FE_CODIGO,FED_NOPARTE,FED_COS_UNI,FED_COS_UNI_CO,
	                                                             FED_CANT,FED_PES_UNILB,FED_NOMBRE,FED_NAME,MA_CODIGO,TI_CODIGO,FED_POR_DEF,
	                                                             FED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX,FED_DISCHARGE,FED_TIP_ENS,AR_IMPFO,
	 				        EQ_IMPFO,EQ_GEN,FED_DEF_TIP,FED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
					        ME_GENERICO, ME_AREXPMX, FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, 
	 				FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
					FED_NG_USA, FED_COS_TOT, FED_PES_NET, FED_PES_NETLB, FED_PES_BRU, FED_PES_BRULB, FED_PES_UNI,
					FED_CANTEMP, MA_EMPAQUE, fed_SALDO, TCO_CODIGO, FED_NAFTA, CL_CODIGO, FED_PARTTYPE, SE_CODIGO)		
	          SELECT @consecutivo+ORDEN, '+@Codigo+', TempScaneo'+@User+'.NOPARTE, TempScaneo'+@User+'.COSTO,   TempScaneo'+@User+'.COSTO,  
                         TempScaneo'+@User+'.CANTIDAD, isnull(TempScaneo'+@User+'.PESO,0), ''MA_NOMBRE''=CASE when @cfq_tipo=''D''  then (case when MAESTRO.MA_NOMBREDESP<>'''' then MAESTRO.MA_NOMBREDESP else ''DESPERDICIO DE ''+MAESTRO.MA_NOMBRE end) else MAESTRO.MA_NOMBRE end, 
			''MA_NAME''=CASE when @cfq_tipo=''D''  then (case when MAESTRO.MA_NAMEDESP<>'''' then MAESTRO.MA_NAMEDESP else ''SCRAP OF ''+MAESTRO.MA_NAME end) else MAESTRO.MA_NAME end,
			MAESTRO.MA_CODIGO, isnull(MAESTRO.TI_CODIGO,0), dbo.GetAdvalorem(MAESTRO.AR_IMPMX, MAESTRO.PA_ORIGEN, isnull(MAESTRO.MA_DEF_TIP,''G''), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.SPI_CODIGO,0)),
			 isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.PA_ORIGEN,0), 
			isnull(MAESTRO.MA_GENERICO,0), isnull(MAESTRO.AR_IMPMX,0), MAESTRO.MA_DISCHARGE, ''MA_TIP_ENS''=CASE WHEN @cfq_tipo=''T'' THEN ''C''  ELSE (case when MAESTRO.MA_TIP_ENS=''A'' then ''F'' else MAESTRO.MA_TIP_ENS end) END, 
			''AR_IMPFO''=CASE when @cfq_tipo=''D'' then isnull(MAESTRO.AR_DESP,0) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and isnull(MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.AR_IMPFO,0) else isnull(MAESTRO.AR_IMPFOUSA,0) end) else isnull(MAESTRO.AR_IMPFO,0) end) end,
  	                ''EQ_IMPFO''=CASE when @cfq_tipo=''D'' then isnull(MAESTRO.EQ_DESP,1) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and isnull(MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.EQ_IMPFO,1) else isnull(MAESTRO.EQ_IMPFOUSA,1) end) else isnull(MAESTRO.EQ_IMPFO,1) end) end, 
			isnull(MAESTRO.EQ_GEN,1), isnull(MAESTRO.MA_DEF_TIP,''G''), -1, isnull(MAESTRO.ME_COM,19), 
			''AR_EXPMX''=CASE when @cfq_tipo=''D'' and @FE_DESTINO=''N'' then isnull(MAESTRO.AR_DESPMX,0) else  isnull(MAESTRO.AR_EXPMX,0) end, ''EQ_EXPMX''=CASE when @cfq_tipo=''D'' and @FE_DESTINO=''N'' then isnull(MAESTRO.EQ_DESPMX,1) else isnull(MAESTRO.EQ_EXPMX,1) end, isnull((SELECT ME_COM FROM VMAESTRO_GENERICO WHERE MA_CODIGO=MAESTRO.MA_GENERICO),19), 
			isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = MAESTRO.AR_EXPMX),19), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		round(isnull(TempScaneo'+@User+'.COSTO*TempScaneo'+@User+'.CANTIDAD,0),6),
		round(isnull((TempScaneo'+@User+'.CANTIDAD* TempScaneo'+@User+'.PESO)/2.20462442018378,0),6), round(isnull(TempScaneo'+@User+'.CANTIDAD* TempScaneo'+@User+'.PESO,0),6),
			round(isnull((TempScaneo'+@User+'.CANTIDAD* TempScaneo'+@User+'.PESO)/2.20462442018378,0),6), round(isnull(TempScaneo'+@User+'.CANTIDAD* TempScaneo'+@User+'.PESO,0),6),
		round(isnull(TempScaneo'+@User+'.PESO/2.20462442018378,0),6), ''CANTEMP''=CASE WHEN MAESTRO.MA_CANTEMP>0 THEN CEILING(TempScaneo'+@User+'.CANTIDAD/MAESTRO.MA_CANTEMP) ELSE 0 END, IsNull(MAESTRO.MA_EMPAQUE,0),
		TempScaneo'+@User+'.CANTIDAD, ''tco_codigo''=case when @cfq_tipo=''D'' and (select count(ma_codigo) from maestrocost where ma_codigo=MAESTRO.ma_codigo and tco_codigo in (select tco_desperdicio from configuracion))>0 
			then (select tco_desperdicio from configuracion) else (case when @cfq_tipo=''T'' and MAESTRO.MA_TIP_ENS=''A'' AND (select CF_TCOCOMPRAIMP from configuracion)=''S'' then (select tco_compra from configuracion) else isnull(VMAESTROCOST.TCO_CODIGO,0) end) end, 
		''N'',
		@CL_DESTINI,
		''FED_PARTTYPE''=CASE WHEN @cfq_tipo=''D'' THEN ''S'' 	WHEN (@cfq_tipo<>''D'' AND (MAESTRO.TI_CODIGO=14 OR MAESTRO.TI_CODIGO=16))
		THEN ''A''  WHEN (@cfq_tipo<>''D'' AND MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16) THEN ''U'' END, isnull(MAESTRO.SE_CODIGO,0)
		FROM         TempScaneo'+@User+'  LEFT OUTER JOIN
	                      MAESTRO ON TempScaneo'+@User+'.NOPARTE = MAESTRO.MA_NOPARTE LEFT OUTER JOIN
	                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
			      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE     (NOT (TempScaneo'+@User+'.NOPARTE NOT IN
		                          (SELECT     MA_NOPARTE
		                            FROM          MAESTRO
		                            WHERE      MA_INV_GEN = @TipoEntrada AND TI_CODIGO IN
		                                                       (SELECT     TI_CODIGO
		                                                         FROM          RELTEMBTIPO
		                                                         WHERE      TQ_CODIGO = @TipoEmbarque) AND MA_NOPARTE = NOPARTE))) AND 
	
				TempScaneo'+@User+'.NOPARTE NOT IN (SELECT     MAESTRO.MA_NOPARTE
								FROM         MAESTRO
								GROUP BY MA_NOPARTE
								HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
						                          (SELECT NOPARTE FROM TempScaneo'+@User+' )))
	             ORDER BY ORDEN
	END

	UPDATE FACTEXPDET
	SET FED_NAFTA=GetNafta (@fe_fecha, FACTEXPDET.MA_CODIGO, FACTEXPDET.AR_IMPMX, FACTEXPDET.PA_CODIGO, FACTEXPDET.FED_DEF_TIP, FACTEXPDET.FED_TIP_ENS)
	FROM FACTEXPDET 
	WHERE FE_CODIGO='+@Codigo+' 

	UPDATE FACTEXPDET
	SET FED_RATEIMPFO=(CASE WHEN FED_NAFTA=''S'' THEN 0 ELSE dbo.GetAdvalorem(AR_IMPFO, 0, ''G'', 0, 0) END)
	FROM FACTEXPDET 
	WHERE FE_CODIGO='+@Codigo+' 


	UPDATE FACTEXPDET
	SET FED_GRA_MP=isnull(MAESTROCOST.MA_GRAV_MP,0), 
	FED_GRA_MO=isnull(MAESTROCOST.MA_GRAV_MO,0), 
	FED_GRA_EMP=isnull(MAESTROCOST.MA_GRAV_EMP,0), 
	FED_GRA_ADD=isnull(MAESTROCOST.MA_GRAV_ADD,0), 
	FED_GRA_GI=isnull(MAESTROCOST.MA_GRAV_GI,0), 
	FED_GRA_GI_MX=isnull(MAESTROCOST.MA_GRAV_GI_MX,0), 
	FED_NG_MP=isnull(MAESTROCOST.MA_NG_MP,0), 
	FED_NG_EMP=isnull(MAESTROCOST.MA_NG_EMP,0), 
	FED_NG_ADD=isnull(MAESTROCOST.MA_NG_ADD,0), 
	FED_NG_USA=isnull(MAESTROCOST.MA_NG_USA,0)
	FROM FACTEXPDET 
	LEFT OUTER JOIN MAESTROCOST ON FACTEXPDET.MA_CODIGO = MAESTROCOST.MA_CODIGO 
	AND FACTEXPDET.TCO_CODIGO = MAESTROCOST.TCO_CODIGO 
	LEFT OUTER JOIN CONFIGURATIPO ON FACTEXPDET.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
	WHERE FE_CODIGO='+@Codigo+' 
	AND MAESTROCOST.MAC_CODIGO IN (SELECT MAX(M1.MAC_CODIGO) 
						FROM MAESTROCOST M1 
						WHERE M1.SPI_CODIGO = 22 AND M1.MA_PERINI <= GETDATE() AND M1.MA_PERFIN >= GETDATE() 
							AND M1.TCO_CODIGO = FACTEXPDET.TCO_CODIGO 
							AND M1.MA_CODIGO = FACTEXPDET.MA_CODIGO)
	and FACTEXPDET.tco_codigo in(SELECT TCO_CODIGO FROM TCOSTO WHERE TCO_TIPO IN (''P'',''N''))



	UPDATE FACTEXPDET
	set FED_COS_UNI=round(isnull(FED_GRA_MP+FED_GRA_MO+FED_GRA_EMP+ FED_GRA_ADD+
		FED_GRA_GI+ FED_GRA_GI_MX+ FED_NG_MP+ FED_NG_EMP+ FED_NG_ADD,0),6)
	FROM FACTEXPDET
	WHERE  FE_CODIGO='+@Codigo+' 
	and FACTEXPDET.tco_codigo in (select tco_manufactura from configuracion)


	UPDATE FACTEXPDET
	SET FED_COS_TOT=round(isnull(FED_COS_UNI*FED_CANT,0),6)
	WHERE  FE_CODIGO='+@Codigo+' and FED_COS_TOT<>round(isnull(FED_COS_UNI*FED_CANT,0),6)


	UPDATE FACTEXPDET
	SET ME_AREXPMX=isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = FACTEXPDET.AR_EXPMX),19)
	WHERE FE_CODIGO='+@Codigo+' 


	  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) <> ''N''  
	  begin
		  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) = ''S'' 
		  begin
			INSERT INTO FACTEXPDETCARGO(CAR_CODIGO, FEG_VALOR, FEG_TIPO, FE_CODIGO, FED_INDICED)
			SELECT     CARGORELARANCEL.CAR_CODIGO, CARGODET.CARD_VALOR, CARGO.CAR_TIPO,  FACTEXPDET.FE_CODIGO, 
			                      FACTEXPDET.FED_INDICED
			FROM         FACTEXPDET INNER JOIN
			                      MAESTRO ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO INNER JOIN
			                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO INNER JOIN
			                      CARGORELARANCEL INNER JOIN
			                      CARGODET ON CARGORELARANCEL.CAR_CODIGO = CARGODET.CAR_CODIGO INNER JOIN
			                      CARGO ON CARGORELARANCEL.CAR_CODIGO = CARGO.CAR_CODIGO ON 
			                      FACTEXP.FE_FECHA >= CARGODET.CARD_FECHAINI AND FACTEXP.FE_FECHA <= CARGODET.CARD_FECHAFIN AND 
			                      FACTEXP.CL_DESTINI = CARGORELARANCEL.CL_CODIGO AND MAESTRO.AR_EXPMX = CARGORELARANCEL.AR_CODIGO
			WHERE FACTEXPDET.FE_CODIGO='+@codigo+' 
		  end
		  else
		  begin
			INSERT INTO FACTEXPDETCARGO(CAR_CODIGO, FEG_VALOR, FEG_TIPO, FE_CODIGO, FED_INDICED)
			SELECT     CARGORELARANCEL.CAR_CODIGO, CARGODET.CARD_VALOR, CARGO.CAR_TIPO,  FACTEXPDET.FE_CODIGO, 
			                      FACTEXPDET.FED_INDICED
			FROM         FACTEXPDET INNER JOIN
			                      MAESTRO ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO INNER JOIN
			                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO INNER JOIN
			                      CARGORELARANCEL INNER JOIN
			                      CARGODET ON CARGORELARANCEL.CAR_CODIGO = CARGODET.CAR_CODIGO INNER JOIN
			                      CARGO ON CARGORELARANCEL.CAR_CODIGO = CARGO.CAR_CODIGO ON 
			                      FACTEXP.FE_FECHA >= CARGODET.CARD_FECHAINI AND FACTEXP.FE_FECHA <= CARGODET.CARD_FECHAFIN AND 
			                      FACTEXP.CL_DESTINI = CARGORELARANCEL.CL_CODIGO AND MAESTRO.LIN_CODIGO = CARGORELARANCEL.LIN_CODIGO
			WHERE FACTEXPDET.FE_CODIGO='+@codigo+' 
		  end
	end	



	update factexpdet	set ar_orig= case when fed_nafta=''S'' then
		 0 else ( case when isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto=''N'' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0)=0 
		then  isnull((select AR_IMPFOUSA from maestro where maestro.ma_codigo=factexpdet.ma_codigo),0)  else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto=''N'' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end) end
	where (ar_orig is null or ar_orig =0) and fed_retrabajo<>''R'' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo=''P'' or cft_tipo=''S'') and fed_tip_ens<>''C''
	and fed_ng_usa>0 and fe_codigo='+@Codigo+' 
	

	update factexpdet
	set ar_ng_emp= case when fed_nafta=''S'' then
	 0 else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto=''3'' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end
	where (ar_ng_emp is null or ar_ng_emp =0) and fed_retrabajo<>''R'' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo=''P'' or cft_tipo=''S'') and fed_tip_ens<>''C''
	and fed_ng_emp>0 and fe_codigo='+@Codigo+' 


	UPDATE FACTEXPDET
	SET     FACTEXPDET.FED_DESTNAFTA= CASE 
	when DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) THEN ''M''
	 when DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
	then ''N''  WHEN 	  DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE=''MX-UE'')) 
	then ''U'' when 	  DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE=''AELC'')) 
	then ''A''  else ''F'' end
	FROM         FACTEXPDET INNER JOIN
	                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN
	                      DIR_CLIENTE ON FACTEXP.DI_DESTFIN = DIR_CLIENTE.DI_INDICE
	where  FACTEXPDET.FE_CODIGO = '+@Codigo+' 



	IF @cfq_tipo is null
	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     '' La importacion no se hizo correctamente debido a la configuracion del tipo de embarque'', 20


	if @cfq_tipo=''N''  and @ConCosto=1 and exists (SELECT     MAESTRO.MA_NOPARTE  
			  	    FROM         TempScaneo'+@User+'  INNER JOIN
			                      MAESTRO ON TempScaneo'+@User+'.NOPARTE = MAESTRO.MA_NOPARTE 
				WHERE MAESTRO.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN (''P'', ''S'')))
	INSERT INTO IMPORTLOG (IML_MENSAJE) 
	SELECT     '' Nota: En el archivo de excel se estan importando productos terminados, de los cuales no se tomaran los costos desde el archivo, esto debido a la division de costos''	

select @FED_indiced= max(FED_indiced) from FACTEXPDET

	update consecutivo
	set cv_codigo =  isnull(@FED_indiced,0) + 1
	where cv_tipo = ''FED''


TRUNCATE TABLE TempScaneo'+@User+' 

	exec SP_ACTUALIZAFED_FECHA_STRUCT '+@Codigo+' 

	update factexp
	set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
	where fe_codigo ='+@Codigo+' 

	ALTER TABLE FACTEXPDET ENABLE TRIGGER Update_FactExpDet')




GO
