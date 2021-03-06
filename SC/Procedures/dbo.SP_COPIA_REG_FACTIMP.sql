SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_COPIA_REG_FACTIMP] (@FUENTE INT,@DESTINO INT)  as

SET NOCOUNT ON 
declare @FID_INDICED INT, @FID_NOPARTE VARCHAR(30), @FID_NOMBRE VARCHAR(150), @FID_NAME VARCHAR(150), @FID_CANT_ST decimal(38,6), @FID_COS_UNI decimal(38,6), @FID_COS_TOT decimal(38,6), @FID_PES_UNI decimal(38,6), @FID_PES_NET decimal(38,6), 
                      @FID_PES_BRU decimal(38,6), @FID_PES_UNILB decimal(38,6), @FID_PES_NETLB decimal(38,6), @FID_PES_BRULB decimal(38,6), @FID_ORD_COMP VARCHAR(50), @FID_NOORDEN VARCHAR(20), @FID_FEC_ENT DATETIME, 
                      @FID_NUM_ENT VARCHAR(15), @FID_SEC_IMP INT, @FID_POR_DEF decimal(38,6), @FID_DEF_TIP CHAR(1), @FID_ENVIO VARCHAR(20), @AR_IMPMX INT, @AR_EXPFO INT, @MA_CODIGO INT, @MV_CODIGO INT, @ME_CODIGO INT, 
                      @MA_GENERICO INT, @ME_ARIMPMX INT, @PA_CODIGO INT, @PR_CODIGO INT, @PL_FOLIO VARCHAR(15),  @CS_CODIGO SMALLINT, @EQ_GEN decimal(28,14), @EQ_IMPMX decimal(28,14), 
                      @EQ_EXPFO decimal(28,14), @EQ_EXPFO2 decimal(28,14), @TI_CODIGO INT, @FID_RATEEXPFO decimal(38,6), @FID_RELEMP VARCHAR(1), @SPI_CODIGO SMALLINT, @MA_EMPAQUE INT, @FID_CANTEMP decimal(38,6), @FID_LOTE VARCHAR(15), @FID_FAC_NUM VARCHAR(15), 
                      @FID_FEC_ENV DATETIME, @FID_LISTA VARCHAR(50), @FID_CON_CERTORIG CHAR(1), @ME_GEN INT, @FID_GENERA_EMP CHAR(1), @FID_CANT_DESP decimal(38,6), @consecutivo int, @PE_CODIGO int



	exec sp_CreaFactImpDetTemp

-- insercion a tabla temporal
	insert into FactImpDetTemp(FI_CODIGO, FID_INDICEDANT, FID_NOPARTE, FID_NOMBRE, FID_NAME, FID_CANT_ST, FID_COS_UNI, FID_COS_TOT, FID_PES_UNI, FID_PES_NET, 
	                      FID_PES_BRU, FID_PES_UNILB, FID_PES_NETLB, FID_PES_BRULB, FID_ORD_COMP, FID_NOORDEN, FID_FEC_ENT, 
	                      FID_NUM_ENT, FID_SEC_IMP, FID_POR_DEF, FID_DEF_TIP, FID_ENVIO, AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, ME_CODIGO, 
	                      MA_GENERICO, ME_ARIMPMX, PA_CODIGO, PR_CODIGO, PL_FOLIO, CS_CODIGO, EQ_GEN, EQ_IMPMX, 
	                      EQ_EXPFO, EQ_EXPFO2, TI_CODIGO, FID_RATEEXPFO, FID_RELEMP, SPI_CODIGO, MA_EMPAQUE, FID_CANTEMP, FID_LOTE, FID_FAC_NUM, 
	                      FID_FEC_ENV, FID_LISTA, FID_CON_CERTORIG, ME_GEN, FID_GENERA_EMP, FID_CANT_DESP)
	
	SELECT    @DESTINO, FID_INDICED, FID_NOPARTE, FID_NOMBRE, FID_NAME, FID_CANT_ST, FID_COS_UNI, FID_COS_TOT, FID_PES_UNI, FID_PES_NET, 
	                      FID_PES_BRU, FID_PES_UNILB, FID_PES_NETLB, FID_PES_BRULB, FID_ORD_COMP, FID_NOORDEN, FID_FEC_ENT, 
	                      FID_NUM_ENT, FID_SEC_IMP, FID_POR_DEF, FID_DEF_TIP, FID_ENVIO, AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, ME_CODIGO, 
	                      MA_GENERICO, ME_ARIMPMX, PA_CODIGO, PR_CODIGO, PL_FOLIO, CS_CODIGO, EQ_GEN, EQ_IMPMX, 
	                      EQ_EXPFO, EQ_EXPFO2, TI_CODIGO, FID_RATEEXPFO, FID_RELEMP, SPI_CODIGO, MA_EMPAQUE, FID_CANTEMP, FID_LOTE, FID_FAC_NUM, 
	                      FID_FEC_ENV, FID_LISTA, FID_CON_CERTORIG, ME_GEN, FID_GENERA_EMP, FID_CANT_DESP
	FROM         FACTIMPDET WHERE FI_CODIGO=@FUENTE


-- insercion en detalle
	insert into factimpdet(FID_INDICED, FI_CODIGO, FID_NOPARTE, FID_NOMBRE, FID_NAME, FID_CANT_ST, FID_COS_UNI, FID_COS_TOT, FID_PES_UNI, FID_PES_NET, 
	                      FID_PES_BRU, FID_PES_UNILB, FID_PES_NETLB, FID_PES_BRULB, FID_ORD_COMP, FID_NOORDEN, FID_FEC_ENT, 
	                      FID_NUM_ENT, FID_SEC_IMP, FID_POR_DEF, FID_DEF_TIP, FID_ENVIO, AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, ME_CODIGO, 
	                      MA_GENERICO, ME_ARIMPMX, PA_CODIGO, PR_CODIGO, PL_FOLIO, CS_CODIGO, EQ_GEN, EQ_IMPMX, 
	                      EQ_EXPFO, EQ_EXPFO2, TI_CODIGO, FID_RATEEXPFO, FID_RELEMP, SPI_CODIGO, MA_EMPAQUE, FID_CANTEMP, FID_LOTE, FID_FAC_NUM, 
	                      FID_FEC_ENV, FID_LISTA, FID_CON_CERTORIG, ME_GEN, FID_GENERA_EMP, FID_CANT_DESP)
	SELECT    FID_INDICED, FI_CODIGO, FID_NOPARTE, FID_NOMBRE, FID_NAME, FID_CANT_ST, FID_COS_UNI, FID_COS_TOT, FID_PES_UNI, FID_PES_NET, 
	                      FID_PES_BRU, FID_PES_UNILB, FID_PES_NETLB, FID_PES_BRULB, FID_ORD_COMP, FID_NOORDEN, FID_FEC_ENT, 
	                      FID_NUM_ENT, FID_SEC_IMP, FID_POR_DEF, FID_DEF_TIP, FID_ENVIO, AR_IMPMX, AR_EXPFO, MA_CODIGO, MV_CODIGO, ME_CODIGO, 
	                      MA_GENERICO, ME_ARIMPMX, PA_CODIGO, PR_CODIGO, PL_FOLIO, CS_CODIGO, EQ_GEN, EQ_IMPMX, 
	                      EQ_EXPFO, EQ_EXPFO2, TI_CODIGO, FID_RATEEXPFO, FID_RELEMP, SPI_CODIGO, MA_EMPAQUE, FID_CANTEMP, FID_LOTE, FID_FAC_NUM, 
	                      FID_FEC_ENV, FID_LISTA, FID_CON_CERTORIG, ME_GEN, FID_GENERA_EMP, FID_CANT_DESP
	FROM         FACTIMPDETTemp


-- insercion en permisos
/*
	INSERT INTO FACTIMPPERM(FID_INDICED, FI_CODIGO, PE_CODIGO, PED_INDICED)
	SELECT     dbo.FactImpDetTemp.FID_INDICED, dbo.FactImpDetTemp.FI_CODIGO, dbo.FACTIMPPERM.PE_CODIGO, dbo.FACTIMPPERM.PED_INDICED
	FROM         dbo.FactImpDetTemp INNER JOIN
	                      dbo.FACTIMPPERM ON dbo.FactImpDetTemp.FID_INDICEDANT = dbo.FACTIMPPERM.FID_INDICED

*/
	update factimp
	set fi_cuentadet=(select isnull(count(factimpdet.fi_codigo),0) from factimpdet where factimpdet.fi_codigo =factimp.fi_codigo),
                  FI_TOTALB = (select FI_TOTALB from factimp where fi_codigo = @FUENTE)
	where fi_codigo =@DESTINO



		select @FID_INDICED= max(fid_indiced) from factimpdet

		update consecutivo
		set cv_codigo =  isnull(@fid_indiced,0) + 1
		where cv_tipo = 'FID'

	exec sp_droptable 'FactImpDetTemp'



GO
