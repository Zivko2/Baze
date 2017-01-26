SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























/* Stored para pasar los pedimentos de exportacion  de la tab la factcons a la tabla pedimp*/
CREATE PROCEDURE [dbo].[SP_temp_pedexportacion]
 AS
SET NOCOUNT ON 

DECLARE @FC_FOLIO varchar(25), @CP_CODIGO int, @FC_SEM varchar(20), @FC_INI datetime, @FC_FIN datetime, 
@FC_ACUSEDERECIBO varchar(30), @AGT_CODIGO smallint, @FC_FECHA datetime, @FC_TIP_CAM decimal(38,6), @AD_DES smallint, @REG_CODIGO smallint, 
@FC_FOLIOPAGO varchar(25), @FC_CHEQUEPAGO varchar(20), @FC_COMPLEMEN varchar(15), @FC_FECHAPAGO datetime, @FC_TIP_CAMPAGO decimal(38,6), 
@CL_CODIGO int, @FC_IMPORTECONTR decimal(38,6), @CL_DESTINO int, @DIR_DESTINO int, @US_CODIGO smallint, @FC_IMPORTERECARGOS decimal(38,6), 
@FC_PORCENNAFTA decimal(38,6), @CONSECUTIVO INT, @pi_codigo int, @pi_codigo2 int, @di_indice int, @FechaActual  varchar(10)



  SET @FechaActual = convert(varchar(10), getdate(),101)


DECLARE CUR_PEDEXP CURSOR FOR

	SELECT     dbo.FACTCONS.FC_FOLIO, dbo.FACTCONS.CP_CODIGO, dbo.FACTCONS.FC_SEM, dbo.FACTCONS.FC_INI, dbo.FACTCONS.FC_FIN, 
	                      dbo.FACTCONS.FC_ACUSEDERECIBO, dbo.FACTCONS.AGT_CODIGO, dbo.FACTCONS.FC_FECHA, dbo.FACTCONS.FC_TIP_CAM, isnull(dbo.FACTCONS.AD_DES,53), 
	                      dbo.FACTCONS.REG_CODIGO, dbo.FACTCONS.CL_CODIGO, dbo.FACTCONS.US_CODIGO
	FROM         dbo.FACTCONS LEFT OUTER JOIN
	                      dbo.PEDIMP ON dbo.FACTCONS.FC_FOLIO = dbo.PEDIMP.PI_FOLIO
	WHERE     (dbo.FACTCONS.FC_TIPO = 'S') AND (dbo.PEDIMP.PI_FOLIO IS NULL) 

OPEN CUR_PEDEXP
	FETCH NEXT FROM CUR_PEDEXP INTO @FC_FOLIO, @CP_CODIGO, @FC_SEM, @FC_INI, @FC_FIN, @FC_ACUSEDERECIBO, @AGT_CODIGO, @FC_FECHA, 
	@FC_TIP_CAM, @AD_DES, @REG_CODIGO, @CL_CODIGO, @US_CODIGO



WHILE (@@FETCH_STATUS = 0)
BEGIN




SELECT @CONSECUTIVO=ISNULL(MAX(PI_CODIGO),0) FROM PEDIMP 

SET @CONSECUTIVO=@CONSECUTIVO+1

	select @di_indice = di_indice from dir_cliente where cl_codigo=@CL_CODIGO and di_fiscal='S'


			INSERT INTO PEDIMP (PI_CODIGO, PI_FOLIO, CP_CODIGO, PI_SEM, PI_FECHAINI, PI_FECHAFIN, PI_FIRMA, AGT_CODIGO, PI_FEC_PAG, 
		PI_TIP_CAM, AD_DES, REG_CODIGO, CL_CODIGO, US_CODIGO, PI_MOVIMIENTO)
		

			VALUES
				(@CONSECUTIVO,  @FC_FOLIO,  @CP_CODIGO,  isnull(@FC_SEM,''),  @FC_INI, @FC_FIN,  isnull(@FC_ACUSEDERECIBO,''),  @AGT_CODIGO,  
		@FC_FECHA, @FC_TIP_CAM,  @AD_DES,  @REG_CODIGO, isnull(@CL_CODIGO,1), @US_CODIGO, 'S')


	FETCH NEXT FROM CUR_PEDEXP INTO @FC_FOLIO, @CP_CODIGO, @FC_SEM, @FC_INI, @FC_FIN, @FC_ACUSEDERECIBO, @AGT_CODIGO, @FC_FECHA, 
	@FC_TIP_CAM, @AD_DES, @REG_CODIGO, @CL_CODIGO, @US_CODIGO

END



CLOSE CUR_PEDEXP
DEALLOCATE CUR_PEDEXP

		
		select @Pi_codigo= isnull(max(pi_codigo),0) from pedimp
		
			update consecutivo
			set cv_codigo =  isnull(@pi_codigo,0) + 1
			where cv_tipo = 'PI'
		


		/* actualizacion de pi_codigo de la tabla factexp */		
		update dbo.FACTEXP
		SET     dbo.FACTEXP.PI_CODIGO= dbo.PEDIMP.PI_CODIGO
		FROM         dbo.FACTCONS INNER JOIN
		                      dbo.FACTEXP ON dbo.FACTCONS.FC_CODIGO = dbo.FACTEXP.FC_CODIGO INNER JOIN
		                      dbo.PEDIMP ON dbo.FACTCONS.FC_FOLIO = dbo.PEDIMP.PI_FOLIO
		WHERE     (dbo.PEDIMP.PI_MOVIMIENTO = 'S')


		/* insercion  de contribuciones */


		INSERT INTO PEDIMPCONTRIBUCION (PI_CODIGO, CON_CODIGO, PIT_CONTRIBTOTMN)
		SELECT     dbo.PEDIMP.PI_CODIGO, (select con_codigo from contribucion where con_clave='1'), dbo.FACTCONS.FC_DTA1_CANT
		FROM         dbo.FACTCONS INNER JOIN
		                      dbo.PEDIMP ON dbo.FACTCONS.FC_FOLIO = dbo.PEDIMP.PI_FOLIO
		WHERE     (dbo.FACTCONS.FC_TIPO = 'S') AND dbo.FACTCONS.FC_DTA1_CANT IS NOT NULL
		and dbo.PEDIMP.PI_CODIGO not in (select PI_CODIGO from PEDIMPCONTRIBUCION where
		CON_CODIGO in(select con_codigo from contribucion where con_clave='1'))
		
		INSERT INTO PEDIMPCONTRIBUCION (PI_CODIGO, CON_CODIGO, PIT_CONTRIBTOTMN)
		SELECT     dbo.PEDIMP.PI_CODIGO, (select con_codigo from contribucion where con_clave='12'), dbo.FACTCONS.FC_ADV_CANT
		FROM         dbo.FACTCONS INNER JOIN
		                      dbo.PEDIMP ON dbo.FACTCONS.FC_FOLIO = dbo.PEDIMP.PI_FOLIO
		WHERE     (dbo.FACTCONS.FC_TIPO = 'S') AND dbo.FACTCONS.FC_ADV_CANT IS NOT NULL
		and dbo.PEDIMP.PI_CODIGO not in (select PI_CODIGO from PEDIMPCONTRIBUCION where
		CON_CODIGO in(select con_codigo from contribucion where con_clave='12'))
		
		INSERT INTO PEDIMPCONTRIBUCION (PI_CODIGO, CON_CODIGO, PIT_CONTRIBTOTMN)
		SELECT     dbo.PEDIMP.PI_CODIGO, (select con_codigo from contribucion where con_clave='3'), dbo.FACTCONS.FC_IVA
		FROM         dbo.FACTCONS INNER JOIN
		                      dbo.PEDIMP ON dbo.FACTCONS.FC_FOLIO = dbo.PEDIMP.PI_FOLIO
		WHERE     (dbo.FACTCONS.FC_TIPO = 'S') AND (dbo.FACTCONS.FC_IVA IS NOT NULL)
		and dbo.PEDIMP.PI_CODIGO not in (select PI_CODIGO from PEDIMPCONTRIBUCION where
		CON_CODIGO in(select con_codigo from contribucion where con_clave='3'))


/* insercion  de detalle */

		declare cur_pedexpdet cursor for
		SELECT     PI_CODIGO
		FROM         dbo.PEDIMP
		WHERE     (PI_MOVIMIENTO = 'S')
		open cur_pedexpdet
		FETCH NEXT FROM cur_pedexpdet INTO @pi_codigo2
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
		
			exec sp_fillpedexp @pi_codigo2, 1
		
		FETCH NEXT FROM cur_pedexpdet INTO @pi_codigo2
		END
		
		CLOSE CUR_PEDEXPdet
		DEALLOCATE CUR_PEDEXPdet



























GO
