SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_IMPEXCELFACTEXP] @Codigo int    as

SET NOCOUNT ON 
DECLARE @NOPARTE VARCHAR(50),@CANTIDAD decimal(38,6),@COSTO decimal(38,6),@PESO decimal(38,6),@CONSECUTIVO INTEGER,
@MA_GRAV_MP decimal(38,6), @MA_GRAV_MO decimal(38,6), @MA_GRAV_EMP decimal(38,6), @MA_GRAV_ADD decimal(38,6), @MA_GRAV_GI decimal(38,6), 
@MA_GRAV_GI_MX decimal(38,6), @MA_NG_MP decimal(38,6), @MA_NG_EMP decimal(38,6), @MA_NG_ADD decimal(38,6), @MA_NG_USA decimal(38,6), 
@FED_indiced INT, @cf_pesos_exp CHAR(1), @TipoEntrada char,@TipoEmbarque int, @CL_DESTINI INT, @cfq_tipo char(1),
@ConCosto smallint, @fe_fecha datetime, @FE_DESTINO char(1)


	ALTER TABLE FACTEXPDET DISABLE TRIGGER Update_FactExpDet

	select @cf_pesos_exp = cf_pesos_exp from configuracion 

DELETE FROM IMPEXCELFACTEXP WHERE NOPARTE='-1'


	set @ConCosto=0

SET @TipoEntrada ='I'
SELECT @TipoEmbarque =TQ_CODIGO, @CL_DESTINI=CL_DESTINI, @fe_fecha=FE_FECHA, @FE_DESTINO=FE_DESTINO FROM FACTEXP WHERE FE_CODIGO=@Codigo


select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo=@TipoEmbarque


	-- actualiza costos en cero
	if @cfq_tipo='D'
	begin
		UPDATE IMPEXCELFACTEXP
		SET     IMPEXCELFACTEXP.COSTO= ISNULL(MAESTROCOST.MA_COSTO, 0)
		FROM         IMPEXCELFACTEXP INNER JOIN
		                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
		WHERE (IMPEXCELFACTEXP.COSTO=0 OR IMPEXCELFACTEXP.COSTO IS NULL)
		AND MAESTROCOST.TCO_CODIGO IN (SELECT TCO_DESPERDICIO FROM CONFIGURACION)
		AND MAESTROCOST.MA_PERINI <=@fe_fecha AND MAESTROCOST.MA_PERFIN >=@fe_fecha
		AND MAESTROCOST.SPI_CODIGO=22 AND ISNULL(MAESTROCOST.MA_COSTO, 0)>0
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


		-- si no encuentra tipo de costo de desperdicio asigna el de manufactura o compra
		UPDATE IMPEXCELFACTEXP
		SET     IMPEXCELFACTEXP.COSTO= ISNULL(VMAESTROCOST.MA_COSTO, 0)
		FROM         IMPEXCELFACTEXP INNER JOIN
		                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE +'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO
		WHERE VMAESTROCOST.SPI_CODIGO=22 AND (IMPEXCELFACTEXP.COSTO=0 OR IMPEXCELFACTEXP.COSTO IS NULL)
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	end
	else
	begin
		if @cfq_tipo='T' AND (select CF_TCOCOMPRAIMP from configuracion)='S'
		UPDATE IMPEXCELFACTEXP
		SET     IMPEXCELFACTEXP.COSTO= ISNULL(MAESTROCOST.MA_COSTO, 0)
		FROM         IMPEXCELFACTEXP INNER JOIN
		                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE +'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      MAESTROCOST ON MAESTRO.MA_CODIGO = MAESTROCOST.MA_CODIGO
		WHERE (IMPEXCELFACTEXP.COSTO=0 OR IMPEXCELFACTEXP.COSTO IS NULL)
		AND MAESTROCOST.TCO_CODIGO IN (SELECT TCO_COMPRA FROM CONFIGURACION)
		AND MAESTROCOST.MA_PERINI <=@fe_fecha AND MAESTROCOST.MA_PERFIN >=@fe_fecha
		AND MAESTROCOST.SPI_CODIGO=22 AND ISNULL(MAESTROCOST.MA_COSTO, 0)>0
		AND MAESTRO.MA_TIP_ENS='A'
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


		UPDATE IMPEXCELFACTEXP
		SET     IMPEXCELFACTEXP.COSTO= ISNULL(VMAESTROCOST.MA_COSTO, 0)
		FROM         IMPEXCELFACTEXP INNER JOIN MAESTRO ON IMPEXCELFACTEXP.NOPARTE +'-'+IsNull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO
		WHERE VMAESTROCOST.SPI_CODIGO=22 AND (IMPEXCELFACTEXP.COSTO=0 OR IMPEXCELFACTEXP.COSTO IS NULL)
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada

	end



	UPDATE IMPEXCELFACTEXP
	SET     IMPEXCELFACTEXP.COSTO= 0
	WHERE IMPEXCELFACTEXP.COSTO IS NULL 



IF @cf_pesos_exp='K'
BEGIN
	UPDATE IMPEXCELFACTEXP
	SET  IMPEXCELFACTEXP.PESO = isnull(MAESTRO.MA_PESO_KG,0)
	FROM         MAESTRO INNER JOIN
	                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+ isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
	WHERE MAESTRO.MA_INV_GEN=@TipoEntrada AND
	               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
	                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) =IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)

END
ELSE
BEGIN
	UPDATE IMPEXCELFACTEXP
	SET  IMPEXCELFACTEXP.PESO = isnull(MAESTRO.MA_PESO_LB,0)
	FROM         MAESTRO INNER JOIN
	                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
	WHERE MAESTRO.MA_INV_GEN=@TipoEntrada AND
	               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
	                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))=IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
END

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=20
if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS

delete from IMPEXCELFACTEXP where NOPARTE=''


if exists(SELECT dbo.IMPEXCELFACTEXP.NOPARTE
	FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
			where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
	                      dbo.IMPEXCELFACTEXP ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTEXP.NOPARTE+'-'+ISNULL(IMPEXCELFACTEXP.NOPARTEAUX,'')
	WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(MAESTROB.MA_NOPARTEAUX)) IS NULL)

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTEXP.NOPARTE +' CON EL AUX.: '+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')+' POR QUE NO EXISTE EN EL CAT. MAESTRO', 20
	FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
			where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
	                      dbo.IMPEXCELFACTEXP ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTEXP.NOPARTE+'-'+ISNULL(IMPEXCELFACTEXP.NOPARTEAUX,'')
	WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(MAESTROB.MA_NOPARTEAUX)) IS NULL




	IF EXISTS(SELECT     IMPEXCELFACTEXP.*
	FROM         MAESTRO RIGHT OUTER JOIN
	                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
	WHERE     (MAESTRO.MA_EST_MAT <>'A') /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada) 
	BEGIN

		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +IMPEXCELFACTEXP.NOPARTE+' CON EL AUX.: '+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') +' POR QUE ESTA OBSOLETO EN EL CAT. MAESTRO', 20
		FROM         MAESTRO RIGHT OUTER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (MAESTRO.MA_EST_MAT <>'A') 
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada

		DELETE IMPEXCELFACTEXP
		FROM         MAESTRO RIGHT OUTER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (MAESTRO.MA_EST_MAT <>'A') 
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada

	END


	if exists (SELECT     IMPEXCELFACTEXP.NOPARTE
		FROM         MAESTRO INNER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (NOT (MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo
                            FROM          reltembtipo
                           WHERE      tq_codigo = @TipoEmbarque)))/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada)

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'No se puede importar No. Parte : ' +IMPEXCELFACTEXP.NOPARTE+' CON EL AUX.: '+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')+' por la relacion tipo embarque-tipo material', 20
		FROM         MAESTRO INNER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (NOT (MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo FROM reltembtipo WHERE tq_codigo = @TipoEmbarque))) and
	'No se puede importar No. Parte : ' +IMPEXCELFACTEXP.NOPARTE +' por la relacion tipo embarque-tipo material' 
	not in (SELECT IML_MENSAJE FROM IMPORTLOG WHERE IML_MENSAJE IS NOT NULL)
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


	if exists(SELECT     MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
	FROM         MAESTRO
	where /*Yolanda 2009-01-21*/  maestro.ma_inv_gen = @TipoEntrada
          and MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)
	GROUP BY MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))), MAESTRO.MA_NOPARTEAUX
	HAVING      (COUNT(MA_CODIGO) > 1))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'No se puede importar No. Parte : ' + MA_NOPARTE+' CON EL AUX.: '+isnull(MA_NOPARTEAUX,'')+ ' porque esta repetido en el Cat. Maestro', 20
	FROM         MAESTRO
        WHERE (MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) IN
	                          (SELECT NOPARTE+'-'+isNull(NOPARTEAUX,'') FROM IMPEXCELFACTEXP))
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	GROUP BY  MA_NOPARTE, MAESTRO.MA_NOPARTEAUX
	HAVING      (COUNT(MA_CODIGO) > 1)  



	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR EL ARCHIVO PORQUE EL NO. PARTE : ' + NOPARTE+' CON EL AUX.: '+isnull(NOPARTEAUX,'') + ' VIENE CON LA CANTIDAD NULA', 20
	FROM         IMPEXCELFACTEXP
	WHERE CANTIDAD IS NULL OR CANTIDAD=0

	if (select cf_sicexexp from configuracion)='S'
	begin
		if (select cf_permisoaviso from configuracion)='S'
		begin
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'EL NO. PARTE: '+MAESTRO.MA_NOPARTE+' CON EL AUX.: '+isnull(MAESTRO.MA_NOPARTEAUX,'')+' NO CUENTA CON PERMISO SICEX', 20
			FROM         MAESTRO INNER JOIN
			             IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+IsNull(IMPEXCELFACTEXP.NOPARTEAUX,'')
			WHERE     MAESTRO.MA_INV_GEN = 'I' AND MAESTRO.MA_CODIGO NOT IN
			(SELECT     MAESTROCATEG.MA_CODIGO
			FROM         MAESTROCATEG INNER JOIN
			                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO LEFT OUTER JOIN
			                      IDENTIFICA INNER JOIN
			                      PERMISO ON IDENTIFICA.IDE_CODIGO = PERMISO.IDE_CODIGO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO
			WHERE     (PERMISO.PE_APROBADO = 'S') AND (IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX')))
			GROUP BY MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX
		end
		else
		if (select cf_permisoaviso from configuracion)='X'
		begin
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MAESTRO.MA_NOPARTE+' CON EL AUX.: '+isnull(MAESTRO.MA_NOPARTEAUX,'')+' PORQUE NO CUENTA CON PERMISO SICEX', 20
			FROM         MAESTRO INNER JOIN
			             IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
			WHERE     MAESTRO.MA_INV_GEN = 'I' AND MAESTRO.MA_CODIGO NOT IN
			(SELECT     MAESTROCATEG.MA_CODIGO
			FROM         MAESTROCATEG INNER JOIN
			                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO LEFT OUTER JOIN
			                      IDENTIFICA INNER JOIN
			                      PERMISO ON IDENTIFICA.IDE_CODIGO = PERMISO.IDE_CODIGO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO
			WHERE     (PERMISO.PE_APROBADO = 'S') AND (IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX')))
			GROUP BY MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX


			DELETE FROM IMPEXCELFACTEXP
			WHERE IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') IN
				(SELECT     MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
				FROM         MAESTRO INNER JOIN
				             IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
				WHERE     MAESTRO.MA_INV_GEN = 'I' AND MAESTRO.MA_CODIGO NOT IN
					(SELECT     MAESTROCATEG.MA_CODIGO
					FROM         MAESTROCATEG INNER JOIN
					                      PERMISODET ON MAESTROCATEG.CPE_CODIGO = PERMISODET.MA_GENERICO LEFT OUTER JOIN
					                      IDENTIFICA INNER JOIN
					                      PERMISO ON IDENTIFICA.IDE_CODIGO = PERMISO.IDE_CODIGO ON PERMISODET.PE_CODIGO = PERMISO.PE_CODIGO
					WHERE     (PERMISO.PE_APROBADO = 'S') AND (IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX')))
			GROUP BY MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))))
		end

	end

	--Verifica si el no. parte esta marcado como material peligroso
	if exists(SELECT    maestro.ma_noparte 
		FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 	
		where maestro.ma_inv_gen = @TipoEntrada and maestroprohibido.mp_prohibido = 'S'
          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)) and (select CF_VALIDAMATERIALPELIGROSO from Configuracion) ='S'
		BEGIN
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MA_NOPARTE+' CON EL AUX.: '+ISNULL(MA_NOPARTEAUX,'')  + ' PORQUE ESTA MARCADO COMO MATERIAL PROHIBIDO EN EL CAT. MAESTRO', 20
				FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 		
				where maestro.ma_inv_gen = @TipoEntrada and maestro.ma_peligroso = 'S'
		          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)

			DELETE FROM IMPEXCELFACTEXP WHERE NOPARTE+'-'+ISNULL(NOPARTEAUX,'') IN
			(SELECT     MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,'')))
				FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 
				where maestro.ma_inv_gen = @TipoEntrada and maestroprohibido.mp_prohibido = 'S'
		          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTEXP))


		END


	select @consecutivo=cv_codigo from consecutivo
	where cv_tipo = 'FED'


	IF @cf_pesos_exp='K'
	BEGIN


		INSERT INTO FACTEXPDET (FED_INDICED,FE_CODIGO,FED_NOPARTE,FED_COS_UNI,FED_COS_UNI_CO,
	                                                             FED_CANT,FED_PES_UNI,FED_NOMBRE,FED_NAME,MA_CODIGO,TI_CODIGO,FED_POR_DEF,
	                                                             FED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX,FED_DISCHARGE,FED_TIP_ENS,AR_IMPFO,
	 				        EQ_IMPFO,EQ_GEN,FED_DEF_TIP,FED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
					        ME_GENERICO, ME_AREXPMX, FED_GRA_MP, FED_GRA_MO, FED_GRA_EMP, FED_GRA_ADD, 
	 				FED_GRA_GI, FED_GRA_GI_MX, FED_NG_MP, FED_NG_EMP, FED_NG_ADD, 
					FED_NG_USA, FED_COS_TOT, FED_PES_NET, FED_PES_NETLB, FED_PES_BRU, FED_PES_BRULB, FED_PES_UNILB,
					FED_CANTEMP, MA_EMPAQUE, fed_SALDO,TCO_CODIGO, FED_NAFTA, CL_CODIGO,FED_PARTTYPE, SE_CODIGO, FED_NOPARTEAUX)	
	          SELECT @consecutivo+ORDEN, @Codigo, IMPEXCELFACTEXP.NOPARTE, IMPEXCELFACTEXP.COSTO,   IMPEXCELFACTEXP.COSTO,  
	                IMPEXCELFACTEXP.CANTIDAD, isnull(IMPEXCELFACTEXP.PESO,0), 'MA_NOMBRE'=CASE when @cfq_tipo='D'  then (case when MAESTRO.MA_NOMBREDESP<>'' then MAESTRO.MA_NOMBREDESP else 'DESPERDICIO DE '+MAESTRO.MA_NOMBRE end) else MAESTRO.MA_NOMBRE end, 
			'MA_NAME'=CASE when @cfq_tipo='D'  then (case when MAESTRO.MA_NAMEDESP<>'' then MAESTRO.MA_NAMEDESP else 'SCRAP OF '+MAESTRO.MA_NAME end) else MAESTRO.MA_NAME end, 
			MAESTRO.MA_CODIGO, isnull(MAESTRO.TI_CODIGO,0), DBO.GetAdvalorem(MAESTRO.AR_IMPMX, MAESTRO.PA_ORIGEN, isnull(MAESTRO.MA_DEF_TIP,'G'), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.SPI_CODIGO,0)), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.PA_ORIGEN,0), 0,
			isnull(MAESTRO.AR_IMPMX,0), isnull(MAESTRO.MA_DISCHARGE, 'S'), 'MA_TIP_ENS'=CASE WHEN @cfq_tipo='T' THEN 'C'  ELSE (case when MAESTRO.MA_TIP_ENS='A' then 'F' else MAESTRO.MA_TIP_ENS end) END, 0, 1, 1,
			isnull(MAESTRO.MA_DEF_TIP,'G'), -1, isnull(MAESTRO.ME_COM,19), 0, 1,
			isnull((SELECT ME_COM FROM VMAESTRO_GENERICO WHERE MA_CODIGO=MAESTRO.MA_GENERICO),19), 
			isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = MAESTRO.AR_EXPMX),0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		round(isnull(IMPEXCELFACTEXP.COSTO*IMPEXCELFACTEXP.CANTIDAD,0),6),
		round(isnull(IMPEXCELFACTEXP.CANTIDAD* IMPEXCELFACTEXP.PESO,0),6), 
		round(isnull(IMPEXCELFACTEXP.CANTIDAD* IMPEXCELFACTEXP.PESO * 2.20462442018378,0),6),
		round(isnull(IMPEXCELFACTEXP.CANTIDAD* IMPEXCELFACTEXP.PESO,0),6), 
		round(isnull(IMPEXCELFACTEXP.CANTIDAD* IMPEXCELFACTEXP.PESO * 2.20462442018378,0),6),
		round(isnull(IMPEXCELFACTEXP.PESO*2.20462442018378,0),6), 
		'CANTEMP'=CASE WHEN MAESTRO.MA_CANTEMP>0 THEN CEILING(IMPEXCELFACTEXP.CANTIDAD/MAESTRO.MA_CANTEMP) ELSE 0 END, 
		IsNull(MAESTRO.MA_EMPAQUE,0),IMPEXCELFACTEXP.CANTIDAD, 
		'tco_codigo'=case when @cfq_tipo='D' and (select count(ma_codigo) from maestrocost where ma_codigo=MAESTRO.ma_codigo and tco_codigo in (select tco_desperdicio from configuracion))>0 
				then (select tco_desperdicio from configuracion) else (case when @cfq_tipo='T' AND (select CF_TCOCOMPRAIMP from configuracion)='S' then (select tco_compra from configuracion) else isnull(VMAESTROCOST.TCO_CODIGO,0) end) end, 

		'N',
		isnull(@CL_DESTINI,0),
		'FED_PARTTYPE'=CASE WHEN @cfq_tipo='D' THEN 'S' 	WHEN (@cfq_tipo<>'D' AND (MAESTRO.TI_CODIGO=14 OR MAESTRO.TI_CODIGO=16))
		THEN 'A'  WHEN (@cfq_tipo<>'D' AND MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16) THEN 'U' END,
		isnull(MAESTRO.SE_CODIGO,0), MAESTRO.MA_NOPARTEAUX
		FROM         IMPEXCELFACTEXP LEFT OUTER JOIN
		                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
				      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE     (NOT (IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') NOT IN
		                          (SELECT     MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
		                            FROM          MAESTRO
		                            WHERE      MA_INV_GEN = @TipoEntrada AND TI_CODIGO IN
		                                                       (SELECT     TI_CODIGO
		                                                         FROM          RELTEMBTIPO
		                                                         WHERE      TQ_CODIGO = @TipoEmbarque) AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) = NOPARTE+'-'+isnull(NOPARTEAUX,'')))) AND 
	
				IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
								FROM         MAESTRO
								where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
								  and MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)
								GROUP BY MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
								HAVING      (COUNT(MA_CODIGO) > 1))
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
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
					FED_CANTEMP, MA_EMPAQUE, fed_SALDO, TCO_CODIGO, FED_NAFTA, CL_CODIGO, FED_PARTTYPE, SE_CODIGO, FED_NOPARTEAUX)		
	          SELECT @consecutivo+ORDEN, @Codigo, IMPEXCELFACTEXP.NOPARTE, IMPEXCELFACTEXP.COSTO,   IMPEXCELFACTEXP.COSTO,  
                         IMPEXCELFACTEXP.CANTIDAD, isnull(IMPEXCELFACTEXP.PESO,0), 'MA_NOMBRE'=CASE when @cfq_tipo='D'  then (case when MAESTRO.MA_NOMBREDESP<>'' then MAESTRO.MA_NOMBREDESP else 'DESPERDICIO DE '+MAESTRO.MA_NOMBRE end) else MAESTRO.MA_NOMBRE end, 
			'MA_NAME'=CASE when @cfq_tipo='D'  then (case when MAESTRO.MA_NAMEDESP<>'' then MAESTRO.MA_NAMEDESP else 'SCRAP OF '+MAESTRO.MA_NAME end) else MAESTRO.MA_NAME end,
			MAESTRO.MA_CODIGO, isnull(MAESTRO.TI_CODIGO,0), dbo.GetAdvalorem(MAESTRO.AR_IMPMX, MAESTRO.PA_ORIGEN, isnull(MAESTRO.MA_DEF_TIP,'G'), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.SPI_CODIGO,0)),
			 isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.PA_ORIGEN,0), 0,
			isnull(MAESTRO.AR_IMPMX,0), MAESTRO.MA_DISCHARGE, 'MA_TIP_ENS'=CASE WHEN @cfq_tipo='T' THEN 'C'  ELSE (case when MAESTRO.MA_TIP_ENS='A' then 'F' else MAESTRO.MA_TIP_ENS end) END, 0, 1, 1,
			isnull(MAESTRO.MA_DEF_TIP,'G'), -1, isnull(MAESTRO.ME_COM,19), 0, 1,
			isnull((SELECT ME_COM FROM VMAESTRO_GENERICO WHERE MA_CODIGO=MAESTRO.MA_GENERICO),19), 
			isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = MAESTRO.AR_EXPMX),19), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		round(isnull(IMPEXCELFACTEXP.COSTO*IMPEXCELFACTEXP.CANTIDAD,0),6),
		round(isnull((IMPEXCELFACTEXP.CANTIDAD* IMPEXCELFACTEXP.PESO)/2.20462442018378,0),6), round(isnull(IMPEXCELFACTEXP.CANTIDAD* IMPEXCELFACTEXP.PESO,0),6),
			round(isnull((IMPEXCELFACTEXP.CANTIDAD* IMPEXCELFACTEXP.PESO)/2.20462442018378,0),6), round(isnull(IMPEXCELFACTEXP.CANTIDAD* IMPEXCELFACTEXP.PESO,0),6),
		round(isnull(IMPEXCELFACTEXP.PESO/2.20462442018378,0),6), 'CANTEMP'=CASE WHEN MAESTRO.MA_CANTEMP>0 THEN CEILING(IMPEXCELFACTEXP.CANTIDAD/MAESTRO.MA_CANTEMP) ELSE 0 END, IsNull(MAESTRO.MA_EMPAQUE,0),
		IMPEXCELFACTEXP.CANTIDAD, 'tco_codigo'=case when @cfq_tipo='D' and (select count(ma_codigo) from maestrocost where ma_codigo=MAESTRO.ma_codigo and tco_codigo in (select tco_desperdicio from configuracion))>0 
			then (select tco_desperdicio from configuracion) else (case when @cfq_tipo='T' and MAESTRO.MA_TIP_ENS='A' AND (select CF_TCOCOMPRAIMP from configuracion)='S' then (select tco_compra from configuracion) else isnull(VMAESTROCOST.TCO_CODIGO,0) end) end, 
		'N',
		@CL_DESTINI,
		'FED_PARTTYPE'=CASE WHEN @cfq_tipo='D' THEN 'S' 	WHEN (@cfq_tipo<>'D' AND (MAESTRO.TI_CODIGO=14 OR MAESTRO.TI_CODIGO=16))
		THEN 'A'  WHEN (@cfq_tipo<>'D' AND MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16) THEN 'U' END, isnull(MAESTRO.SE_CODIGO,0), MAESTRO.MA_NOPARTEAUX
		FROM         IMPEXCELFACTEXP LEFT OUTER JOIN
	                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
	                      VMAESTROCOST ON MAESTRO.MA_CODIGO = VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
			      CONFIGURATIPO ON MAESTRO.TI_CODIGO = CONFIGURATIPO.TI_CODIGO
		WHERE     (NOT (IMPEXCELFACTEXP.NOPARTE+'-'+Isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') NOT IN
		                          (SELECT     MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
		                            FROM          MAESTRO
		                            WHERE      MA_INV_GEN = @TipoEntrada AND TI_CODIGO IN
		                                                       (SELECT     TI_CODIGO
		                                                         FROM          RELTEMBTIPO
		                                                         WHERE      TQ_CODIGO = @TipoEmbarque) AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = NOPARTE+'-'+isnull(NOPARTEAUX,'')))) AND 
	
				IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
								FROM         MAESTRO
								where /*Yolanda 2009-01-21*/  maestro.ma_inv_gen = @TipoEntrada
                						  and MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)
								GROUP BY MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
								HAVING      (COUNT(MA_CODIGO) > 1))
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	             ORDER BY ORDEN
	END


	-- Permite Exportar sin Estructura de producto 
	if (select CF_EXPSINBOM from configuracion)='N'
	begin
		if (@cfq_tipo<>'D') or (@cfq_tipo='D' and (select CF_VERIFICABOMDESPERDICIO from configuracion)='S')
		begin
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + FACTEXPDET.FED_NOPARTE+' CON EL AUX.: '+isnull(FACTEXPDET.FED_NOPARTEAUX,'')+' PORQUE NO CUENTA CON ESTRUCTURA(BOM)', 20
			FROM        FACTEXPDET 
			WHERE FACTEXPDET.FE_CODIGO=@Codigo and (FED_TIP_ENS='F' OR FED_TIP_ENS='E') AND MA_CODIGO NOT IN
				(select bsu_subensamble from bom_struct where bst_perini<=@fe_fecha and bst_perfin>=@fe_fecha group by bsu_subensamble)
			GROUP BY FACTEXPDET.FED_NOPARTE, FACTEXPDET.FED_NOPARTEAUX
	
	
			DELETE FROM FACTEXPDET 
			WHERE FACTEXPDET.FE_CODIGO=@Codigo and (FED_TIP_ENS='F' OR FED_TIP_ENS='E') AND MA_CODIGO NOT IN
				(select bsu_subensamble from bom_struct where bst_perini<=@fe_fecha and bst_perfin>=@fe_fecha group by bsu_subensamble)
		end
	end

	UPDATE FACTEXPDET
	SET FED_NAFTA=dbo.GetNafta (@fe_fecha, FACTEXPDET.MA_CODIGO, FACTEXPDET.AR_IMPMX, FACTEXPDET.PA_CODIGO, FACTEXPDET.FED_DEF_TIP, FACTEXPDET.FED_TIP_ENS)
	FROM FACTEXPDET 
	WHERE FE_CODIGO=@Codigo




	IF (SELECT CF_TCOCOMPRAIMP FROM CONFIGURACION)='S'
		UPDATE FACTEXPDET
		SET AR_IMPFO=(CASE when @cfq_tipo='D' then isnull(MAESTRO.AR_DESP,0) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and isnull(MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) and FED_NAFTA='S' then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.AR_IMPFO,0) else isnull(MAESTRO.AR_IMPFOUSA,0) end) 
			     else (CASE wheN FED_TIP_ENS ='C' then isnull(MAESTRO.AR_IMPFO,0) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.AR_IMPFOFIS,0) else isnull(MAESTRO.AR_IMPFO,0) end) end) end) end),
		EQ_IMPFO=(CASE when @cfq_tipo='D' then isnull(MAESTRO.EQ_DESP,1) else (CASE WHEN MAESTRO.TI_CODIGO<>14 AND MAESTRO.TI_CODIGO<>16 and isnull(MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) and FED_NAFTA='S'  then (case when isnull(MAESTRO.AR_IMPFOUSA,0)=0 then isnull(MAESTRO.EQ_IMPFO,1) else isnull(MAESTRO.EQ_IMPFOUSA,1) end) 
			     else (CASE wheN FED_TIP_ENS ='C' then isnull(MAESTRO.EQ_IMPFO,1) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.EQ_IMPFOFIS,1) else isnull(MAESTRO.EQ_IMPFO,1) end) end) end) end),
		AR_EXPMX=(CASE when @cfq_tipo='D' and @FE_DESTINO='N' then isnull(MAESTRO.AR_DESPMX,0) else  (CASE when FED_TIP_ENS ='C' then isnull(MAESTRO.AR_EXPMX,0) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.AR_EXPMXFIS,0) else isnull(MAESTRO.AR_EXPMX,0) end) end) end), 
		EQ_EXPMX=(CASE when @cfq_tipo='D' and @FE_DESTINO='N' then isnull(MAESTRO.EQ_DESPMX,1) else (CASE when FED_TIP_ENS ='C' then isnull(MAESTRO.EQ_EXPMX,1) else (case when MA_TIP_ENS='A' then isnull(ANEXO24.EQ_EXPMXFIS,1) else isnull(MAESTRO.EQ_EXPMX,1) end) end) end),
		MA_GENERICO=(case when MA_TIP_ENS='A' and FED_TIP_ENS ='F' then isnull(ANEXO24.MA_GENERICOFIS,0) else isnull(MAESTRO.MA_GENERICO,0) end), 
		EQ_GEN=(case when MA_TIP_ENS='A' and FED_TIP_ENS ='F' then isnull(ANEXO24.EQ_GENERICOFIS,1) else isnull(MAESTRO.EQ_GEN,1) end)
		FROM FACTEXPDET 
		  LEFT OUTER JOIN MAESTRO 
		  ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN ANEXO24 
		  ON ANEXO24.MA_CODIGO = MAESTRO.MA_CODIGO 
		WHERE FACTEXPDET.FE_CODIGO=@Codigo

	ELSE
		UPDATE FACTEXPDET
		SET AR_IMPFO=(CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.AR_DESP,0) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) and FED_NAFTA='S' then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.AR_IMPFO,0) else isnull(dbo.MAESTRO.AR_IMPFOUSA,0) end) else isnull(dbo.MAESTRO.AR_IMPFO,0) end) end),
  	            EQ_IMPFO=(CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.EQ_DESP,1) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) and FED_NAFTA='S' then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.EQ_IMPFO,1) else isnull(dbo.MAESTRO.EQ_IMPFOUSA,1) end) else isnull(dbo.MAESTRO.EQ_IMPFO,1) end) end), 
		    AR_EXPMX=(CASE when @cfq_tipo='D' and @FE_DESTINO='N' then isnull(dbo.MAESTRO.AR_DESPMX,0) else isnull(dbo.MAESTRO.AR_EXPMX,0) end),
		    EQ_EXPMX=(CASE when @cfq_tipo='D' and @FE_DESTINO='N' then isnull(dbo.MAESTRO.EQ_DESPMX,1) else isnull(dbo.MAESTRO.EQ_EXPMX,1) end),
		    MA_GENERICO=(isnull(dbo.MAESTRO.MA_GENERICO,0)), 
		    EQ_GEN=(isnull(dbo.MAESTRO.EQ_GEN,1))
		FROM FACTEXPDET 
		  LEFT OUTER JOIN MAESTRO 
		  ON FACTEXPDET.MA_CODIGO = MAESTRO.MA_CODIGO LEFT OUTER JOIN ANEXO24 
		  ON ANEXO24.MA_CODIGO = MAESTRO.MA_CODIGO 
		WHERE FACTEXPDET.FE_CODIGO=@Codigo




	UPDATE FACTEXPDET
	SET FED_RATEIMPFO=(CASE WHEN FED_NAFTA='S' THEN 0 ELSE dbo.GetAdvalorem(AR_IMPFO, 0, 'G', 0, 0) END)
	FROM FACTEXPDET 
	WHERE FE_CODIGO=@Codigo


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
	WHERE FE_CODIGO=@Codigo
	AND MAESTROCOST.MAC_CODIGO IN (SELECT MAX(M1.MAC_CODIGO) 
						FROM MAESTROCOST M1 
						WHERE M1.SPI_CODIGO = 22 AND M1.MA_PERINI <= GETDATE() AND M1.MA_PERFIN >= GETDATE() 
							AND M1.TCO_CODIGO = FACTEXPDET.TCO_CODIGO 
							AND M1.MA_CODIGO = FACTEXPDET.MA_CODIGO)
	and FACTEXPDET.tco_codigo in(SELECT TCO_CODIGO FROM TCOSTO WHERE TCO_TIPO IN ('P','N'))



	UPDATE FACTEXPDET
	set FED_COS_UNI=round(isnull(FED_GRA_MP+FED_GRA_MO+FED_GRA_EMP+ FED_GRA_ADD+
		FED_GRA_GI+ FED_GRA_GI_MX+ FED_NG_MP+ FED_NG_EMP+ FED_NG_ADD,0),6)
	FROM FACTEXPDET
	WHERE  FE_CODIGO=@Codigo
	and FACTEXPDET.tco_codigo in (select tco_manufactura from configuracion)


	UPDATE FACTEXPDET
	SET FED_COS_TOT=round(isnull(FED_COS_UNI*FED_CANT,0),6)
	WHERE  FE_CODIGO=@Codigo and FED_COS_TOT<>round(isnull(FED_COS_UNI*FED_CANT,0),6)


	UPDATE FACTEXPDET
	SET ME_AREXPMX=isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = FACTEXPDET.AR_EXPMX),19)
	WHERE FE_CODIGO=@Codigo


	  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) <> 'N'  
	  begin
		  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) = 'S' 
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
			WHERE FACTEXPDET.FE_CODIGO=@codigo
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
			WHERE FACTEXPDET.FE_CODIGO=@codigo
		  end
	end	



	update factexpdet	set ar_orig= case when fed_nafta='S' then
		 0 else ( case when isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0)=0 
		then  isnull((select AR_IMPFOUSA from maestro where maestro.ma_codigo=factexpdet.ma_codigo),0)  else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end) end
	where (ar_orig is null or ar_orig =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and fed_tip_ens<>'C'
	and fed_ng_usa>0 and fe_codigo=@Codigo
	

	update factexpdet
	set ar_ng_emp= case when fed_nafta='S' then
	 0 else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='3' and bom_arancel.ma_codigo=factexpdet.ma_codigo),0) end
	where (ar_ng_emp is null or ar_ng_emp =0) and fed_retrabajo<>'R' and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and fed_tip_ens<>'C'
	and fed_ng_emp>0 and fe_codigo=@Codigo


	UPDATE FACTEXPDET
	SET     FACTEXPDET.FED_DESTNAFTA= CASE 
	when DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_MX FROM CONFIGURACION) THEN 'M'
	 when DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_USA FROM CONFIGURACION) or DIR_CLIENTE.PA_CODIGO IN (SELECT CF_PAIS_CA FROM CONFIGURACION)
	then 'N'  WHEN 	  DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='MX-UE')) 
	then 'U' when 	  DIR_CLIENTE.PA_CODIGO IN (SELECT PA_CODIGO FROM PAIS WHERE SPI_CODIGO IN ( SELECT SPI_CODIGO FROM SPI WHERE SPI_CLAVE='AELC')) 
	then 'A'  else 'F' end
	FROM         FACTEXPDET INNER JOIN
	                      FACTEXP ON FACTEXPDET.FE_CODIGO = FACTEXP.FE_CODIGO LEFT OUTER JOIN
	                      DIR_CLIENTE ON FACTEXP.DI_DESTFIN = DIR_CLIENTE.DI_INDICE
	where  FACTEXPDET.FE_CODIGO = @Codigo 



	IF @cfq_tipo is null
	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     ' La importacion no se hizo correctamente debido a la configuracion del tipo de embarque', 20


	if @cfq_tipo='N'  and @ConCosto=1 and exists (SELECT     MAESTRO.MA_NOPARTE  
			  	    FROM         IMPEXCELFACTEXP INNER JOIN
			                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+IsNull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
				WHERE MAESTRO.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P', 'S')) /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada)
	INSERT INTO IMPORTLOG (IML_MENSAJE) 
	SELECT     ' Nota: En el archivo de excel se estan importando productos terminados, de los cuales no se tomaran los costos desde el archivo, esto debido a la division de costos'	


	select @FED_indiced= max(FED_indiced) from FACTEXPDET

	update consecutivo
	set cv_codigo =  isnull(@FED_indiced,0) + 1
	where cv_tipo = 'FED'



	TRUNCATE TABLE IMPEXCELFACTEXP

	exec SP_ACTUALIZAFED_FECHA_STRUCT @Codigo

	update factexp
	set fe_cuentadet=(select isnull(count(factexpdet.fe_codigo),0) from factexpdet where factexpdet.fe_codigo =factexp.fe_codigo)
	where fe_codigo =@Codigo

	ALTER TABLE FACTEXPDET ENABLE TRIGGER Update_FactExpDet

GO
