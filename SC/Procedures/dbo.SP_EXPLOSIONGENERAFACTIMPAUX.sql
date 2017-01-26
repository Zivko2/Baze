SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO




















































































CREATE PROCEDURE [dbo].[SP_EXPLOSIONGENERAFACTIMPAUX] @tipofactura char(1), @FE_CODIGO int     as

SET NOCOUNT ON 
DECLARE @CONSECUTIVO1 INT, @CONSECUTIVO INT, @NOPARTE varchar(30), @COSTO decimal(38,6), @CANTIDAD decimal(38,6), @PESO decimal(38,6), @MA_CODIGO INT,
@fecha varchar(10), @ag_mex int, @ag_usa int, @cl_matriz int, @cl_trafico int, @pu_carga int, @pu_salida int, @pu_entrada int, @pu_destino int,
@di_matriz int, @di_trafico int, @di_empresa int, @fe_folio varchar(30), @MA_GENERICO INT, @ME_GEN INT, @fi_tipocambio decimal(38,6), @OT_FOLIO VARCHAR(25)


	if @tipofactura='I'
	begin
		select @fe_folio=fe_folio from factexp where fe_codigo=@FE_CODIGO
		set @OT_FOLIO=''
	end
	
	if @tipofactura='A'
	begin
		select @fe_folio=fea_folio from factexpagru where fea_codigo=@FE_CODIGO
		set @OT_FOLIO=''
	end

	if not exists (select * from factimp where fi_folio =('TEMP'+@fe_folio) and fi_tipo='F')
	begin
		SET @FECHA=(CONVERT(VARCHAR(10),GETDATE(),102))
	
		select @fi_tipocambio=tc_cant from tcambio where tc_fecha=@FECHA

		SELECT @CL_MATRIZ=CL_MATRIZ, @AG_MEX=AG_MEX, @AG_USA=AG_USA, @CL_TRAFICO=CL_TRAFICO,
		@PU_CARGA=PU_CARGAS, @PU_SALIDA=PU_SALIDAS, @PU_ENTRADA=PU_ENTRADAS, @PU_DESTINO=PU_DESTINOS 
		FROM CLIENTE WHERE CL_EMPRESA='S'
	
		select @di_matriz= di_indice from dir_cliente where cl_codigo=@cl_matriz and di_fiscal='S'
		select @di_trafico= di_indice from dir_cliente where cl_codigo=@cl_trafico and di_fiscal='S'
		select @di_empresa= di_indice from dir_cliente where cl_codigo=1 and di_fiscal='S'
	
	
	
		EXEC SP_GETCONSECUTIVO @TIPO='FI',@VALUE=@CONSECUTIVO1 OUTPUT

	
		if not exists (select * from factimp where fi_folio =('TEMP'+@fe_folio) and fi_tipo='F')
		INSERT INTO FACTIMP(FI_CODIGO, FI_FOLIO, FI_FECHA, TF_CODIGO, TQ_CODIGO, FI_PINICIAL, FI_PFINAL,
		AG_MEX, AG_USA, PR_CODIGO, DI_PROVEE, CL_PROD, DI_PROD, CL_DESTFIN, DI_DESTFIN,
		CL_COMP, DI_COMP, CL_VEND, DI_VEND, CL_EXP, DI_EXP, CL_IMP, DI_IMP, FI_TIPO, CL_DESTINT, DI_DESTINT, fi_tipocambio)
	
		VALUES (@CONSECUTIVO1, 'TEMP'+@fe_folio, @fecha, 5, 12, @fecha, @fecha,
		@ag_mex, @ag_usa, @cl_matriz, @di_matriz, @cl_matriz, @di_matriz, 1, @di_empresa,
		1, @di_empresa, @cl_matriz, @di_matriz, @cl_matriz, @di_matriz, @cl_trafico, @di_trafico, 'F', 1, @di_empresa, @fi_tipocambio)
	end
	else
	begin
		if exists (select * from factimpdet where fi_codigo in (select fi_codigo from factimp where fi_folio =('TEMP'+@fe_folio) and fi_tipo='F'))
		delete from factimpdet where fi_codigo in (select fi_codigo from factimp where fi_folio =('TEMP'+@fe_folio) and fi_tipo='F')

		select @CONSECUTIVO1=fi_codigo from factimp where fi_folio =('TEMP'+@fe_folio) and fi_tipo='F'

	end	


if @tipofactura='I' 
begin

	DECLARE CUR_IMPEXPLOSION CURSOR FOR
		SELECT     BST_HIJO, SUM(BST_INCORPOR * FED_CANT) 
		FROM BOM_DESCTEMP
		WHERE FE_CODIGO=@FE_CODIGO
		GROUP BY BST_HIJO
end
else
if @tipofactura='A'
begin

	DECLARE CUR_IMPEXPLOSION CURSOR FOR
		SELECT BST_HIJO, CANTIDAD FROM VEXPLOSIONFACTEXP
		WHERE FE_CODIGO in (select fe_codigo from factexp where fe_factagru = @FE_CODIGO)
end
	OPEN CUR_IMPEXPLOSION
	FETCH NEXT FROM CUR_IMPEXPLOSION INTO @MA_CODIGO, @CANTIDAD
	WHILE (@@FETCH_STATUS = 0) 
	BEGIN
	
		SELECT @NOPARTE=MAESTRO.MA_NOPARTE, @COSTO=isnull(VMAESTROCOST.MA_COSTO,0), @PESO=isnull(MAESTRO.MA_PESO_KG,0), @MA_GENERICO=MAESTRO.MA_GENERICO 
		FROM MAESTRO LEFT OUTER JOIN VMAESTROCOST ON MAESTRO.MA_CODIGO=VMAESTROCOST.MA_CODIGO
		WHERE MAESTRO.MA_CODIGO=@MA_CODIGO

		SELECT @ME_GEN=ISNULL(ME_COM,19) FROM MAESTRO WHERE MA_CODIGO=@MA_GENERICO
	
		EXEC SP_GETCONSECUTIVO @TIPO='FID',@VALUE=@CONSECUTIVO OUTPUT	
		INSERT INTO FACTIMPDET (FID_INDICED,FI_CODIGO,FID_NOPARTE,FID_COS_UNI,FID_CANT_ST, FID_COS_TOT, FID_PES_UNI, FID_PES_NET, FID_PES_BRU, FID_NOMBRE,FID_NAME,MA_CODIGO,
	                                                             TI_CODIGO,FID_POR_DEF,FID_SEC_IMP,SPI_CODIGO,PA_CODIGO,MA_GENERICO,AR_IMPMX,ME_ARIMPMX,
	 				       AR_EXPFO,FID_PES_UNILB, FID_PES_NETLB, FID_PES_BRULB, EQ_IMPMX,EQ_EXPFO,EQ_GEN,FID_DEF_TIP, ME_CODIGO, ME_GEN, FID_SALDO, FID_ENUSO,
					        FID_NOORDEN) 
	
	                SELECT @CONSECUTIVO,@CONSECUTIVO1,@NOPARTE,@COSTO,@CANTIDAD, ROUND(@COSTO*@CANTIDAD,6), @PESO, ROUND(@CANTIDAD*@PESO,6), ROUND(@CANTIDAD*@PESO,6), MA_NOMBRE,MA_NAME,MA_CODIGO,TI_CODIGO, dbo.GetAdvalorem(MAESTRO.AR_IMPMX, MAESTRO.PA_ORIGEN, isnull(MAESTRO.MA_DEF_TIP,'G'), isnull(MAESTRO.MA_SEC_IMP,0), isnull(MAESTRO.SPI_CODIGO,0)),
		                                isnull(MA_SEC_IMP,0), ISNULL(SPI_CODIGO,0), PA_ORIGEN, isnull(MA_GENERICO,0), isnull(AR_IMPMX,0), isnull((SELECT ME_CODIGO FROM ARANCEL WHERE AR_CODIGO=AR_IMPMX),0),
		                               isnull(AR_EXPFO,0), @PESO*2.20462442018378, ROUND(@CANTIDAD*@PESO*2.20462442018378,6), ROUND(@CANTIDAD*@PESO*2.20462442018378,6), isnull(EQ_IMPMX,0), isnull(EQ_EXPFO,1), isnull(EQ_GEN,1), isnull(MA_DEF_TIP, 'G'),  isnull(ME_COM,0), isnull(@ME_GEN,0), @CANTIDAD, 'N',
				   @OT_FOLIO
			FROM MAESTRO WHERE MA_CODIGO=@MA_CODIGO
		
	FETCH NEXT FROM CUR_IMPEXPLOSION INTO @MA_CODIGO, @CANTIDAD
	END
	
	CLOSE CUR_IMPEXPLOSION
	DEALLOCATE CUR_IMPEXPLOSION



	update factimp
	set fi_cuentadet=(select isnull(count(*),0) from factimpdet where fi_codigo=@CONSECUTIVO1)
	where fi_codigo=@CONSECUTIVO1

	EXEC SP_INSERTPERMISODET @CONSECUTIVO1

	EXEC sp_actualizaReferencia @CONSECUTIVO1

GO
