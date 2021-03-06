SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_IMPEXCELFACTIMP] @Codigo int   as

SET NOCOUNT ON 
DECLARE @CONSECUTIVO INTEGER, @NOPARTE varchar(30), @COSTO decimal(38,6), @CANTIDAD decimal(38,6), @PESO decimal(38,6), @ORIGEN INT, @TipoEmbarque INT, 
@TipoEntrada CHAR(1), @FID_indiced int, @CF_PESOS_IMP CHAR(1)



	SELECT     @CF_PESOS_IMP = CF_PESOS_IMP
	FROM         dbo.CONFIGURACION

SET @TipoEntrada ='I'
SELECT @TipoEmbarque =TQ_CODIGO FROM FACTIMP WHERE FI_CODIGO=@Codigo


DELETE FROM IMPEXCELFACTIMP WHERE NOPARTE='-1'

	ALTER TABLE FACTIMPDET DISABLE TRIGGER Update_FactImpDet



-- se actualiza el costo en caso de que venga nulo o igual a cero pero solo de los comprados-fisicos
UPDATE dbo.IMPEXCELFACTIMP
SET     dbo.IMPEXCELFACTIMP.COSTO= ISNULL(dbo.MAESTROCOST.MA_COSTO, 0)
FROM         dbo.IMPEXCELFACTIMP INNER JOIN
                      dbo.MAESTRO ON dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
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
                      dbo.MAESTRO ON dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) LEFT OUTER JOIN
                      dbo.VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO = dbo.VMAESTROCOST.MA_CODIGO
WHERE dbo.VMAESTROCOST.SPI_CODIGO=22 AND
(dbo.IMPEXCELFACTIMP.COSTO=0 OR dbo.IMPEXCELFACTIMP.COSTO IS NULL)
/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


UPDATE dbo.IMPEXCELFACTIMP
SET     dbo.IMPEXCELFACTIMP.COSTO= 0
WHERE dbo.IMPEXCELFACTIMP.COSTO IS NULL


-- se actualiza el peso en caso de que venga nulo o igual a cero
IF @CF_PESOS_IMP='K'
BEGIN
UPDATE dbo.IMPEXCELFACTIMP
SET  dbo.IMPEXCELFACTIMP.PESO = isnull(dbo.MAESTRO.MA_PESO_KG,0)
FROM         dbo.MAESTRO INNER JOIN
                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))=IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
END
ELSE
BEGIN
UPDATE dbo.IMPEXCELFACTIMP
SET  dbo.IMPEXCELFACTIMP.PESO = isnull(dbo.MAESTRO.MA_PESO_LB,0)
FROM         dbo.MAESTRO INNER JOIN
                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
WHERE dbo.MAESTRO.MA_INV_GEN=@TipoEntrada AND
               TI_CODIGO IN  ( SELECT  TI_CODIGO  FROM  RELTEMBTIPO  WHERE  TQ_CODIGO =@TipoEmbarque  ) 
                AND MA_EST_MAT = 'A' AND MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))=IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') AND (PESO IS NULL OR PESO =0.0)
END


--borra los errores generados en otras importaciones

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=21

if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS

--borra los registros de la tabla que se hayan importado sin numero de parte
delete from IMPEXCELFACTIMP where NOPARTE=''

-- revisa si existen en el catalogo maestro
if exists(SELECT dbo.IMPEXCELFACTIMP.NOPARTE
	FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
			where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
	                      dbo.IMPEXCELFACTIMP ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
	WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) IS NULL)

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTIMP.NOPARTE +' CON EL AUX.: '+isnull(IMPEXCELFACTIMP.NOPARTEAUX,'')+' POR QUE NO EXISTE EN EL CAT. MAESTRO', 21
	FROM         (select MA_NOPARTE, MA_NOPARTEAUX from dbo.MAESTRO 
			where maestro.ma_inv_gen = 'I') MAESTROB RIGHT OUTER JOIN
	                      dbo.IMPEXCELFACTIMP ON MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
	WHERE     MAESTROB.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTROB.MA_NOPARTEAUX,''))) IS NULL


-- revisa si existen obsoletos en el catalogo maestro
	if exists(SELECT dbo.IMPEXCELFACTIMP.NOPARTE
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
		WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada)
	begin
	
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTIMP.NOPARTE+' CON EL AUX.: '+isnull(IMPEXCELFACTIMP.NOPARTEAUX,'') +' POR QUE ESTA OBSOLETO EN EL CAT. MAESTRO', 21
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
		WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') 
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada



		DELETE dbo.IMPEXCELFACTIMP
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
		WHERE     (dbo.MAESTRO.MA_EST_MAT <>'A') 
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada

	end



-- revisa si los tipos de material existen en la relacion tipo embarque - tipo material
	if exists (SELECT     dbo.IMPEXCELFACTIMP.NOPARTE
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
		WHERE     (NOT (dbo.MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo
                            FROM          reltembtipo
                           WHERE      tq_codigo = @TipoEmbarque)))/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada)

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTIMP.NOPARTE+' CON EL AUX.: '+isnull(MA_NOPARTEAUX,'')+' POR LA RELACION TIPO EMBARQUE-TIPO MATERIAL' , 21
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
		WHERE     (NOT (dbo.MAESTRO.TI_CODIGO IN
                          (SELECT     ti_codigo FROM reltembtipo WHERE tq_codigo = @TipoEmbarque))) and
	'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTIMP.NOPARTE +' POR LA RELACION TIPO EMBARQUE-TIPO MATERIAL' 
	not in (SELECT IML_MENSAJE FROM IMPORTLOG WHERE IML_MENSAJE IS NOT NULL)
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada


	if exists(SELECT     dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,'')))
	FROM         dbo.MAESTRO
	where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
          and MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)
	GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))
	HAVING      (COUNT(MA_CODIGO) > 1))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MA_NOPARTE +' CON EL AUX.: '+isnull(MA_NOPARTEAUX,'')+ ' PORQUE ESTA REPETIDO EN EL CAT. MAESTRO' , 21
	FROM         dbo.MAESTRO
	WHERE  (MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+isnull(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada)
	GROUP BY MA_NOPARTE, ma_noparteaux
	HAVING      (COUNT(MA_CODIGO) > 1)


	if exists(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP GROUP BY NOPARTE+'-'+ISNULL(NOPARTEAUX,'') HAVING COUNT(*)>1)

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     ' IMPORTO AGRUPADO EL NO. PARTE : ' + MA_NOPARTE+' CON EL AUX.: '+isnull(MA_NOPARTEAUX,'') + ' YA QUE SE ENCUENTRA DUPLICADO EN EL ARCHIVO', 21
	FROM         dbo.MAESTRO
	WHERE  MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))) IN
	                          (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP GROUP BY NOPARTE+'-'+ISNULL(NOPARTEAUX,'') HAVING COUNT(*)>1)
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada




	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR EL ARCHIVO PORQUE EL NO. PARTE : ' + MA_NOPARTE+' CON EL AUX.: '+isnull(MA_NOPARTEAUX,'') + ' TIENE DUPLICIDAD EN EL COSTO', 21
	FROM         dbo.MAESTRO
	WHERE dbo.MAESTRO.MA_CODIGO IN (SELECT MA_CODIGO FROM VMAESTROCOST GROUP BY MA_CODIGO HAVING COUNT(*)>1)
	AND MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))) IN
	                          (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	GROUP BY MA_NOPARTE,MA_NOPARTEAUX


	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR EL ARCHIVO PORQUE EL NO. PARTE : ' + NOPARTE+' CON EL AUX.: '+isnull(NOPARTEAUX,'') + ' VIENE CON LA CANTIDAD NULA', 21
	FROM         dbo.IMPEXCELFACTIMP
	WHERE CANTIDAD IS NULL OR CANTIDAD=0


	if (select cf_permisoaviso from configuracion)='S'
	begin
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'EL NO. PARTE: '+dbo.MAESTRO.MA_NOPARTE+' CON EL AUX.: '+isnull(MAESTRO.MA_NOPARTEAUX,'')+' CON FRACCION '+ARANCEL.AR_FRACCION+' NO CUENTA CON PERMISO DE IMPORTACION', 21
		FROM         dbo.MAESTRO INNER JOIN
		             dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') LEFT OUTER JOIN ARANCEL ON
			dbo.MAESTRO.AR_IMPMX=ARANCEL.AR_CODIGO
		WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND (dbo.MAESTRO.MA_CODIGO NOT IN
			(SELECT     dbo.MAESTROCATEG.MA_CODIGO
			FROM         dbo.MAESTROCATEG INNER JOIN
			                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
			                      dbo.IDENTIFICA INNER JOIN
			                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
			WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
		MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
		GROUP BY dbo.MAESTRO.MA_NOPARTE,MAESTRO.MA_NOPARTEAUX, ARANCEL.AR_FRACCION
	end
	else
	if (select cf_permisoaviso from configuracion)='X'
	begin
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + dbo.MAESTRO.MA_NOPARTE+' CON EL AUX.: '+isnull(MAESTRO.MA_NOPARTEAUX,'')+' CON FRACCION '+ARANCEL.AR_FRACCION+' PORQUE NO CUENTA CON PERMISO SICEX', 21
		FROM         dbo.MAESTRO INNER JOIN
		             dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')  LEFT OUTER JOIN ARANCEL ON
			dbo.MAESTRO.AR_IMPMX=ARANCEL.AR_CODIGO
		WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND (dbo.MAESTRO.MA_CODIGO NOT IN
			(SELECT     dbo.MAESTROCATEG.MA_CODIGO
			FROM         dbo.MAESTROCATEG INNER JOIN
			                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
			                      dbo.IDENTIFICA INNER JOIN
			                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
			WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
		MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
		GROUP BY dbo.MAESTRO.MA_NOPARTE, MAESTRO.MA_NOPARTEAUX, ARANCEL.AR_FRACCION


		DELETE FROM dbo.IMPEXCELFACTIMP
		WHERE dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') IN (SELECT dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,'')))
		FROM         dbo.MAESTRO INNER JOIN
		             dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'')
		WHERE     dbo.MAESTRO.MA_INV_GEN = 'I' AND (dbo.MAESTRO.MA_CODIGO NOT IN
			(SELECT     dbo.MAESTROCATEG.MA_CODIGO
			FROM         dbo.MAESTROCATEG INNER JOIN
			                      dbo.PERMISODET ON dbo.MAESTROCATEG.CPE_CODIGO = dbo.PERMISODET.MA_GENERICO LEFT OUTER JOIN
			                      dbo.IDENTIFICA INNER JOIN
			                      dbo.PERMISO ON dbo.IDENTIFICA.IDE_CODIGO = dbo.PERMISO.IDE_CODIGO ON dbo.PERMISODET.PE_CODIGO = dbo.PERMISO.PE_CODIGO
			WHERE     (dbo.PERMISO.PE_APROBADO = 'S') AND (dbo.IDENTIFICA.IDE_CLAVE IN ('MQ', 'PX'))) OR
			MAESTRO.MA_CODIGO NOT IN (SELECT MA_CODIGO FROM MAESTROCATEG WHERE MA_CODIGO=MAESTRO.MA_CODIGO))
		GROUP BY dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))))

	end

	IF (SELECT CF_SELPAISIMP FROM CONFIGURACION)='S'
	begin
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR EL NO. PARTE : ' + MA_NOPARTE+' CON EL AUX.: '+isnull(MA_NOPARTEAUX,'') + ' PORQUE TIENE ASIGNADO MAS DE UN PAIS DE ORIGEN', 21
		FROM         dbo.MAESTRO
		WHERE MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') FROM IMPEXCELFACTIMP) AND  dbo.MAESTRO.MA_CODIGO IN
			(SELECT     MA_CODIGO FROM VMAESTROPROVEEGROUP GROUP BY MA_CODIGO HAVING (COUNT(*) > 1))
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		GROUP BY MA_NOPARTE, MA_NOPARTEAUX


		DELETE FROM IMPEXCELFACTIMP WHERE NOPARTE+'-'+isnull(NOPARTEAUX,'') IN
		(SELECT     MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))
		FROM         dbo.MAESTRO
		WHERE MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') FROM IMPEXCELFACTIMP) AND  dbo.MAESTRO.MA_CODIGO IN
			(SELECT     MA_CODIGO FROM VMAESTROPROVEEGROUP GROUP BY MA_CODIGO HAVING (COUNT(*) > 1))
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))))
	
	end

	--Verifica si el no. parte esta marcado como material peligroso
	if exists(SELECT    maestro.ma_noparte 
		FROM         dbo.MAESTRO left outer join MAESTROPROHIBIDO on maestro.ma_codigo = maestroprohibido.ma_codigo and getdate() between maestroprohibido.mp_fechainicial and maestroprohibido.mp_fechafinal 	
		where maestro.ma_inv_gen = @TipoEntrada and maestroprohibido.mp_prohibido = 'S'
          	and MA_NOPARTE+'-'+LTRIM(RTRIM(ISNULL(MA_NOPARTEAUX,''))) IN(SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)) and (select CF_VALIDAMATERIALPELIGROSO from Configuracion) ='S'
		BEGIN
			INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
			SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' + MA_NOPARTE+' CON EL AUX.: '+ISNULL(MA_NOPARTEAUX,'')  + ' PORQUE ESTA MARCADO COMO MATERIAL PROHIBIDO EN EL CAT. MAESTRO', 21
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
	where cv_tipo = 'FID'

-- insercion a la tabla factimpdet
IF @CF_PESOS_IMP='K'
BEGIN
		INSERT INTO FACTIMPDET (FID_INDICED,FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNI,FID_NOMBRE,FID_NAME,MA_CODIGO,
	                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
	 				       AR_EXPFO,FID_PES_UNILB,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
					       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_NOPARTEAUX) 
	
		SELECT     TOP 100 PERCENT dbo.IMPEXCELFACTIMP.ORDEN+@consecutivo, @Codigo, max(dbo.IMPEXCELFACTIMP.NOPARTE), isnull(max(dbo.IMPEXCELFACTIMP.COSTO),0), 
		                      SUM(dbo.IMPEXCELFACTIMP.CANTIDAD), isnull(max(dbo.IMPEXCELFACTIMP.PESO),0), max(dbo.MAESTRO.MA_NOMBRE), max(dbo.MAESTRO.MA_NAME), 
		                      dbo.MAESTRO.MA_CODIGO, isnull(max(dbo.MAESTRO.TI_CODIGO),10), dbo.GetAdvalorem(max(dbo.MAESTRO.AR_IMPMX), ISNULL(isnull(max(PAISISO.PA_CODIGO), max(dbo.PAIS.PA_CODIGO)), max(dbo.MAESTRO.PA_ORIGEN)), isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), isnull(max(dbo.MAESTRO.SPI_CODIGO),0)),
					isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), 
		                      ISNULL(max(dbo.MAESTRO.SPI_CODIGO), 0), ISNULL(isnull(max(PAISISO.PA_CODIGO), max(dbo.PAIS.PA_CODIGO)), max(dbo.MAESTRO.PA_ORIGEN)), max(isnull(dbo.MAESTRO.MA_GENERICO,0)), 
		                      ISNULL(max(dbo.MAESTRO.AR_IMPMX), 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(max(dbo.IMPEXCELFACTIMP.PESO),0) * 2.20462442018378, 
		                      ISNULL(max(dbo.MAESTRO.EQ_IMPMX), 1), ISNULL(max(dbo.MAESTRO.EQ_EXPFO), 1), ISNULL(max(dbo.MAESTRO.EQ_EXPFO2), 1), ISNULL(max(dbo.MAESTRO.EQ_GEN), 1), isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), 
		                      isnull(max(dbo.MAESTRO.ME_COM),19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO), max(dbo.MAESTRO.ME_COM)),
		                      (SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo), round(isnull(sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * max(dbo.IMPEXCELFACTIMP.COSTO),0),6), 
		                      round(sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * isnull(max(dbo.IMPEXCELFACTIMP.PESO),0),6), round(sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * isnull(max(dbo.IMPEXCELFACTIMP.PESO),0) * 2.20462442018378,6), 
		                      round(sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * isnull(max(dbo.IMPEXCELFACTIMP.PESO),0),6), round(sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * isnull(max(dbo.IMPEXCELFACTIMP.PESO),0) * 2.20462442018378,6),
			         isnull(sum(dbo.IMPEXCELFACTIMP.CANTIDAD),0), 'TCO_CODIGO'=case when max(dbo.MAESTRO.MA_TIP_ENS)='A' THEN  (select TCO_COMPRA from configuracion) ELSE isnull(max(VMAESTROCOST.TCO_CODIGO),0) END, MAESTRO.MA_NOPARTEAUX
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') LEFT OUTER JOIN
		                      dbo.PAIS ON dbo.IMPEXCELFACTIMP.ORIGEN = dbo.PAIS.PA_CORTO  LEFT OUTER JOIN
				VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
		                      dbo.PAIS PAISISO ON dbo.IMPEXCELFACTIMP.ORIGEN = PAISISO.PA_ISO
		WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     TI_CODIGO
		                            FROM          RELTEMBTIPO
		                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
				dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,'')))
							FROM         MAESTRO
							where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
						          and MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)		
							GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))
							HAVING      (COUNT(MA_CODIGO) > 1)) 
		GROUP BY dbo.IMPEXCELFACTIMP.ORDEN, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, MAESTRO.MA_NOPARTEAUX
		ORDER BY dbo.IMPEXCELFACTIMP.ORDEN
	
		/*SELECT     TOP 100 PERCENT dbo.IMPEXCELFACTIMP.ORDEN+@consecutivo, @Codigo, dbo.IMPEXCELFACTIMP.NOPARTE, isnull(dbo.IMPEXCELFACTIMP.COSTO,0), 
		                      dbo.IMPEXCELFACTIMP.CANTIDAD, isnull(dbo.IMPEXCELFACTIMP.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
		                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)),
					isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
		                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_GENERICO,0), 
		                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.IMPEXCELFACTIMP.PESO,0) * 2.20462442018378, 
		                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
		                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),dbo.MAESTRO.ME_COM),
		                      (SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo), round(isnull(dbo.IMPEXCELFACTIMP.CANTIDAD * dbo.IMPEXCELFACTIMP.COSTO,0),6), 
		                      round(dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0),6), round(dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0) * 2.20462442018378,6), 
		                      round(dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0),6), round(dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0) * 2.20462442018378,6),
			         isnull(dbo.IMPEXCELFACTIMP.CANTIDAD,0), 'TCO_CODIGO'=case when dbo.MAESTRO.MA_TIP_ENS='A' THEN  (select TCO_COMPRA from configuracion) ELSE isnull(VMAESTROCOST.TCO_CODIGO,0) END
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE = dbo.IMPEXCELFACTIMP.NOPARTE LEFT OUTER JOIN
		                      dbo.PAIS ON dbo.IMPEXCELFACTIMP.ORIGEN = dbo.PAIS.PA_CORTO  LEFT OUTER JOIN
				VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
		                      dbo.PAIS PAISISO ON dbo.IMPEXCELFACTIMP.ORIGEN = PAISISO.PA_ISO
		WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     TI_CODIGO
		                            FROM          RELTEMBTIPO
		                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
				dbo.IMPEXCELFACTIMP.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
							FROM         dbo.MAESTRO
							GROUP BY MA_NOPARTE
							HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
						                          (SELECT NOPARTE FROM IMPEXCELFACTIMP))) 
		ORDER BY dbo.IMPEXCELFACTIMP.ORDEN*/
END
ELSE
BEGIN
		INSERT INTO FACTIMPDET (FID_INDICED,FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_PES_UNILB,FID_NOMBRE,FID_NAME,MA_CODIGO,
	                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
	 				       AR_EXPFO,FID_PES_UNI,EQ_IMPMX,EQ_EXPFO,EQ_EXPFO2,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, PR_CODIGO,
					       	FID_COS_TOT, FID_PES_NET, FID_PES_NETLB, FID_PES_BRU, FID_PES_BRULB, FID_SALDO, TCO_CODIGO, FID_NOPARTEAUX) 

		SELECT     TOP 100 PERCENT dbo.IMPEXCELFACTIMP.ORDEN+@consecutivo, @Codigo, max(dbo.IMPEXCELFACTIMP.NOPARTE), max(dbo.IMPEXCELFACTIMP.COSTO), 
		                      sum(dbo.IMPEXCELFACTIMP.CANTIDAD), isnull(max(dbo.IMPEXCELFACTIMP.PESO),0), max(dbo.MAESTRO.MA_NOMBRE), max(dbo.MAESTRO.MA_NAME), 
		                      dbo.MAESTRO.MA_CODIGO, isnull(max(dbo.MAESTRO.TI_CODIGO),10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, ISNULL(isnull(max(PAISISO.PA_CODIGO), max(dbo.PAIS.PA_CODIGO)), max(dbo.MAESTRO.PA_ORIGEN)), isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), isnull(max(dbo.MAESTRO.SPI_CODIGO),0)),
					 isnull(max(dbo.MAESTRO.MA_SEC_IMP),0), 
		                      ISNULL(max(dbo.MAESTRO.SPI_CODIGO), 0), ISNULL(isnull(max(PAISISO.PA_CODIGO), max(dbo.PAIS.PA_CODIGO)), max(dbo.MAESTRO.PA_ORIGEN)), isnull(dbo.MAESTRO.MA_GENERICO,0), 
		                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(max(dbo.IMPEXCELFACTIMP.PESO),0) / 2.20462442018378, 
		                      ISNULL(max(dbo.MAESTRO.EQ_IMPMX), 1), ISNULL(max(dbo.MAESTRO.EQ_EXPFO), 1), ISNULL(max(dbo.MAESTRO.EQ_EXPFO2), 1), ISNULL(max(dbo.MAESTRO.EQ_GEN), 1),  isnull(max(dbo.MAESTRO.MA_DEF_TIP),'G'), 
		                      isnull(max(dbo.MAESTRO.ME_COM),19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),max(dbo.MAESTRO.ME_COM)),
		                      isnull((SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo),0), round(sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * isnull(max(dbo.IMPEXCELFACTIMP.COSTO),0),6), 
		                      round((sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * isnull(max(dbo.IMPEXCELFACTIMP.PESO),0))/2.20462442018378,6), round(sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * isnull(max(dbo.IMPEXCELFACTIMP.PESO),0),6), 
		                      round((sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * isnull(max(dbo.IMPEXCELFACTIMP.PESO),0))/2.20462442018378,6), round(sum(dbo.IMPEXCELFACTIMP.CANTIDAD) * isnull(max(dbo.IMPEXCELFACTIMP.PESO),0),6),
				sum(dbo.IMPEXCELFACTIMP.CANTIDAD), 'TCO_CODIGO'=case when max(dbo.MAESTRO.MA_TIP_ENS)='A' THEN  (select TCO_COMPRA from configuracion) ELSE isnull(max(VMAESTROCOST.TCO_CODIGO),0) END, MAESTRO.MA_NOPARTEAUX
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') LEFT OUTER JOIN
		                      dbo.PAIS ON dbo.IMPEXCELFACTIMP.ORIGEN = dbo.PAIS.PA_CORTO  LEFT OUTER JOIN
				VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
		                      dbo.PAIS PAISISO ON dbo.IMPEXCELFACTIMP.ORIGEN = PAISISO.PA_ISO
		WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     TI_CODIGO
		                            FROM          RELTEMBTIPO
		                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
	
				dbo.IMPEXCELFACTIMP.NOPARTE+'-'+ISNULL(IMPEXCELFACTIMP.NOPARTEAUX,'') NOT IN (SELECT     MAESTRO.MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MAESTRO.MA_NOPARTEAUX,'')))
							FROM         MAESTRO
							where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
                					  and MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,''))) IN (SELECT NOPARTE+'-'+ISNULL(NOPARTEAUX,'') FROM IMPEXCELFACTIMP)
							GROUP BY MA_NOPARTE+'-'+LTRIM(RTRIM(isnull(MA_NOPARTEAUX,'')))
							HAVING      (COUNT(MA_CODIGO) > 1))
		GROUP BY dbo.IMPEXCELFACTIMP.ORDEN, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_GENERICO, dbo.MAESTRO.AR_IMPMX, dbo.MAESTRO.AR_EXPFO, MAESTRO.MA_NOPARTEAUX
		ORDER BY dbo.IMPEXCELFACTIMP.ORDEN



	
	
/*		SELECT     TOP 100 PERCENT dbo.IMPEXCELFACTIMP.ORDEN+@consecutivo, @Codigo, dbo.IMPEXCELFACTIMP.NOPARTE, dbo.IMPEXCELFACTIMP.COSTO, 
		                      dbo.IMPEXCELFACTIMP.CANTIDAD, isnull(dbo.IMPEXCELFACTIMP.PESO,0), dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
		                      dbo.MAESTRO.MA_CODIGO, isnull(dbo.MAESTRO.TI_CODIGO,10), dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)),
					 isnull(dbo.MAESTRO.MA_SEC_IMP,0), 
		                      ISNULL(dbo.MAESTRO.SPI_CODIGO, 0), ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_GENERICO,0), 
		                      ISNULL(dbo.MAESTRO.AR_IMPMX, 0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = dbo.MAESTRO.AR_IMPMX),0), ISNULL(dbo.MAESTRO.AR_EXPFO, 0), isnull(dbo.IMPEXCELFACTIMP.PESO,0) / 2.20462442018378, 
		                      ISNULL(dbo.MAESTRO.EQ_IMPMX, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO, 1), ISNULL(dbo.MAESTRO.EQ_EXPFO2, 1), ISNULL(dbo.MAESTRO.EQ_GEN, 1),  isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), 
		                      isnull(dbo.MAESTRO.ME_COM,19), isnull((SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = dbo.MAESTRO.MA_GENERICO),dbo.MAESTRO.ME_COM),
		                      isnull((SELECT PR_CODIGO FROM FACTIMP WHERE FI_CODIGO = @Codigo),0), round(dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.COSTO,0),6), 
		                      round((dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0))/2.20462442018378,6), round(dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0),6), 
		                      round((dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0))/2.20462442018378,6), round(dbo.IMPEXCELFACTIMP.CANTIDAD * isnull(dbo.IMPEXCELFACTIMP.PESO,0),6),
				dbo.IMPEXCELFACTIMP.CANTIDAD, 'TCO_CODIGO'=case when dbo.MAESTRO.MA_TIP_ENS='A' THEN  (select TCO_COMPRA from configuracion) ELSE isnull(VMAESTROCOST.TCO_CODIGO,0) END
		FROM         dbo.MAESTRO INNER JOIN
		                      dbo.IMPEXCELFACTIMP ON dbo.MAESTRO.MA_NOPARTE = dbo.IMPEXCELFACTIMP.NOPARTE LEFT OUTER JOIN
		                      dbo.PAIS ON dbo.IMPEXCELFACTIMP.ORIGEN = dbo.PAIS.PA_CORTO  LEFT OUTER JOIN
				VMAESTROCOST ON dbo.MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO LEFT OUTER JOIN
		                      dbo.PAIS PAISISO ON dbo.IMPEXCELFACTIMP.ORIGEN = PAISISO.PA_ISO
		WHERE     (dbo.MAESTRO.MA_INV_GEN = 'I') AND (dbo.MAESTRO.TI_CODIGO IN
		                          (SELECT     TI_CODIGO
		                            FROM          RELTEMBTIPO
		                            WHERE      TQ_CODIGO = @TipoEmbarque)) AND (dbo.MAESTRO.MA_EST_MAT = 'A') AND
	
				dbo.IMPEXCELFACTIMP.NOPARTE NOT IN (SELECT     dbo.MAESTRO.MA_NOPARTE
							FROM         dbo.MAESTRO
							GROUP BY MA_NOPARTE
							HAVING      (COUNT(MA_CODIGO) > 1) AND (MA_NOPARTE IN
						                          (SELECT NOPARTE FROM IMPEXCELFACTIMP)))
		ORDER BY dbo.IMPEXCELFACTIMP.ORDEN*/

END


	update factimp
	set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
	where fi_codigo =@Codigo


	update factimpdet
	set eq_gen=fid_pes_uni
	where me_gen=36 and fi_codigo=@Codigo
	update factimpdet
	set eq_impmx=fid_pes_uni
	where me_arimpmx=36 and fi_codigo=@Codigo


	if (select cf_selpaisimp from configuracion)='S'
	EXEC SP_ACTUALIZAIMPEXCELPROVEE @CODIGO, 'F'


	if (SELECT CF_VALIDAPERMISOS FROM CONFIGURACION)='I'
	EXEC SP_INSERTPERMISODET @Codigo

	-- cambia el tipo de tasa en base a la configuracion
	if (select CF_ACTTASA from configuracion)='S'
	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'PARA ACTUALIZAR A LA TASA MAS BAJA DEBERA DE EJECUTAR EN PROCESO MANUALMENTE POR MEDIO DE INFORANEXA', 21
	--	EXEC SP_ACTUALIZATASABAJAFACTIMP  @codigo 

	EXEC sp_actualizaReferencia @Codigo

select @FID_indiced= max(FID_indiced) from FACTIMPDET

	update consecutivo
	set cv_codigo =  isnull(@FID_indiced,0) + 1
	where cv_tipo = 'FID'

	ALTER TABLE FACTIMPDET ENABLE TRIGGER Update_FactImpDet


	TRUNCATE TABLE IMPEXCELFACTIMP

GO
