SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_IMPEXCELENTSALALMLISTA] (@end_indiced int)   as

SET NOCOUNT ON 
declare @EN_CODIGO int, @ENT_indicer int, @consecutivo int, @ma_hijo int, @ENT_noparte varchar(30), @ENT_nombre varchar(150), @ENT_name varchar(150),
@ENT_incorpor decimal(38,6), @fed_indiced int, @ti_hijo int, @me_codigo int, @ME_ALM int, @ENT_incorporgen decimal(38,6), @Factconv decimal(28,14),
@NOPARTE VARCHAR(30)

DELETE FROM IMPORTLOG WHERE IML_CBFORMA=115
if (select count(*) from IMPORTLOG)=0
DBCC CHECKIDENT (IMPORTLOG, RESEED, 0) WITH NO_INFOMSGS
delete from IMPEXCELALM where NOPARTE=''
/*	DECLARE CUR_IMPHIJOEXCEL CURSOR FOR
	SELECT NOPARTE FROM IMPEXCELALM
	WHERE NOPARTE NOT IN
	(SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN = 'I' 
	                                             AND MA_EST_MAT = 'A') 
	OPEN CUR_IMPHIJOEXCEL
	FETCH NEXT FROM CUR_IMPHIJOEXCEL INTO @NOPARTE
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
		INSERT INTO IMPORTLOG (IML_MENSAJE) VALUES ('NO SE PUEDE IMPORTAR NO. DE PARTE : '+@NOPARTE +'PORQUE NO
		SE ENCUENTRA EN EL CATALOGO MAESTRO')
		FETCH NEXT FROM CUR_IMPHIJOEXCEL INTO @NOPARTE
	END
	CLOSE CUR_IMPHIJOEXCEL
	DEALLOCATE CUR_IMPHIJOEXCEL*/

	INSERT INTO IMPORTLOG (IML_MENSAJE, IML_CBFORMA) 
	SELECT 'NO SE PUEDE IMPORTAR NO. DE PARTE : '+NOPARTE +'PORQUE NO
		SE ENCUENTRA EN EL CATALOGO MAESTRO', 115
	FROM IMPEXCELALM
	WHERE NOPARTE NOT IN
	(SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN = 'I' 
	                                             AND MA_EST_MAT = 'A') 

	select @EN_CODIGO= en_codigo from entsalalmdet where end_indiced=@end_indiced
	select @consecutivo=cv_codigo from consecutivo
	where cv_tipo = 'END'
/* se ejecutan los procedimientos para llenar el detalle */
		INSERT INTO ENTSALALMLISTA (ENT_INDICER, EN_CODIGO, END_INDICED, MA_HIJO, ENT_NOPARTE, ENT_NOMBRE, ENT_NAME, ENT_INCORPOR,
			TI_HIJO, ME_CODIGO, ME_ALM, FACTCONV)
		SELECT     dbo.IMPEXCELALM.ORDEN+@consecutivo, @EN_CODIGO, @end_indiced, dbo.MAESTRO.MA_CODIGO, dbo.MAESTRO.MA_NOPARTE, dbo.MAESTRO.MA_NOMBRE, dbo.MAESTRO.MA_NAME, 
		                      dbo.IMPEXCELALM.CANTIDAD, dbo.MAESTRO.TI_CODIGO, dbo.MAESTRO.ME_COM, dbo.MEDIDA.ME_CODIGO, 
		                      dbo.MAESTRO.EQ_ALM
		FROM         dbo.MAESTRO MAESTRO_1 LEFT OUTER JOIN
		                      dbo.MEDIDA ON MAESTRO_1.ME_COM = dbo.MEDIDA.ME_CODIGO RIGHT OUTER JOIN
		                      dbo.MAESTRO ON MAESTRO_1.MA_CODIGO = dbo.MAESTRO.MA_GENERICO RIGHT OUTER JOIN
		                      dbo.IMPEXCELALM ON dbo.MAESTRO.MA_NOPARTE = dbo.IMPEXCELALM.NOPARTE
		WHERE dbo.IMPEXCELALM.NOPARTE IN (SELECT MA_NOPARTE FROM MAESTRO WHERE MA_INV_GEN = 'I' 
	                                             AND MA_EST_MAT = 'A' AND TI_CODIGO NOT IN (SELECT TI_CODIGO FROM CONFIGURATIPO WHERE CFT_TIPO='P'
				OR CFT_TIPO='S')) 
		ORDER BY dbo.IMPEXCELALM.ORDEN

select @ENT_indicer= max(ENT_indicer) from ENTSALALMLISTA
	update consecutivo
	set cv_codigo =  isnull(@ENT_indicer,0) + 1
	where cv_tipo = 'ENT'



GO
