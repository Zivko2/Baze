SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




























CREATE PROCEDURE [dbo].[SP_IMPEXCELFACTIMP2factimp]     as

SET NOCOUNT ON 
DECLARE @fi_folio varchar(15), @fi_fecha DateTime, @tf_codigo smallint, @tq_codigo smallint, @fi_tipo char(1), @pr_codigo int, @di_provee int, @cl_destfin int, @di_destfin int,
	@ag_mex int, @ag_usa int, @cl_imp int, @di_imp int, @fi_pfinal datetime, @fi_pinicial datetime, @consecutivo int, @fecha varchar(10), @fi_codigo int, @consecutivo2 INT,
@FID_indiced INT, @cl_matriz int, @CF_PESOS_IMP CHAR(1), @owner varchar(150)

	delete from impexcelfactimp2 where part_number='-1'
	EXEC SP_IMPEXCELFACTIMP2mp


	SELECT     @CF_PESOS_IMP = CF_PESOS_IMP
	FROM         CONFIGURACION



	if exists (select * from factimp where fi_folio not in ( select FOLIO from IMPEXCELFACTIMP2))
	begin
		Set @fecha =  convert(varchar(10),GETDATE(), 101)
	
		SELECT @CONSECUTIVO=ISNULL(MAX(FI_CODIGO),0) FROM FACTIMP
		SET @CONSECUTIVO=@CONSECUTIVO+1
	
	
		select @ag_mex=ag_mex, @ag_usa=ag_usa, @cl_matriz=cl_matriz from cliente where cl_codigo=1
	
		INSERT INTO FACTIMP(fi_folio, fi_fecha, tf_codigo, tq_codigo, fi_tipo, pr_codigo, di_provee, cl_destfin, di_destfin,
		ag_mex, ag_usa, cl_imp, di_imp, fi_pfinal, fi_pinicial, fi_codigo, ct_codigo, fi_cont_reg, fi_tipocambio)
	
	
		SELECT     IMPEXCELFACTIMP2.FOLIO, isnull(max(IMPEXCELFACTIMP2.INV_DATE), @fecha), 
			5, 12, 'F', isnull(max(CLIENTE_1.CL_CODIGO), @cl_matriz), isnull((select min(di_indice) from dir_cliente where cl_codigo=isnull(max(CLIENTE_1.CL_CODIGO),@cl_matriz) and di_fiscal='s'),0), 
			isnull(max(CLIENTE_3.CL_CODIGO),1), isnull((select min(di_indice) from dir_cliente where cl_codigo=isnull(max(CLIENTE_3.CL_CODIGO),1) and di_fiscal='s'),0), 
			@ag_mex, @ag_usa, 1, (select min(di_indice) from dir_cliente where cl_codigo=1 and di_fiscal='s'), isnull(max(IMPEXCELFACTIMP2.INV_DATE), @fecha), isnull(max(IMPEXCELFACTIMP2.INV_DATE), @fecha),
			@CONSECUTIVO, max(CTRANSPOR.CT_CODIGO), isnull(max(IMPEXCELFACTIMP2.CONTAINER), ''), isnull(max(IMPEXCELFACTIMP2.EXCHANGE_RATE),
			(select max(tc_cant) from tcambio where tc_fecha=isnull(max(IMPEXCELFACTIMP2.INV_DATE), @fecha)))
		FROM         CTRANSPOR RIGHT OUTER JOIN
		                      IMPEXCELFACTIMP2 ON CTRANSPOR.CT_CORTO = IMPEXCELFACTIMP2.CARRIER LEFT OUTER JOIN
		                      CLIENTE CLIENTE_3 ON IMPEXCELFACTIMP2.DESTINATION = CLIENTE_3.CL_RAZON LEFT OUTER JOIN
		                      CLIENTE CLIENTE_2 ON IMPEXCELFACTIMP2.CONSIGNEE = CLIENTE_2.CL_RAZON LEFT OUTER JOIN
		                      CLIENTE CLIENTE_1 ON IMPEXCELFACTIMP2.SHIPPER_CODE = CLIENTE_1.CL_RAZON
		WHERE IMPEXCELFACTIMP2.FOLIO NOT IN (SELECT FI_FOLIO FROM FACTIMP)
		GROUP BY IMPEXCELFACTIMP2.FOLIO
	
	
	end	


	select @consecutivo2=cv_codigo from consecutivo
	where cv_tipo = 'FID'

	IF @CF_PESOS_IMP='K'
	BEGIN

		INSERT INTO FACTIMPDET (FID_INDICED, FI_CODIGO, FID_NOPARTE, MA_CODIGO, FID_NAME, FID_NOMBRE, FID_CANT_ST, ME_CODIGO,
			MA_EMPAQUE, FID_CANTEMP, FID_PES_NET, FID_PES_BRU, FID_PES_UNI, FID_COS_UNI, TCO_CODIGO, AR_IMPMX, AR_EXPFO,
			PA_CODIGO, TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO, EQ_IMPMX,EQ_EXPFO,EQ_GEN,FID_DEF_TIP, ME_GEN, MA_GENERICO,
			FID_COS_TOT, FID_PES_UNILB, FID_PES_NETLB, FID_PES_BRULB, FID_SALDO)
	
		SELECT       IMPEXCELFACTIMP2.FID_INDICED+@consecutivo2, @CONSECUTIVO, MAESTRO.MA_NOPARTE, MAESTRO.MA_CODIGO, ISNULL(IMPEXCELFACTIMP2.DESC_ENG, MAESTRO.MA_NAME), 
		                      ISNULL(IMPEXCELFACTIMP2.DESC_SPA, MAESTRO.MA_NOMBRE), IMPEXCELFACTIMP2.QTY, ISNULL(MEDIDA.ME_CODIGO, 
		                      MAESTRO.ME_COM), ISNULL(MAESTRO_1.MA_CODIGO, 0), isnull(IMPEXCELFACTIMP2.PACKAGE_NO,0), isnull(IMPEXCELFACTIMP2.NET_WEIGHT,0), 
		                      isnull(isnull(IMPEXCELFACTIMP2.GROSS_WEIGHT, IMPEXCELFACTIMP2.NET_WEIGHT),0), IMPEXCELFACTIMP2.NET_WEIGHT/IMPEXCELFACTIMP2.QTY, ISNULL(IMPEXCELFACTIMP2.UNIT_COST,VMAESTROCOST.MA_COSTO), ISNULL(VMAESTROCOST.TCO_CODIGO, 0), 
		                      ISNULL(ARANCEL_1.AR_CODIGO, MAESTRO.AR_IMPMX), ISNULL(ARANCEL_2.AR_CODIGO, MAESTRO.AR_EXPFO), ISNULL(ARANCEL_2.PA_CODIGO, 
		                      MAESTRO.PA_ORIGEN), MAESTRO.TI_CODIGO, dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), MAESTRO.MA_SEC_IMP, 
		                      ISNULL(MAESTRO.SPI_CODIGO, 0), ISNULL(MAESTRO.EQ_IMPMX, 1), ISNULL(MAESTRO.EQ_EXPFO, 1), ISNULL(MAESTRO.EQ_GEN, 1), MAESTRO.MA_DEF_TIP, 
		                      (SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = MAESTRO.MA_GENERICO), MAESTRO.MA_GENERICO,
			         IMPEXCELFACTIMP2.QTY*ISNULL(IMPEXCELFACTIMP2.UNIT_COST,VMAESTROCOST.MA_COSTO), (isnull(IMPEXCELFACTIMP2.NET_WEIGHT,0)*2.20462442018378)/IMPEXCELFACTIMP2.QTY, isnull(IMPEXCELFACTIMP2.NET_WEIGHT,0)*2.20462442018378, isnull(isnull(IMPEXCELFACTIMP2.GROSS_WEIGHT, IMPEXCELFACTIMP2.NET_WEIGHT),0)*2.20462442018378,
				IMPEXCELFACTIMP2.QTY
		FROM         VMAESTROCOST RIGHT OUTER JOIN
		                      MAESTRO ON VMAESTROCOST.MA_CODIGO = MAESTRO.MA_CODIGO RIGHT OUTER JOIN
		                      ARANCEL ARANCEL_2 RIGHT OUTER JOIN
		                      IMPEXCELFACTIMP2 LEFT OUTER JOIN
		                      MAESTRO MAESTRO_1 ON IMPEXCELFACTIMP2.PACKAGE_KIND = MAESTRO_1.MA_NOPARTE LEFT OUTER JOIN
		                      MEDIDA ON IMPEXCELFACTIMP2.MEASURE = MEDIDA.ME_CORTO LEFT OUTER JOIN
		                      ARANCEL ARANCEL_1 ON IMPEXCELFACTIMP2.MX_HTS = ARANCEL_1.AR_FRACCION ON 
		                      ARANCEL_2.AR_FRACCION = IMPEXCELFACTIMP2.US_HTS LEFT OUTER JOIN
		                      PAIS ON IMPEXCELFACTIMP2.COUNTRY = PAIS.PA_CORTO ON MAESTRO.MA_NOPARTE = IMPEXCELFACTIMP2.PART_NUMBER
					 LEFT OUTER JOIN PAIS PAISISO ON IMPEXCELFACTIMP2.COUNTRY = PAISISO.PA_ISO 
                                                WHERE MAESTRO.MA_INV_GEN='I'
		ORDER BY FID_INDICED
	
	END
	ELSE
	BEGIN


		INSERT INTO FACTIMPDET (FID_INDICED, FI_CODIGO, FID_NOPARTE, MA_CODIGO, FID_NAME, FID_NOMBRE, FID_CANT_ST, ME_CODIGO,
			MA_EMPAQUE, FID_CANTEMP, FID_PES_NETLB, FID_PES_BRULB, FID_PES_UNILB, FID_COS_UNI, TCO_CODIGO, AR_IMPMX, AR_EXPFO,
			PA_CODIGO, TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO, EQ_IMPMX,EQ_EXPFO,EQ_GEN,FID_DEF_TIP, ME_GEN, MA_GENERICO,
			FID_COS_TOT, FID_PES_UNI, FID_PES_NET, FID_PES_BRU, FID_SALDO)
	
		SELECT      IMPEXCELFACTIMP2.FID_INDICED+@consecutivo2, @CONSECUTIVO, MAESTRO.MA_NOPARTE, MAESTRO.MA_CODIGO, ISNULL(IMPEXCELFACTIMP2.DESC_ENG, MAESTRO.MA_NAME), 
		                      ISNULL(IMPEXCELFACTIMP2.DESC_SPA, MAESTRO.MA_NOMBRE), IMPEXCELFACTIMP2.QTY, ISNULL(MEDIDA.ME_CODIGO, 
		                      MAESTRO.ME_COM), ISNULL(MAESTRO_1.MA_CODIGO, 0), isnull(IMPEXCELFACTIMP2.PACKAGE_NO,0), isnull(IMPEXCELFACTIMP2.NET_WEIGHT,0), 
		                      isnull(isnull(IMPEXCELFACTIMP2.GROSS_WEIGHT, IMPEXCELFACTIMP2.NET_WEIGHT),0), IMPEXCELFACTIMP2.NET_WEIGHT/IMPEXCELFACTIMP2.QTY, ISNULL(IMPEXCELFACTIMP2.UNIT_COST,VMAESTROCOST.MA_COSTO), ISNULL(VMAESTROCOST.TCO_CODIGO, 0), 
		                      ISNULL(ARANCEL_1.AR_CODIGO, MAESTRO.AR_IMPMX), ISNULL(ARANCEL_2.AR_CODIGO, MAESTRO.AR_EXPFO), ISNULL(ARANCEL_2.PA_CODIGO, 
		                      MAESTRO.PA_ORIGEN), MAESTRO.TI_CODIGO, 
					dbo.GetAdvalorem(dbo.MAESTRO.AR_IMPMX, ISNULL(isnull(PAISISO.PA_CODIGO, dbo.PAIS.PA_CODIGO), dbo.MAESTRO.PA_ORIGEN), isnull(dbo.MAESTRO.MA_DEF_TIP,'G'), isnull(dbo.MAESTRO.MA_SEC_IMP,0), isnull(dbo.MAESTRO.SPI_CODIGO,0)), 
				       MAESTRO.MA_SEC_IMP, 
		                      ISNULL(MAESTRO.SPI_CODIGO, 0), ISNULL(MAESTRO.EQ_IMPMX, 1), ISNULL(MAESTRO.EQ_EXPFO, 1), ISNULL(MAESTRO.EQ_GEN, 1), MAESTRO.MA_DEF_TIP, 
		                      (SELECT ME_COM FROM VMAESTRO_GENERICO AS MAESTRO1 WHERE MA_CODIGO = MAESTRO.MA_GENERICO), MAESTRO.MA_GENERICO,
			         IMPEXCELFACTIMP2.QTY*ISNULL(IMPEXCELFACTIMP2.UNIT_COST,VMAESTROCOST.MA_COSTO), (isnull(IMPEXCELFACTIMP2.NET_WEIGHT,0)/2.20462442018378)/IMPEXCELFACTIMP2.QTY, isnull(IMPEXCELFACTIMP2.NET_WEIGHT,0)/2.20462442018378, isnull(isnull(IMPEXCELFACTIMP2.GROSS_WEIGHT, IMPEXCELFACTIMP2.NET_WEIGHT),0)/2.20462442018378,
				IMPEXCELFACTIMP2.QTY
		FROM         VMAESTROCOST RIGHT OUTER JOIN
		                      MAESTRO ON VMAESTROCOST.MA_CODIGO = MAESTRO.MA_CODIGO RIGHT OUTER JOIN
		                      ARANCEL ARANCEL_2 RIGHT OUTER JOIN
		                      IMPEXCELFACTIMP2 LEFT OUTER JOIN
		                      MAESTRO MAESTRO_1 ON IMPEXCELFACTIMP2.PACKAGE_KIND = MAESTRO_1.MA_NOPARTE LEFT OUTER JOIN
		                      MEDIDA ON IMPEXCELFACTIMP2.MEASURE = MEDIDA.ME_CORTO LEFT OUTER JOIN
		                      ARANCEL ARANCEL_1 ON IMPEXCELFACTIMP2.MX_HTS = ARANCEL_1.AR_FRACCION ON 
		                      ARANCEL_2.AR_FRACCION = IMPEXCELFACTIMP2.US_HTS LEFT OUTER JOIN
		                      PAIS ON IMPEXCELFACTIMP2.COUNTRY = PAIS.PA_CORTO ON MAESTRO.MA_NOPARTE = IMPEXCELFACTIMP2.PART_NUMBER
					 LEFT OUTER JOIN PAIS PAISISO ON IMPEXCELFACTIMP2.COUNTRY = PAISISO.PA_ISO 
			        WHERE MAESTRO.MA_INV_GEN='I'
		ORDER BY FID_INDICED

	END


		UPDATE FACTIMPDET
		SET ME_ARIMPMX=(SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO = FACTIMPDET.AR_IMPMX)
		WHERE FI_CODIGO=@CONSECUTIVO


select @fi_codigo= max(fi_codigo) from factimp

	update consecutivo
	set cv_codigo =  isnull(@fi_codigo,0) + 1
	where cv_tipo = 'FI'


	update factimp
	set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo)
	where fi_codigo =@fi_codigo


select @FID_indiced= max(FID_indiced) from FACTIMPDET

	update consecutivo
	set cv_codigo =  isnull(@FID_indiced,0) + 1
	where cv_tipo = 'FID'


	exec sp_droptable 'IMPEXCELFACTIMP2'

GO