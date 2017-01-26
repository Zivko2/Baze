SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




















CREATE PROCEDURE [dbo].[SP_IMPEXCELRETRABAJO] (@fetr_indiced int,@tipo char(1))   as

SET NOCOUNT ON 
declare @FETR_CODIGO int, @re_indicer int, @consecutivo int, @ma_hijo int, @re_noparte varchar(30), @re_nombre varchar(150), @re_name varchar(150),
@re_incorpor decimal(38,6), @fed_indiced int, @ti_hijo int, @me_codigo int, @ma_generico int, @me_gen int, @re_incorporgen decimal(38,6), @Factconv decimal(28,14),
@NOPARTE VARCHAR(30), @fed_retrabajo char(1)
/*Yolanda 2009-01-21*/
DECLARE @TipoEntrada CHAR(1)
SET @TipoEntrada= 'I'

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=20

if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS

delete from IMPEXCELRETRA where NOPARTE=''
/*
	DECLARE CUR_IMPHIJOEXCEL CURSOR FOR
	SELECT NOPARTE FROM IMPEXCELRETRA
	WHERE NOPARTE NOT IN
	(SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN = 'I' 
   	                                             AND MA_EST_MAT = 'A') 
	OPEN CUR_IMPHIJOEXCEL
	FETCH NEXT FROM CUR_IMPHIJOEXCEL INTO @NOPARTE
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA ) 
		VALUES ('NO SE PUEDE IMPORTAR NO. DE PARTE : '+@NOPARTE +'PORQUE NO
		SE ENCUENTRA EN EL CATALOGO MAESTRO', 20)
		FETCH NEXT FROM CUR_IMPHIJOEXCEL INTO @NOPARTE
	END
	CLOSE CUR_IMPHIJOEXCEL
	DEALLOCATE CUR_IMPHIJOEXCEL*/

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA ) 
	SELECT 'NO SE PUEDE IMPORTAR NO. DE PARTE : '+NOPARTE+' CON EL AUX.: '+isnull(NOPARTEAUX,'') +' PORQUE NO
		SE ENCUENTRA EN EL CATALOGO MAESTRO', 20
	FROM IMPEXCELRETRA
	WHERE NOPARTE+'-'+isnull(NOPARTEAUX,'') NOT IN
	(SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO WHERE MA_INV_GEN = 'I' 
   	                                             AND MA_EST_MAT = 'A') 


	select @FETR_CODIGO= fe_codigo, @fed_retrabajo=fed_retrabajo from factexpdet where fed_indiced=@fetr_indiced


/* se ejecutan los procedimientos para llenar el detalle */


	select @consecutivo=cv_codigo from consecutivo
	where cv_tipo = 'RE'

	if @fed_retrabajo='A'
	begin
		INSERT INTO RETRABAJO (RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
			TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN)


		SELECT     MIN(IMPEXCELRETRA.ORDEN+@consecutivo), 'F', @FETR_CODIGO, @fetr_indiced, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
		                      SUM(dbo.IMPEXCELRETRA.CANTIDAD), dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, dbo.MEDIDA.ME_CODIGO, 
		                     SUM(dbo.IMPEXCELRETRA.CANTIDAD * dbo.MAESTRO.EQ_GEN), dbo.MAESTRO.EQ_GEN, 'N', ISNULL((SELECT MA_NAFTA FROM VMAESTRONAFTA WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO),'N'), dbo.MAESTRO.PA_ORIGEN
		FROM         dbo.MAESTRO MAESTRO_1 LEFT OUTER JOIN
		                      dbo.MEDIDA ON MAESTRO_1.ME_COM = dbo.MEDIDA.ME_CODIGO RIGHT OUTER JOIN
		                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO RIGHT OUTER JOIN
				      dbo.IMPEXCELRETRA ON dbo.MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(dbo.MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELRETRA.NOPARTE+'-'+isnull(dbo.IMPEXCELRETRA.NOPARTEAUX,'')
		WHERE dbo.IMPEXCELRETRA.NOPARTE+'-'+isnull(dbo.IMPEXCELRETRA.NOPARTEAUX,'') IN (SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO WHERE MA_INV_GEN = 'I' 
	                                             AND MA_EST_MAT = 'A' ) 
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
		                      dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, dbo.MEDIDA.ME_CODIGO, 
		                     dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.PA_ORIGEN
		ORDER BY MIN( IMPEXCELRETRA.ORDEN+@consecutivo)
	end
	else
	begin
		INSERT INTO RETRABAJO (RE_INDICER, TIPO_FACTRANS, FETR_CODIGO, FETR_INDICED, MA_HIJO, RE_NOPARTE, RE_NOMBRE, RE_NAME, RE_INCORPOR,
			TI_HIJO, ME_CODIGO, MA_GENERICO, ME_GEN, RE_INCORPORGEN, FACTCONV, FETR_RETRABAJODES, FETR_NAFTA, PA_ORIGEN)


		SELECT     MIN(IMPEXCELRETRA.ORDEN+@consecutivo), 'F', @FETR_CODIGO, @fetr_indiced, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
		                      SUM(dbo.IMPEXCELRETRA.CANTIDAD), dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, dbo.MEDIDA.ME_CODIGO, 
		                     SUM(dbo.IMPEXCELRETRA.CANTIDAD * dbo.MAESTRO.EQ_GEN), dbo.MAESTRO.EQ_GEN, 'N', ISNULL((SELECT MA_NAFTA FROM VMAESTRONAFTA WHERE MA_CODIGO=dbo.MAESTRO.MA_CODIGO),'N'), dbo.MAESTRO.PA_ORIGEN
		FROM         dbo.MAESTRO MAESTRO_1 LEFT OUTER JOIN
		                      dbo.MEDIDA ON MAESTRO_1.ME_COM = dbo.MEDIDA.ME_CODIGO RIGHT OUTER JOIN
		                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO RIGHT OUTER JOIN
		                      dbo.IMPEXCELRETRA ON dbo.MAESTRO.MA_NOPARTE +'-'+rtrim(ltrim(isnull(dbo.MAESTRO.MA_NOPARTEAUX,''))) = dbo.IMPEXCELRETRA.NOPARTE+'-'+isnull(dbo.IMPEXCELRETRA.NOPARTEAUX,'')
		WHERE dbo.IMPEXCELRETRA.NOPARTE+'-'+isnull(dbo.IMPEXCELRETRA.NOPARTEAUX,'') IN (SELECT MA_NOPARTE+'-'+rtrim(ltrim(isnull(MA_NOPARTEAUX,''))) FROM MAESTRO WHERE MA_INV_GEN = 'I' 
	                                             AND MA_EST_MAT = 'A' AND TI_CODIGO NOT IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO='P'
				OR CFT_TIPO='S')) 
		/*Yolanda 2009-01-21*/ and maestro.ma_inv_gen = @TipoEntrada
		GROUP BY dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
		                      dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.ME_COM, dbo.MAESTRO.MA_GENERICO, dbo.MEDIDA.ME_CODIGO, 
		                     dbo.MAESTRO.EQ_GEN, dbo.MAESTRO.PA_ORIGEN
		ORDER BY MIN( IMPEXCELRETRA.ORDEN+@consecutivo)

	end
select @re_indicer= max(re_indicer) from retrabajo

	update consecutivo
	set cv_codigo =  isnull(@re_indicer,0) + 1
	where cv_tipo = 'RE'



--delete from IMPEXCELRETRA
GO
