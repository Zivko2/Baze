SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_IMPEXCELLISTAEXP] @Codigo int,@TipoEntrada char,@TipoEmbarque int   as

SET NOCOUNT ON 
DECLARE @NOPARTE VARCHAR(50),@CANTIDAD decimal(38,6),@COSTO decimal(38,6),@PESO decimal(38,6),@CONSECUTIVO INTEGER,
@MA_GRAV_MP decimal(38,6), @MA_GRAV_MO decimal(38,6), @MA_GRAV_EMP decimal(38,6), @MA_GRAV_ADD decimal(38,6), @MA_GRAV_GI decimal(38,6), 
@MA_GRAV_GI_MX decimal(38,6), @MA_NG_MP decimal(38,6), @MA_NG_EMP decimal(38,6), @MA_NG_ADD decimal(38,6), @MA_NG_USA decimal(38,6), 
@LED_indiced INT, @cf_pesos_exp CHAR(1), @CL_DESTINI INT, @cfq_tipo char(1),
@ConCosto smallint, @LE_fecha datetime, @LE_DESTINO char(1)




	select @cf_pesos_exp = cf_pesos_exp from configuracion 

DELETE FROM IMPEXCELFACTEXP WHERE NOPARTE='-1'


	set @ConCosto=0

SELECT @CL_DESTINI=CL_CODIGO, @LE_fecha=LE_FECHA FROM LISTAEXP WHERE LE_CODIGO=@Codigo


select @cfq_tipo=cfq_tipo from configuratembarque where tq_codigo=@TipoEmbarque

if (select cf_tipocosto from configuracion)='N'
begin


	if exists(SELECT     dbo.IMPEXCELFACTEXP.COSTO
	FROM         dbo.IMPEXCELFACTEXP INNER JOIN
	                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
	                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
	WHERE dbo.MAESTRO.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P', 'S'))
	AND  dbo.VMAESTROCOST.SPI_CODIGO=22 AND dbo.IMPEXCELFACTEXP.COSTO>0 AND  dbo.IMPEXCELFACTEXP.COSTO IS NOT NULL /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada)
	set @ConCosto=1


	UPDATE dbo.IMPEXCELFACTEXP
	SET     dbo.IMPEXCELFACTEXP.COSTO= round(ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0),6)
	FROM         dbo.IMPEXCELFACTEXP INNER JOIN
	                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
	                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
	WHERE dbo.VMAESTROCOST.SPI_CODIGO=22 AND (dbo.IMPEXCELFACTEXP.COSTO=0 OR dbo.IMPEXCELFACTEXP.COSTO IS NULL)
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


	UPDATE dbo.IMPEXCELFACTEXP
	SET     dbo.IMPEXCELFACTEXP.COSTO= round(ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0),6)
	FROM         dbo.IMPEXCELFACTEXP INNER JOIN
	                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
	                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
	WHERE dbo.VMAESTROCOST.SPI_CODIGO=22 AND 
		dbo.MAESTRO.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P', 'S'))
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
end
else
begin
	if @cfq_tipo='D'
	begin
		UPDATE dbo.IMPEXCELFACTEXP
		SET     dbo.IMPEXCELFACTEXP.COSTO= ISNULL(dbo.MAESTROCOST.MA_COSTO, 0)
		FROM         dbo.IMPEXCELFACTEXP INNER JOIN
		                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      dbo.MAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO
		WHERE (dbo.IMPEXCELFACTEXP.COSTO=0 OR dbo.IMPEXCELFACTEXP.COSTO IS NULL)
		AND dbo.MAESTROCOST.TCO_CODIGO IN (SELECT TCO_DESPERDICIO FROM CONFIGURACION)
		AND dbo.MAESTROCOST.MA_PERINI <=@LE_fecha AND dbo.MAESTROCOST.MA_PERFIN >=@LE_fecha
		AND dbo.MAESTROCOST.SPI_CODIGO=22 AND ISNULL(dbo.MAESTROCOST.MA_COSTO, 0)>0
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


		-- si no encuentra tipo de costo de desperdicio asigna el de manufactura o compra
		UPDATE dbo.IMPEXCELFACTEXP
		SET     dbo.IMPEXCELFACTEXP.COSTO= ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0)
		FROM         dbo.IMPEXCELFACTEXP INNER JOIN
		                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
		WHERE dbo.VMAESTROCOST.SPI_CODIGO=22 AND (dbo.IMPEXCELFACTEXP.COSTO=0 OR dbo.IMPEXCELFACTEXP.COSTO IS NULL)
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	end
	else
	begin
		if @cfq_tipo='T'
		UPDATE dbo.IMPEXCELFACTEXP
		SET     dbo.IMPEXCELFACTEXP.COSTO= ISNULL(dbo.MAESTROCOST.MA_COSTO, 0)
		FROM         dbo.IMPEXCELFACTEXP INNER JOIN
		                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      dbo.MAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO
		WHERE (dbo.IMPEXCELFACTEXP.COSTO=0 OR dbo.IMPEXCELFACTEXP.COSTO IS NULL)
		AND dbo.MAESTROCOST.TCO_CODIGO IN (SELECT TCO_COMPRA FROM CONFIGURACION)
		AND dbo.MAESTROCOST.MA_PERINI <=@LE_fecha AND dbo.MAESTROCOST.MA_PERFIN >=@LE_fecha
		AND dbo.MAESTROCOST.SPI_CODIGO=22 AND ISNULL(dbo.MAESTROCOST.MA_COSTO, 0)>0
		AND dbo.MAESTRO.MA_TIP_ENS='A'
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


		UPDATE dbo.IMPEXCELFACTEXP
		SET     dbo.IMPEXCELFACTEXP.COSTO= ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0)
		FROM         dbo.IMPEXCELFACTEXP INNER JOIN		                      
                                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
		WHERE dbo.VMAESTROCOST.SPI_CODIGO=22 AND (dbo.IMPEXCELFACTEXP.COSTO=0 OR dbo.IMPEXCELFACTEXP.COSTO IS NULL)
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada

	end
end


	UPDATE dbo.IMPEXCELFACTEXP
	SET     dbo.IMPEXCELFACTEXP.COSTO= 0
	WHERE dbo.IMPEXCELFACTEXP.COSTO IS NULL 



IF @cf_pesos_exp='K'
BEGIN
	UPDATE dbo.IMPEXCELFACTEXP
	SET  dbo.IMPEXCELFACTEXP.PESO = isnull(dbo.MAESTRO.MA_PESO_KG,0)
	FROM         dbo.MAESTRO INNER JOIN
	                      IMPEXCELFACTEXP ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
	WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
	               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
	                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))=IMPEXCELFACTEXP.NOPARTE+'-'+ISNULL(IMPEXCELFACTEXP.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
END
ELSE
BEGIN
	UPDATE dbo.IMPEXCELFACTEXP
	SET  dbo.IMPEXCELFACTEXP.PESO = isnull(dbo.MAESTRO.MA_PESO_LB,0)
	FROM         dbo.MAESTRO INNER JOIN
	                      IMPEXCELFACTEXP ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
	WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
	               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
	                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) =IMPEXCELFACTEXP.NOPARTE+'-'+ISNULL(IMPEXCELFACTEXP.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
END

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=26
if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS


delete from IMPEXCELFACTEXP where NOPARTE=''


if exists(SELECT dbo.IMPEXCELFACTEXP.NOPARTE
	FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
			where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
	                      dbo.IMPEXCELFACTEXP ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTEXP.NOPARTE+'-'+ISNULL(IMPEXCELFACTEXP.NOPARTEAUX,'')
	WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) IS NULL)

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTEXP.NOPARTE +' CON EL AUX.: '+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')+' POR QUE NO EXISTE EN EL CAT. MAESTRO', 20
	FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
			where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
	                      dbo.IMPEXCELFACTEXP ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTEXP.NOPARTE+'-'+ISNULL(IMPEXCELFACTEXP.NOPARTEAUX,'')
	WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) IS NULL



	IF EXISTS(SELECT     dbo.IMPEXCELFACTEXP.*
	FROM         dbo.MAESTRO RIGHT OUTER JOIN
	                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
	WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A')/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada) 
	BEGIN

		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTEXP.NOPARTE+' CON EL AUX.: '+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') +' POR QUE ESTA OBSOLETO EN EL CAT. MAESTRO', 33
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') 
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada

		DELETE dbo.IMPEXCELFACTEXP
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') 
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada

	END

	--Verifica si el no. parte esta marcado como material peligroso
	if exists(SELECT    maestro.ma_noparte 
		FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 	
		where maestro.ma_inv_gen = @TipoEntrada and maestroprohibido.mp_prohibido = 'S'
          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)) and (select CF_VALIDAMATERIALPELIGROSO from Configuracion) ='S'
		BEGIN
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MA_NOPARTE+' CON EL AUX.: '+ISNULL(MA_NOPARTEAUX,'')  + ' PORQUE ESTA MARCADO COMO MATERIAL PROHIBIDO EN EL CAT. MAESTRO', 26
				FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 		
				where maestro.ma_inv_gen = @TipoEntrada and maestro.ma_peligroso = 'S'
		          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)

			DELETE FROM IMPEXCELFACTEXP WHERE NOPARTE+'-'+ISNULL(NOPARTEAUX,'') IN
			(SELECT     MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,'')))
				FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 
				where maestro.ma_inv_gen = @TipoEntrada and maestroprohibido.mp_prohibido = 'S'
		          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTEXP))


		END


	if exists (SELECT     dbo.IMPEXCELFACTEXP.NOPARTE
		FROM         dbo.MAESTRO INNER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (NOT (dbo.MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo
                            FROM          reltembtipo
                           WHERE      tq_codigo = @TipoEmbarque)))/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada)

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'No se puede importar No. Parte : ' +dbo.IMPEXCELFACTEXP.NOPARTE+' CON EL AUX.: '+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')+' por la relacion tipo embarque-tipo material', 2
		FROM         dbo.MAESTRO INNER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) = IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (NOT (dbo.MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo FROM reltembtipo WHERE tq_codigo = @TipoEmbarque))) and
	'No se puede importar No. Parte : ' +dbo.IMPEXCELFACTEXP.NOPARTE+' CON EL AUX.: '+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') +' por la relacion tipo embarque-tipo material' 
	not in (SELECT IML_MENSAJE FROM IMPORTLOG WHERE IML_MENSAJE IS NOT NULL)
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


	if exists(SELECT     dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
	FROM         dbo.MAESTRO
	where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
          and MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) in (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)
	GROUP BY MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
	HAVING      (COUNT(MA_CODIGO) > 1))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'No se puede importar No. Parte : ' + MA_NOPARTE+' CON EL AUX.: '+isnull(MA_NOPARTEAUX,'') + ' porque esta repetido en el Cat. Maestro', 26
	FROM         dbo.MAESTRO
	where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
          and MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) in (SELECT NOPARTE+'-'+isnull(noparteaux,'') FROM IMPEXCELFACTEXP)
	GROUP BY MA_NOPARTE, MA_NOPARTEAUX
	HAVING      (COUNT(MA_CODIGO) > 1)


	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR EL ARCHIVO PORQUE EL NO. PARTE : ' + NOPARTE+' CON EL AUX.: '+isnull(NOPARTEAUX,'') + ' VIENE CON LA CANTIDAD NULA', 26
	FROM         dbo.IMPEXCELFACTEXP
	WHERE CANTIDAD IS NULL OR CANTIDAD=0




	select @consecutivo=cv_codigo from consecutivo
	where cv_tipo = 'LED'


	IF @cf_pesos_exp='K'
	BEGIN


		INSERT INTO LISTAEXPDET (LED_INDICED,LE_CODIGO,LED_NOPARTE,LED_COS_UNI,
	                                                             LED_CANT,LED_PES_UNI,LED_NOMBRE,LED_NAME,MA_CODIGO,TI_CODIGO,LED_POR_DEF,
	                                                             LED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX,AR_IMPFO,
	 				        EQ_IMPFO,EQ_GEN,LED_DEF_TIP,LED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
					        LED_GRA_MP, LED_GRA_MO, LED_GRA_EMP, LED_GRA_ADD, 
	 				LED_GRA_GI, LED_GRA_GI_MX, LED_NG_MP, LED_NG_EMP, LED_NG_ADD, 
					LED_NG_USA, LED_COS_TOT, LED_PES_NET, LED_PES_NETLB, LED_PES_BRU, LED_PES_BRULB, LED_PES_UNILB,
					LED_CANTEMP, MA_EMPAQUE, LED_SALDO,TCO_CODIGO, LED_TIP_ENS, LED_NAFTA, LED_NOPARTEAUX)	

	          SELECT @consecutivo+ORDEN, @Codigo, dbo.IMPEXCELFACTEXP.NOPARTE, dbo.IMPEXCELFACTEXP.COSTO,   
	                dbo.IMPEXCELFACTEXP.CANTIDAD, isnull(dbo.IMPEXCELFACTEXP.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
			dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.PA_ORIGEN,0), 
			isnull(dbo.MAESTRO.MA_GENERICO,0), isnull(dbo.MAESTRO.AR_IMPMX,0), 'AR_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.AR_DESP,0) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.AR_IMPFO,0) else isnull(dbo.MAESTRO.AR_IMPFOUSA,0) end) else isnull(dbo.MAESTRO.AR_IMPFO,0) end) end,
  	                'EQ_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.EQ_DESP,1) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.EQ_IMPFO,1) else isnull(dbo.MAESTRO.EQ_IMPFOUSA,1) end) else isnull(dbo.MAESTRO.EQ_IMPFO,1) end) end, 
			isnull(dbo.MAESTRO.EQ_GEN,1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), -1, isnull(dbo.MAESTRO.ME_COM,19), 
			'AR_EXPMX'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.AR_DESPMX,0) else  isnull(dbo.MAESTRO.AR_EXPMX,0) end, 'EQ_EXPMX'=CASE when @cfq_tipo='D'  then isnull(dbo.MAESTRO.EQ_DESPMX,1) else isnull(dbo.MAESTRO.EQ_EXPMX,1) end, 
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		round(isnull(dbo.IMPEXCELFACTEXP.COSTO*dbo.IMPEXCELFACTEXP.CANTIDAD,0),6),
		round(isnull(dbo.IMPEXCELFACTEXP.CANTIDAD* dbo.IMPEXCELFACTEXP.PESO,0),6), 
		round(isnull(dbo.IMPEXCELFACTEXP.CANTIDAD* dbo.IMPEXCELFACTEXP.PESO * 2.20462442018378,0),6),
		round(isnull(dbo.IMPEXCELFACTEXP.CANTIDAD* dbo.IMPEXCELFACTEXP.PESO,0),6), 
		round(isnull(dbo.IMPEXCELFACTEXP.CANTIDAD* dbo.IMPEXCELFACTEXP.PESO * 2.20462442018378,0),6),
		round(isnull(dbo.IMPEXCELFACTEXP.PESO*2.20462442018378,0),6), 
		'CANTEMP'=CASE WHEN dbo.MAESTRO.MA_CANTEMP>0 THEN CEILING(dbo.IMPEXCELFACTEXP.CANTIDAD/dbo.MAESTRO.MA_CANTEMP) ELSE 0 END, 
		IsNull(dbo.MAESTRO.MA_EMPAQUE,0),dbo.IMPEXCELFACTEXP.CANTIDAD, 
		'tco_codigo'=case when @cfq_tipo='D' and (select count(ma_codigo) from maestrocost where ma_codigo=dbo.MAESTRO.ma_codigo and tco_codigo in (select tco_desperdicio from configuracion))>0 
				then (select tco_desperdicio from configuracion) else (case when @cfq_tipo='T' AND (select CF_TCOCOMPRAIMP from configuracion)='S' then (select tco_compra from configuracion) else isnull(dbo.VMAESTROCOST.TCO_CODIGO,0) end) end, 
		'MA_TIP_ENS'=CASE WHEN @cfq_tipo='T' THEN 'C'  ELSE (case when dbo.MAESTRO.MA_TIP_ENS='A' then 'F' else dbo.MAESTRO.MA_TIP_ENS end) END,
		'N', MAESTRO.MA_NOPARTEAUX
		FROM         dbo.IMPEXCELFACTEXP LEFT OUTER JOIN
		                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
		                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
				      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (NOT (dbo.IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') NOT IN
		                          (SELECT     MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
		                            FROM          MAESTRO
		                            WHERE      MA_INV_GEN = @TipoEntrada AND TI_CODIGO IN
		                                                       (SELECT     TI_CODIGO
		                                                         FROM          RELTEMBTIPO
		                                                         WHERE      TQ_CODIGO = @TipoEmbarque) AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) = NOPARTE+'-'+isnull(NOPARTEAUX,'')))) AND 
	
				dbo.IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
								FROM         MAESTRO
								where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
								  and MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) in (SELECT NOPARTE+'-'+isnull(noparteaux,'') FROM IMPEXCELFACTEXP)
								GROUP BY MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
								HAVING      (COUNT(MA_CODIGO) > 1))
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	             ORDER BY ORDEN
	END
	ELSE
	BEGIN
		INSERT INTO LISTAEXPDET (LED_INDICED,LE_CODIGO,LED_NOPARTE,LED_COS_UNI,
	                                                             LED_CANT,LED_PES_UNILB,LED_NOMBRE,LED_NAME,MA_CODIGO,TI_CODIGO,LED_POR_DEF,
	                                                             LED_SEC_IMP,PA_CODIGO,MA_GENERICO,AR_IMPMX, AR_IMPFO,
	 				        EQ_IMPFO,EQ_GEN,LED_DEF_TIP,LED_RATEIMPFO,ME_CODIGO,AR_EXPMX,EQ_EXPMX,
					        LED_GRA_MP, LED_GRA_MO, LED_GRA_EMP, LED_GRA_ADD, 
	 				LED_GRA_GI, LED_GRA_GI_MX, LED_NG_MP, LED_NG_EMP, LED_NG_ADD, 
					LED_NG_USA, LED_COS_TOT, LED_PES_NET, LED_PES_NETLB, LED_PES_BRU, LED_PES_BRULB, LED_PES_UNI,
					LED_CANTEMP, MA_EMPAQUE, LED_SALDO, TCO_CODIGO, LED_TIP_ENS, LED_NAFTA, LED_NOPARTEAUX)		
	          SELECT @consecutivo+ORDEN, @Codigo, dbo.IMPEXCELFACTEXP.NOPARTE, dbo.IMPEXCELFACTEXP.COSTO, 
                         dbo.IMPEXCELFACTEXP.CANTIDAD, isnull(dbo.IMPEXCELFACTEXP.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
			dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,0), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.PA_ORIGEN, isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)),
			 isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.PA_ORIGEN,0), 
			isnull(dbo.MAESTRO.MA_GENERICO,0), isnull(dbo.MAESTRO.AR_IMPMX,0),  
			'AR_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.AR_DESP,0) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.AR_IMPFO,0) else isnull(dbo.MAESTRO.AR_IMPFOUSA,0) end) else isnull(dbo.MAESTRO.AR_IMPFO,0) end) end,
  	                'EQ_IMPFO'=CASE when @cfq_tipo='D' then isnull(dbo.MAESTRO.EQ_DESP,1) else (CASE WHEN dbo.MAESTRO.TI_CODIGO<>14 AND dbo.MAESTRO.TI_CODIGO<>16 and isnull(dbo.MAESTRO.PA_ORIGEN,0)=(select cf_pais_usa from configuracion) then (case when isnull(dbo.MAESTRO.AR_IMPFOUSA,0)=0 then isnull(dbo.MAESTRO.EQ_IMPFO,1) else isnull(dbo.MAESTRO.EQ_IMPFOUSA,1) end) else isnull(dbo.MAESTRO.EQ_IMPFO,1) end) end, 
			isnull(dbo.MAESTRO.EQ_GEN,1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), -1, isnull(dbo.MAESTRO.ME_COM,19), 
			'AR_EXPMX'=CASE when @cfq_tipo='D' and @LE_DESTINO='N' then isnull(dbo.MAESTRO.AR_DESPMX,0) else  isnull(dbo.MAESTRO.AR_EXPMX,0) end, 'EQ_EXPMX'=CASE when @cfq_tipo='D' and @LE_DESTINO='N' then isnull(dbo.MAESTRO.EQ_DESPMX,1) else isnull(dbo.MAESTRO.EQ_EXPMX,1) end, 
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
		round(isnull(dbo.IMPEXCELFACTEXP.COSTO*dbo.IMPEXCELFACTEXP.CANTIDAD,0),6),
		round(isnull((dbo.IMPEXCELFACTEXP.CANTIDAD* dbo.IMPEXCELFACTEXP.PESO)/2.20462442018378,0),6), round(isnull(dbo.IMPEXCELFACTEXP.CANTIDAD* dbo.IMPEXCELFACTEXP.PESO,0),6),
			round(isnull((dbo.IMPEXCELFACTEXP.CANTIDAD* dbo.IMPEXCELFACTEXP.PESO)/2.20462442018378,0),6), round(isnull(dbo.IMPEXCELFACTEXP.CANTIDAD* dbo.IMPEXCELFACTEXP.PESO,0),6),
		round(isnull(dbo.IMPEXCELFACTEXP.PESO/2.20462442018378,0),6), 'CANTEMP'=CASE WHEN dbo.MAESTRO.MA_CANTEMP>0 THEN CEILING(dbo.IMPEXCELFACTEXP.CANTIDAD/dbo.MAESTRO.MA_CANTEMP) ELSE 0 END, IsNull(dbo.MAESTRO.MA_EMPAQUE,0),
		dbo.IMPEXCELFACTEXP.CANTIDAD, 'tco_codigo'=case when @cfq_tipo='D' and (select count(ma_codigo) from maestrocost where ma_codigo=dbo.MAESTRO.ma_codigo and tco_codigo in (select tco_desperdicio from configuracion))>0 
				then (select tco_desperdicio from configuracion) else (case when @cfq_tipo='T' AND (select CF_TCOCOMPRAIMP from configuracion)='S' then (select tco_compra from configuracion) else isnull(dbo.VMAESTROCOST.TCO_CODIGO,0) end) end, 
		'MA_TIP_ENS'=CASE WHEN @cfq_tipo='T' THEN 'C'  ELSE (case when dbo.MAESTRO.MA_TIP_ENS='A' then 'F' else dbo.MAESTRO.MA_TIP_ENS end) END,
		'N', MAESTRO.MA_NOPARTEAUX
		FROM         dbo.IMPEXCELFACTEXP LEFT OUTER JOIN
	                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
	                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
			      dbo.CONFIGURATIPO ON dbo.MAESTRO.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
		WHERE     (NOT (dbo.IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') NOT IN
		                          (SELECT     MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
		                            FROM          MAESTRO
		                            WHERE      MA_INV_GEN = @TipoEntrada AND TI_CODIGO IN
		                                                       (SELECT     TI_CODIGO
		                                                         FROM          RELTEMBTIPO
		                                                         WHERE      TQ_CODIGO = @TipoEmbarque) AND MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) = NOPARTE+'-'+isnull(NOPARTEAUX,'')))) AND 
	
				dbo.IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,'')))
								FROM         MAESTRO
								where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
								  and maestro.MA_NOPARTE+'-'+rtrim(ltrim(isnull(maestro.MA_NOPARTEAUX,''))) in (SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM IMPEXCELFACTEXP)
								GROUP BY MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,'')))
								HAVING      (COUNT(MA_CODIGO) > 1))
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	             ORDER BY ORDEN
	END

	

	UPDATE LISTAEXPDET
	SET LED_NAFTA=dbo.GetNafta (@LE_fecha, LISTAEXPDET.MA_CODIGO, LISTAEXPDET.AR_IMPMX, LISTAEXPDET.PA_CODIGO, LISTAEXPDET.LED_DEF_TIP, LISTAEXPDET.LED_TIP_ENS)
	FROM LISTAEXPDET 
	WHERE LE_CODIGO=@Codigo

	UPDATE LISTAEXPDET
	SET LED_RATEIMPFO=(CASE WHEN LED_NAFTA='S' THEN 0 ELSE dbo.GetAdvalorem(AR_IMPFO, 0, 'G', 0, 0) END)
	FROM LISTAEXPDET 
	WHERE LE_CODIGO=@Codigo


	UPDATE LISTAEXPDET
	SET LED_GRA_MP=isnull(dbo.MAESTROCOST.MA_GRAV_MP,0), 
	LED_GRA_MO=isnull(dbo.MAESTROCOST.MA_GRAV_MO,0), 
	LED_GRA_EMP=isnull(dbo.MAESTROCOST.MA_GRAV_EMP,0), 
	LED_GRA_ADD=isnull(dbo.MAESTROCOST.MA_GRAV_ADD,0), 
	LED_GRA_GI=isnull(dbo.MAESTROCOST.MA_GRAV_GI,0), 
	LED_GRA_GI_MX=isnull(dbo.MAESTROCOST.MA_GRAV_GI_MX,0), 
	LED_NG_MP=isnull(dbo.MAESTROCOST.MA_NG_MP,0), 
	LED_NG_EMP=isnull(dbo.MAESTROCOST.MA_NG_EMP,0), 
	LED_NG_ADD=isnull(dbo.MAESTROCOST.MA_NG_ADD,0), 
	LED_NG_USA=isnull(dbo.MAESTROCOST.MA_NG_USA,0)
	FROM LISTAEXPDET 
	LEFT OUTER JOIN dbo.MAESTROCOST ON LISTAEXPDET.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO 
	AND LISTAEXPDET.TCO_CODIGO = dbo.MAESTROCOST.TCO_CODIGO 
	LEFT OUTER JOIN dbo.CONFIGURATIPO ON LISTAEXPDET.TI_CODIGO = dbo.CONFIGURATIPO.TI_CODIGO
	WHERE LE_CODIGO=@Codigo
	AND dbo.MAESTROCOST.MAC_CODIGO IN (SELECT MAX(M1.MAC_CODIGO) 
						FROM MAESTROCOST M1 
						WHERE M1.SPI_CODIGO = 22 AND M1.MA_PERINI <= GETDATE() AND M1.MA_PERFIN >= GETDATE() 
							AND M1.TCO_CODIGO = LISTAEXPDET.TCO_CODIGO 
							AND M1.MA_CODIGO = LISTAEXPDET.MA_CODIGO)
	and LISTAEXPDET.tco_codigo in (select tco_manufactura from configuracion)



	UPDATE LISTAEXPDET
	set LED_COS_UNI=round(isnull(LED_GRA_MP+LED_GRA_MO+LED_GRA_EMP+ LED_GRA_ADD+
		LED_GRA_GI+ LED_GRA_GI_MX+ LED_NG_MP+ LED_NG_EMP+ LED_NG_ADD,0),6)
	FROM LISTAEXPDET
	WHERE  LE_CODIGO=@Codigo
	and LISTAEXPDET.tco_codigo in (select tco_manufactura from configuracion)


	UPDATE LISTAEXPDET
	SET LED_COS_TOT=round(isnull(LED_COS_UNI*LED_CANT,0),6)
	WHERE  LE_CODIGO=@Codigo and LED_COS_TOT<>round(isnull(LED_COS_UNI*LED_CANT,0),6)




	  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) <> 'N'  
	  begin
		  if (SELECT CF_USACARGOCOSTO FROM CONFIGURACION) = 'S' 
		  begin
			INSERT INTO LISTAEXPDETCARGO(CAR_CODIGO, FEG_VALOR, FEG_TIPO, LE_CODIGO, LED_INDICED)
			SELECT     dbo.CARGORELARANCEL.CAR_CODIGO, dbo.CARGODET.CARD_VALOR, dbo.CARGO.CAR_TIPO,  dbo.LISTAEXPDET.LE_CODIGO, 
			                      dbo.LISTAEXPDET.LED_INDICED
			FROM         dbo.LISTAEXPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.LISTAEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO INNER JOIN
			                      dbo.LISTAEXP ON dbo.LISTAEXPDET.LE_CODIGO = dbo.LISTAEXP.LE_CODIGO INNER JOIN
			                      dbo.CARGORELARANCEL INNER JOIN
			                      dbo.CARGODET ON dbo.CARGORELARANCEL.CAR_CODIGO = dbo.CARGODET.CAR_CODIGO INNER JOIN
			                      dbo.CARGO ON dbo.CARGORELARANCEL.CAR_CODIGO = dbo.CARGO.CAR_CODIGO ON 
			                      dbo.LISTAEXP.LE_FECHA >= dbo.CARGODET.CARD_FECHAINI AND dbo.LISTAEXP.LE_FECHA <= dbo.CARGODET.CARD_FECHAFIN AND 
			                      dbo.LISTAEXP.CL_CODIGO = dbo.CARGORELARANCEL.CL_CODIGO AND dbo.MAESTRO.AR_EXPMX = dbo.CARGORELARANCEL.AR_CODIGO
			WHERE dbo.LISTAEXPDET.LE_CODIGO=@codigo
		  end
		  else
		  begin
			INSERT INTO LISTAEXPDETCARGO(CAR_CODIGO, FEG_VALOR, FEG_TIPO, LE_CODIGO, LED_INDICED)
			SELECT     dbo.CARGORELARANCEL.CAR_CODIGO, dbo.CARGODET.CARD_VALOR, dbo.CARGO.CAR_TIPO,  dbo.LISTAEXPDET.LE_CODIGO, 
			                      dbo.LISTAEXPDET.LED_INDICED
			FROM         dbo.LISTAEXPDET INNER JOIN
			                      dbo.MAESTRO ON dbo.LISTAEXPDET.MA_CODIGO = dbo.MAESTRO.MA_CODIGO INNER JOIN
			                      dbo.LISTAEXP ON dbo.LISTAEXPDET.LE_CODIGO = dbo.LISTAEXP.LE_CODIGO INNER JOIN
			                      dbo.CARGORELARANCEL INNER JOIN
			                      dbo.CARGODET ON dbo.CARGORELARANCEL.CAR_CODIGO = dbo.CARGODET.CAR_CODIGO INNER JOIN
			                      dbo.CARGO ON dbo.CARGORELARANCEL.CAR_CODIGO = dbo.CARGO.CAR_CODIGO ON 
			                      dbo.LISTAEXP.LE_FECHA >= dbo.CARGODET.CARD_FECHAINI AND dbo.LISTAEXP.LE_FECHA <= dbo.CARGODET.CARD_FECHAFIN AND 
			                      dbo.LISTAEXP.CL_CODIGO = dbo.CARGORELARANCEL.CL_CODIGO AND dbo.MAESTRO.LIN_CODIGO = dbo.CARGORELARANCEL.LIN_CODIGO
			WHERE dbo.LISTAEXPDET.LE_CODIGO=@codigo
		  end
	end	


	update listaexpdet
	set ar_orig= case when led_nafta='S' then
		 0 else ( case when isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=listaexpdet.ma_codigo),0)=0 
		then  isnull((select AR_IMPFOUSA from maestro where maestro.ma_codigo=listaexpdet.ma_codigo),0)  else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='N' and bom_arancel.ma_codigo=listaexpdet.ma_codigo),0) end) end
	where (ar_orig is null or ar_orig =0) and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and led_tip_ens<>'C'
	and led_ng_usa>0 and le_codigo=@Codigo
	

	update listaexpdet
	set ar_ng_emp= case when led_nafta='S' then
	 0 else isnull((select max(ar_codigo) from bom_arancel where ba_tipocosto='3' and bom_arancel.ma_codigo=listaexpdet.ma_codigo),0) end
	where (ar_ng_emp is null or ar_ng_emp =0) and ti_codigo in (select ti_codigo from configuratipo where cft_tipo='P' or cft_tipo='S') and led_tip_ens<>'C'
	and led_ng_emp>0 and le_codigo=@Codigo


	IF @cfq_tipo is null
	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     ' La importacion no se hizo correctamente debido a la configuracion del tipo de embarque', 26


	if @cfq_tipo='N'  and @ConCosto=1 and exists (SELECT     dbo.MAESTRO.MA_NOPARTE  
			  	    FROM         dbo.IMPEXCELFACTEXP INNER JOIN
			                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE+'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(isnull(MAESTRO.MA_NOPARTEAUX,''))) 
				WHERE dbo.MAESTRO.TI_CODIGO IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO IN ('P', 'S')))
	INSERT INTO IMPORTLOG (IML_MENSAJE) 
	SELECT     ' Nota: En el archivo de excel se estan importando productos terminados, de los cuales no se tomaran los costos desde el archivo, esto debido a la division de costos'	

	select @LED_indiced= max(LED_indiced) from LISTAEXPDET

	update consecutivo
	set cv_codigo =  isnull(@LED_indiced,0) + 1
	where cv_tipo = 'LED'




	TRUNCATE TABLE IMPEXCELFACTEXP



GO
