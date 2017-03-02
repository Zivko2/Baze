SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_IMPEXCELALMDESP] @am_Codigo int   as

DECLARE @ADE_FECHA DATETIME
/*Yolanda 2009-01-21*/
DECLARE @TipoEntrada CHAR(1)
SET @TipoEntrada= 'I'


SELECT     @ADE_FECHA=AM_REFERFECHA
FROM         ALMACENDESPCAR
WHERE     (AM_CODIGO = @AM_CODIGO)

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=-1
if (select count(*) from IMPORTLOG)=0

DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS

delete from IMPEXCELFACTEXP where NOPARTE=''

	if exists(SELECT dbo.IMPEXCELFACTEXP.NOPARTE
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(MAESTRO.MA_NOPARTEAUX)) = IMPEXCELFACTEXP.NOPARTE+'-'+ isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX)) IS NULL) /*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada)
	
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
		SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : ' +dbo.IMPEXCELFACTEXP.NOPARTE+' CON EL AUX.: '+dbo.IMPEXCELFACTEXP.NOPARTEAUX +' POR QUE NO EXISTE EN EL CAT. MAESTRO', -1
		FROM         dbo.MAESTRO RIGHT OUTER JOIN
		                      IMPEXCELFACTEXP ON MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(MAESTRO.MA_NOPARTEAUX)) = IMPEXCELFACTEXP.NOPARTE+'-'+ isnull(IMPEXCELFACTEXP.NOPARTEAUX,'')
		WHERE     (dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX)) IS NULL) 
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada

	if exists(SELECT     dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX))
	FROM         dbo.IMPEXCELFACTEXP INNER JOIN
	                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE +'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(MAESTRO.MA_NOPARTEAUX))
	where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
	GROUP BY dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX))
	HAVING      (COUNT(dbo.MAESTRO.MA_CODIGO) > 1))
	
	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : '+dbo.MAESTRO.MA_NOPARTE+' CON EL AUX.: '+dbo.MAESTRO.MA_NOPARTEAUX+' PORQUE ESTA REPETIDO EN EL CAT. MAESTRO', -1
	FROM         dbo.IMPEXCELFACTEXP INNER JOIN
	                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE +'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(MAESTRO.MA_NOPARTEAUX))
	where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
	GROUP BY dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOPARTEAUX
	HAVING      (COUNT(dbo.MAESTRO.MA_CODIGO) > 1)

	if exists (SELECT  dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX))
	FROM         dbo.IMPEXCELFACTEXP INNER JOIN
	                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE +'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(MAESTRO.MA_NOPARTEAUX))
	WHERE dbo.MAESTRO.MA_CODIGO IN (SELECT MA_HIJO FROM ALMACENDESP WHERE AM_CODIGO=@AM_CODIGO)
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	GROUP BY dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX)))

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT     'NO SE PUEDE IMPORTAR NO. PARTE : '+dbo.MAESTRO.MA_NOPARTE+' CON EL AUX.: '+dbo.MAESTRO.MA_NOPARTEAUX+' PORQUE YA EXISTE EN EL ALMACEN DESPERDICIO', -1
	FROM         dbo.IMPEXCELFACTEXP INNER JOIN
	                      MAESTRO ON IMPEXCELFACTEXP.NOPARTE +'-'+isnull(IMPEXCELFACTEXP.NOPARTEAUX,'') = MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(MAESTRO.MA_NOPARTEAUX))
	WHERE dbo.MAESTRO.MA_CODIGO IN (SELECT MA_HIJO FROM ALMACENDESP WHERE AM_CODIGO=@AM_CODIGO)
	/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
	GROUP BY dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOPARTEAUX


	insert into    ALMACENDESP ( AM_CODIGO, FETR_TIPO, TIPO_ENT_SAL, MA_HIJO, TI_CODIGO, ADE_CANT, ADE_CANTKG, ME_CODIGO, ADE_SALDO, ADE_ENUSO, ADE_GENERADOPOR, 
	                      MA_GENERA_EMP, EQ_GENERICO, MA_GENERICO, ADE_FECHA, ADE_PESO_UNIKG)
	SELECT     @AM_CODIGO, 'F', 'S', dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.TI_CODIGO, dbo.IMPEXCELFACTEXP.CANTIDAD / dbo.MAESTRO.MA_PESO_KG, 
	                      dbo.IMPEXCELFACTEXP.CANTIDAD, dbo.MAESTRO.ME_COM, dbo.IMPEXCELFACTEXP.CANTIDAD / dbo.MAESTRO.MA_PESO_KG, 'N', 'C', 
	               dbo.MAESTRO.MA_GENERA_EMP, dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.MA_GENERICO, @ADE_FECHA, isnull(dbo.MAESTRO.MA_PESO_KG,0)
	FROM         dbo.IMPEXCELFACTEXP INNER JOIN
	                      dbo.MAESTRO ON dbo.IMPEXCELFACTEXP.NOPARTE +'-'+isnull(dbo.IMPEXCELFACTEXP.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX))
	WHERE  dbo.MAESTRO.MA_EST_MAT = 'A'  AND dbo.MAESTRO.MA_INV_GEN='I'  AND dbo.IMPEXCELFACTEXP.NOPARTE+'-'+isnull(dbo.IMPEXCELFACTEXP.NOPARTEAUX,'') NOT IN (SELECT dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX))
			FROM         dbo.IMPEXCELFACTEXP INNER JOIN
			                      dbo.MAESTRO ON dbo.IMPEXCELFACTEXP.NOPARTE +'-'+isnull(dbo.IMPEXCELFACTEXP.NOPARTEAUX,'') = dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX))
			where /*Yolanda 2009-01-21*/ maestro.ma_inv_gen = @TipoEntrada
			GROUP BY dbo.MAESTRO.MA_NOPARTE+'-'+rtrim(ltrim(dbo.MAESTRO.MA_NOPARTEAUX))
			HAVING      (COUNT(dbo.MAESTRO.MA_CODIGO) > 1))




























GO