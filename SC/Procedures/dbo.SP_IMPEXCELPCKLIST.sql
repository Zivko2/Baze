SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_IMPEXCELPCKLIST] @Codigo int,@TipoEntrada char,@TipoEmbarque int   as

SET NOCOUNT ON 
DECLARE @CONSECUTIVO INTEGER, @NOPARTE varchar(30), @COSTO decimal(38,6), @CANTIDAD decimal(38,6), @PESO decimal(38,6), @ORIGEN INT, 
@PLD_indiced int, @CF_PESOS_IMP CHAR(1)



	SELECT     @CF_PESOS_IMP = CF_PESOS_IMP
	FROM         dbo.CONFIGURACION


DELETE FROM IMPEXCELFACTIMP WHERE NOPARTE='-1'


-- se actualiza el costo en caso de que venga nulo o igual a cero pero solo de los comprados-fisicos
UPDATE dbo.IMPEXCELFACTIMP
SET     dbo.IMPEXCELFACTIMP.COSTO= ISNULL(dbo.MAESTROCOST.MA_COSTO, 0)
FROM         dbo.IMPEXCELFACTIMP INNER JOIN
                      dbo.MAESTRO ON dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
                      dbo.MAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.MAESTROCOST.MA_CODIGO
WHERE dbo.MAESTROCOST.SPI_CODIGO=22 AND dbo.MAESTROCOST.MA_PERINI<=getdate() AND dbo.MAESTROCOST.MA_PERFIN>=getdate()
AND dbo.MAESTROCOST.TCO_CODIGO IN (select TCO_COMPRA from configuracion) AND
(dbo.IMPEXCELFACTIMP.COSTO=0 OR dbo.IMPEXCELFACTIMP.COSTO IS NULL)
AND dbo.MAESTRO.MA_TIP_ENS='A'
/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


-- se actualiza el costo en caso de que venga nulo o igual a cero
UPDATE dbo.IMPEXCELFACTIMP
SET     dbo.IMPEXCELFACTIMP.COSTO= ISNULL(dbo.VMAESTROCOST.MA_COSTO, 0)
FROM         dbo.IMPEXCELFACTIMP INNER JOIN
                      dbo.MAESTRO ON dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
WHERE dbo.IMPEXCELFACTIMP.COSTO=0 OR dbo.IMPEXCELFACTIMP.COSTO IS NULL
/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


-- se actualiza el peso en caso de que venga nulo o igual a cero
IF @CF_PESOS_IMP='K'
BEGIN
	UPDATE dbo.IMPEXCELFACTIMP
	SET  dbo.IMPEXCELFACTIMP.PESO = isnull(dbo.MAESTRO.MA_PESO_KG,0)
	FROM         dbo.MAESTRO INNER JOIN
	                      dbo.IMPEXCELFACTIMP ON dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,'')))
	WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
	               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
	                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) =IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
END
ELSE
BEGIN
	UPDATE dbo.IMPEXCELFACTIMP
	SET  dbo.IMPEXCELFACTIMP.PESO = isnull(dbo.MAESTRO.MA_PESO_LB,0)
	FROM         dbo.MAESTRO INNER JOIN
	                      dbo.IMPEXCELFACTIMP ON dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,'')))
	WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
	               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
	                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,'')))=IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
END

--borra los errores generados en otras importaciones
DELETE FROM IMPORTLOG WHERE IML_CBFORMA=33

if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS

--borra los registros de la tabla que se hayan importado sin numero de parte
delete from IMPEXCELFACTIMP where NOPARTE=''

-- revisa si existen en el catalogo maestro
if exists(SELECT dbo.IMPEXCELFACTIMP.NOPARTE
	FROM         dbo.MAESTRO RIGHT OUTER JOIN
                              dbo.IMPEXCELFACTIMP ON dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,'')))
                              /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	WHERE     (dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) IS NULL))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTIMP.NOPARTE+' CON EL AUX.: '+ISNULL(MA_NOPARTEAUX,'') +' POR QUE NO EXISTE EN EL CAT. MAESTRO', 33
	FROM         dbo.MAESTRO RIGHT OUTER JOIN
	                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
                                 /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	WHERE     (dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) IS NULL) 
	

	-- revisa si existen obsoletos en el catalogo maestro
	if exists(SELECT dbo.IMPEXCELFACTIMP.NOPARTE
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
                                             /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A'))
	BEGIN
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTIMP.NOPARTE+' CON EL AUX.: '+ISNULL(MA_NOPARTEAUX,'') +' POR QUE ESTA OBSOLETO EN EL CAT. MAESTRO', 33
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
                                           /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') 
		

		DELETE dbo.IMPEXCELFACTIMP
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
                                         /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') 
		
	END

-- revisa si los tipos de material existen en la relacion tipo embarque - tipo material
	if exists (SELECT     dbo.IMPEXCELFACTIMP.NOPARTE
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
                                              /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		WHERE     (NOT (dbo.MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo
                            FROM          reltembtipo
                           WHERE      tq_codigo = @TipoEmbarque))))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTIMP.NOPARTE+' CON EL AUX.: '+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') +' POR LA RELACION TIPO EMBARQUE-TIPO MATERIAL', 33
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
                                              /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		WHERE     (NOT (dbo.MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo FROM reltembtipo WHERE tq_codigo = @TipoEmbarque))) and
	'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTIMP.NOPARTE+' CON EL AUX.: '+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') +' POR LA RELACION TIPO EMBARQUE-TIPO MATERIAL' 
	not in (SELECT IML_MENSAJE FROM IMPORTLOG WHERE IML_MENSAJE IS NOT NULL)
	


	if exists(SELECT     dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,'')))
	FROM         dbo.MAESTRO
	where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
          and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)
	GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,'')))
	HAVING      (COUNT(MA_CODIGO) > 1))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MA_NOPARTE+' CON EL AUX.: '+ISNULL(MA_NOPARTEAUX,'')  + ' PORQUE ESTA REPETIDO EN EL CAT. MAESTRO', 33
	FROM         dbo.MAESTRO	
	where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
          and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)
	GROUP BY MA_NOPARTE,MA_NOPARTEAUX
	HAVING      (COUNT(MA_CODIGO) > 1)



	IF (SELECT CF_SELPAISIMP FROM CONFIGURACION)='S'
	begin
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR EL NO. PARTE : ' + MA_NOPARTE+' CON EL AUX.: '+ISNULL(MA_NOPARTEAUX,'') + ' PORQUE TIENE ASIGNADO MAS DE UN PAIS DE ORIGEN', 33
		FROM         dbo.MAESTRO
		WHERE MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP) AND  dbo.MAESTRO.MA_CODIGO IN
			(SELECT     MA_CODIGO FROM VMAESTROPROVEEGROUP GROUP BY MA_CODIGO HAVING (COUNT(*) > 1))
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		GROUP BY MA_NOPARTE,MA_NOPARTEAUX


		DELETE FROM IMPEXCELFACTIMP WHERE NOPARTE+'-'+ISNULL(NOPARTEAUX,'') IN
		(SELECT     MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,'')))
		FROM         dbo.MAESTRO
		WHERE MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP) AND  dbo.MAESTRO.MA_CODIGO IN
			(SELECT     MA_CODIGO FROM VMAESTROPROVEEGROUP GROUP BY MA_CODIGO HAVING (COUNT(*) > 1))
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))))
	
	end
	
	--Verifica si el no. parte esta marcado como material peligroso
	if exists(SELECT    maestro.ma_noparte 
		FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 	
		where maestro.ma_inv_gen = @TipoEntrada and maestroprohibido.mp_prohibido = 'S'
          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)) and (select CF_VALIDAMATERIALPELIGROSO from Configuracion) ='S'
		BEGIN
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MA_NOPARTE+' CON EL AUX.: '+ISNULL(MA_NOPARTEAUX,'')  + ' PORQUE ESTA MARCADO COMO MATERIAL PROHIBIDO EN EL CAT. MAESTRO', 33
				FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 		
				where maestro.ma_inv_gen = @TipoEntrada and maestro.ma_peligroso = 'S'
		          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)

			DELETE FROM IMPEXCELFACTIMP WHERE NOPARTE+'-'+ISNULL(NOPARTEAUX,'') IN
			(SELECT     MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,'')))
				FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 
				where maestro.ma_inv_gen = @TipoEntrada and maestroprohibido.mp_prohibido = 'S'
		          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP))


		END


	select @consecutivo=cv_codigo from consecutivo
	where cv_tipo = 'PLD'

ALTER TABLE [PCKLISTDET] DISABLE trigger [Update_PcklistDet]

-- insercion a la tabla PCKLISTdet
IF @CF_PESOS_IMP='K'
BEGIN
		INSERT INTO PCKLISTDET (PLD_INDICED,PL_CODIGO,PLD_NOPARTE,PLD_COS_UNI,PLD_CANT_ST, PLD_PES_UNI,PLD_NOMBRE,PLD_NAME,MA_CODIGO,
	                                                             TI_CODIGO,PLD_POR_DEF,PLD_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
	 				       AR_EXPFO,PLD_PES_UNILB,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,PLD_DEF_TIP, ME_CODIGO, ME_GEN, 
					       	PLD_COS_TOT, PLD_PES_NET, PLD_PES_NETLB, PLD_PES_BRU, PLD_PES_BRULB, PLD_SALDO, TCO_CODIGO, PLD_NOPARTEAUX) 
	
	
		SELECT     TOP 100 PERCENT dbo.IMPEXCELFACTIMP.ORDEN+@consecutivo, @Codigo, dbo.IMPEXCELFACTIMP.NOPARTE, isnull(dbo.IMPEXCELFACTIMP.COSTO,0), 
		                      dbo.IMPEXCELFACTIMP.CANTIDAD, isnull(dbo.IMPEXCELFACTIMP.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
		                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
		                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_GENERICO,0), 
		                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.IMPEXCELFACTIMP.PESO,0) * 2.20462442018378, 
		                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
		                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),dbo.MAESTRO.ME_COM),
		                      isnull(dbo.IMPEXCELFACTIMP.CANTIDAD * dbo.IMPEXCELFACTIMP.COSTO,0), 
		                      dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0), dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0) * 2.20462442018378, 
		                      dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0), dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0) * 2.20462442018378,
			         isnull(dbo.IMPEXCELFACTIMP.CANTIDAD,0), isnull(VMAESTROCOST.TCO_CODIGO,0), MAESTRO.MA_NOPARTEAUX
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') LEFT OUTER JOIN
		                      dbo.PAIS ON dbo.IMPEXCELFACTIMP.ORIGEN = dbo.PAIS.PA_CORTO  LEFT OUTER JOIN
				VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
		                      dbo.PAIS PAISISO ON dbo.IMPEXCELFACTIMP.ORIGEN = PAISISO.PA_ISO
		WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     TI_CODIGO
		                            FROM          RELTEMBTIPO
		                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
				dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,'')))
							FROM         MAESTRO
							where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
                                                          and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP) 
							GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,'')))
							HAVING      (COUNT(MA_CODIGO) > 1)) 
		ORDER BY dbo.IMPEXCELFACTIMP.ORDEN
END
ELSE
BEGIN
		INSERT INTO PCKLISTDET (PLD_INDICED,PL_CODIGO,PLD_NOPARTE,PLD_COS_UNI,PLD_CANT_ST, PLD_PES_UNILB,PLD_NOMBRE,PLD_NAME,MA_CODIGO,
	                                                             TI_CODIGO,PLD_POR_DEF,PLD_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
	 				       AR_EXPFO,PLD_PES_UNI,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,PLD_DEF_TIP, ME_CODIGO, ME_GEN, 
					       	PLD_COS_TOT, PLD_PES_NET, PLD_PES_NETLB, PLD_PES_BRU, PLD_PES_BRULB, PLD_SALDO, TCO_CODIGO, PLD_NOPARTEAUX) 
	
	
		SELECT     TOP 100 PERCENT dbo.IMPEXCELFACTIMP.ORDEN+@consecutivo, @Codigo, dbo.IMPEXCELFACTIMP.NOPARTE, dbo.IMPEXCELFACTIMP.COSTO, 
		                      dbo.IMPEXCELFACTIMP.CANTIDAD, isnull(dbo.IMPEXCELFACTIMP.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
		                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), isnull(dbo.MAESTRO.MA_SEC_IMP,0), 		                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_GENERICO,0), 
		                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.IMPEXCELFACTIMP.PESO,0) / 2.20462442018378, 
		                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1),  isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
		                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),dbo.MAESTRO.ME_COM),
		                      dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.COSTO,0), 
		                      (dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0))/2.20462442018378, dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0), 
		                      (dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0))/2.20462442018378, dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0),
				dbo.IMPEXCELFACTIMP.CANTIDAD, isnull(VMAESTROCOST.TCO_CODIGO,0), MAESTRO.MA_NOPARTEAUX
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') LEFT OUTER JOIN
		                      dbo.PAIS ON dbo.IMPEXCELFACTIMP.ORIGEN = dbo.PAIS.PA_CORTO  LEFT OUTER JOIN
				VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
		                      dbo.PAIS PAISISO ON dbo.IMPEXCELFACTIMP.ORIGEN = PAISISO.PA_ISO
		WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     TI_CODIGO
		                            FROM          RELTEMBTIPO
		                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
	
				dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MAESTRO.MA_NOPARTEAUX,'')))
							FROM         dbo.MAESTRO
							where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
                                                          and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP) 
							GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,'')))
							HAVING      (COUNT(MA_CODIGO) > 1))
		ORDER BY dbo.IMPEXCELFACTIMP.ORDEN

END



	-- cambia el tipo de tasa en base a la configuracion
	if (select CF_ACTTASA from configuracion)='S'
	exec SP_ACTUALIZATASABAJAPCKLIST  @codigo


	if (select cf_selpaisimp from configuracion)='S'
	EXEC SP_ACTUALIZAIMPEXCELPROVEE @CODIGO, 'P'

	EXEC sp_actualizaReferencia @Codigo

ALTER TABLE [PCKLISTDET] ENABLE trigger [Update_PcklistDet]

select @PLD_indiced= max(PLD_indiced) from PCKLISTDET

	update consecutivo
	set cv_codigo =  isnull(@PLD_indiced,0) + 1
	where cv_tipo = 'PLD'


	TRUNCATE TABLE IMPEXCELFACTIMP
GO
